from fastapi import APIRouter, Depends
from sqlalchemy import select, func, literal_column
from sqlalchemy.ext.asyncio import AsyncSession
from typing import List, DefaultDict, Optional
from collections import defaultdict
from ..core.db import get_db
from ..models import Pharmacy, PharmacyInventory, Package, Brand
from ..schemas.product import PharmaciesSearchRequest, PharmacySearchResult, PharmacyPackageLine

router = APIRouter(prefix="/pharmacies", tags=["pharmacies"])

@router.post("/search", response_model=List[PharmacySearchResult])
async def search_pharmacies(
    body: PharmaciesSearchRequest,
    db: AsyncSession = Depends(get_db)
):
    if not body.package_ids:
        return []

    # Set default radius if lat/lng provided but no radius (to prevent worldwide results)
    DEFAULT_RADIUS_KM = 100.0  # Adjust as needed (e.g., 50.0 for stricter city-level)
    if body.lat is not None and body.lng is not None and body.radius_km is None:
        body.radius_km = DEFAULT_RADIUS_KM

    # Build the base grouped query for header rows
    header_stmt = (
        select(
            Pharmacy.id,
            Pharmacy.name,
            Pharmacy.address,
            Pharmacy.city,
            Pharmacy.country,
            Pharmacy.lat,
            Pharmacy.lng,
            func.min(PharmacyInventory.price_cents).label("min_price_cents"),
            func.sum(PharmacyInventory.price_cents).label("total_price_cents"),
            func.count(func.distinct(PharmacyInventory.package_id)).label("pkg_count"),
        )
        .join(PharmacyInventory, Pharmacy.id == PharmacyInventory.pharmacy_id)
        .where(PharmacyInventory.package_id.in_(body.package_ids))
        .where(PharmacyInventory.stock_quantity.isnot(None), PharmacyInventory.stock_quantity > 0)
        .group_by(Pharmacy.id)
    )


    # Add distance column and radius filter conditionally (after broad filters)
    if body.lat is not None and body.lng is not None:
        distance_expr = Pharmacy.distance_to(body.lat, body.lng)
        header_stmt = header_stmt.add_columns(func.min(distance_expr).label("distance_km"))
        if body.radius_km is not None:
            header_stmt = header_stmt.where(Pharmacy.lat.isnot(None), Pharmacy.lng.isnot(None))
            header_stmt = header_stmt.where(distance_expr <= body.radius_km)
    else:
        header_stmt = header_stmt.add_columns(literal_column("NULL").label("distance_km"))

    # Apply HAVING if must_have_all (for multi-package: require all packages)
    if body.must_have_all:
        header_stmt = header_stmt.having(func.count(func.distinct(PharmacyInventory.package_id)) == len(body.package_ids))

    # Apply sorting based on sort_by
    if body.sort_by == "price":
        header_stmt = header_stmt.order_by(func.min(PharmacyInventory.price_cents).asc().nulls_last())
    elif body.sort_by == "name":
        header_stmt = header_stmt.order_by(Pharmacy.name.asc())
    else:
        # Default: distance if available, else name
        if body.lat is not None and body.lng is not None:
            header_stmt = header_stmt.order_by(func.min(Pharmacy.distance_to(body.lat, body.lng)).asc().nulls_last())
        else:
            header_stmt = header_stmt.order_by(Pharmacy.name.asc())

    # Apply limit
    header_stmt = header_stmt.limit(body.limit)

    # Execute header query
    head_res = await db.execute(header_stmt)
    header_rows = head_res.all()
    if not header_rows:
        return []

    pharmacy_ids = [r[0] for r in header_rows]

    # Pull per-package lines, including brand_name via joins
    lines_res = await db.execute(
        select(
            PharmacyInventory.pharmacy_id,
            PharmacyInventory.package_id,
            PharmacyInventory.price_cents,
            PharmacyInventory.currency,
            PharmacyInventory.stock_quantity,
            PharmacyInventory.last_updated,
            Brand.brand_name,
        )
        .join(Package, PharmacyInventory.package_id == Package.id)
        .join(Brand, Package.brand_id == Brand.id, isouter=True)  # Outer join since brand_id nullable
        .where(PharmacyInventory.pharmacy_id.in_(pharmacy_ids))
        .where(PharmacyInventory.package_id.in_(body.package_ids))
        .where(PharmacyInventory.stock_quantity.isnot(None), PharmacyInventory.stock_quantity > 0)
    )
    lines = lines_res.all()

    per_pharmacy: DefaultDict[str, List[PharmacyPackageLine]] = defaultdict(list)
    for ph_id, pkg_id, price, curr, stock, lu, brand_name in lines:
        per_pharmacy[ph_id].append(PharmacyPackageLine(
            package_id=pkg_id,
            price_cents=int(price) if price is not None else None,
            currency=curr,
            stock_quantity=stock,
            last_updated=lu.isoformat() if lu else None,
            brand_name=brand_name,  # Will be None if no brand
        ))

    # Build final list
    results: List[PharmacySearchResult] = []
    for row in header_rows:
        # Unpack row (adjust index if distance_km is present)
        ph_id, name, addr, city, country, lat, lng, min_price, total_price, pkg_count = row[:10]
        distance_km = row[10] if len(row) > 10 else None  # Handles case without distance
        results.append(PharmacySearchResult(
            pharmacy_id=ph_id,
            pharmacy_name=name,
            address=addr,
            city=city,
            country=country,
            lat=lat,
            lng=lng,
            distance_km=float(distance_km) if distance_km is not None else None,
            min_price_cents=int(min_price) if min_price is not None else None,
            total_price_cents=int(total_price) if total_price is not None else None,
            pkg_count=pkg_count,
            packages=per_pharmacy.get(ph_id, []),
        ))

    # For debugging: Serialize to JSON
    serializable_results = [result.model_dump() for result in results]
    import json
    with open("pharma_results.json", "w") as file:
        json.dump(serializable_results, file, indent=2)

    return results