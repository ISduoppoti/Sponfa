# app/routers/pharmacies.py
from fastapi import APIRouter, Depends
from sqlalchemy import select, func, literal_column
from sqlalchemy.ext.asyncio import AsyncSession
from typing import List, Dict, DefaultDict
from collections import defaultdict

from ..core.db import get_db
from ..models import Pharmacy, PharmacyInventory
from ..schemas.product import PharmaciesSearchRequest, PharmacySearchResult, PharmacyPackageLine

router = APIRouter(prefix="/pharmacies", tags=["pharmacies"])

@router.post("/search", response_model=List[PharmacySearchResult])
async def search_pharmacies(
    body: PharmaciesSearchRequest,
    db: AsyncSession = Depends(get_db)
):
    if not body.package_ids:
        return []

    # Base query: candidate pharmacies that carry any of the package_ids
    base_stmt = (
        select(
            Pharmacy.id.label("ph_id"),
            Pharmacy.name,
            Pharmacy.address,
            Pharmacy.city,
            Pharmacy.country,
            Pharmacy.lat,
            Pharmacy.lng,
        )
        .join(PharmacyInventory, Pharmacy.id == PharmacyInventory.pharmacy_id)
        .where(PharmacyInventory.package_id.in_(body.package_ids))
    )

    # Optional stock > 0
    base_stmt = base_stmt.where(
        PharmacyInventory.stock_quantity.isnot(None),
        PharmacyInventory.stock_quantity > 0
    )

    # Radius filter
    if body.lat is not None and body.lng is not None and body.radius_km is not None:
        base_stmt = base_stmt.where(Pharmacy.lat.isnot(None), Pharmacy.lng.isnot(None))
        base_stmt = base_stmt.where(Pharmacy.distance_to(body.lat, body.lng) <= body.radius_km)
        base_stmt = base_stmt.add_columns(Pharmacy.distance_to(body.lat, body.lng).label("distance_km"))
    else:
        base_stmt = base_stmt.add_columns(literal_column("NULL").label("distance_km"))

    # If must_have_all: group and HAVING count(distinct pkg) = len(package_ids)
    group_stmt = (
        select(
            Pharmacy.id.label("ph_id"),
            func.min(PharmacyInventory.price_cents).label("min_price_cents"),
            func.count(func.distinct(PharmacyInventory.package_id)).label("pkg_count"),
            func.min(Pharmacy.distance_to(body.lat, body.lng)).label("distance_km") if (body.lat is not None and body.lng is not None) else literal_column("NULL").label("distance_km")
        )
        .join(PharmacyInventory, Pharmacy.id == PharmacyInventory.pharmacy_id)
        .where(PharmacyInventory.package_id.in_(body.package_ids))
    )

    group_stmt = group_stmt.where(
        PharmacyInventory.stock_quantity.isnot(None),
        PharmacyInventory.stock_quantity > 0
    )

    if body.lat is not None and body.lng is not None and body.radius_km is not None:
        group_stmt = group_stmt.where(Pharmacy.lat.isnot(None), Pharmacy.lng.isnot(None))
        group_stmt = group_stmt.where(Pharmacy.distance_to(body.lat, body.lng) <= body.radius_km)

    group_stmt = group_stmt.group_by(Pharmacy.id)

    if body.must_have_all:
        group_stmt = group_stmt.having(func.count(func.distinct(PharmacyInventory.package_id)) == len(body.package_ids))

    # ORDER
    if body.sort_by == "price":
        group_stmt = group_stmt.order_by(func.min(PharmacyInventory.price_cents).asc().nulls_last())
    elif body.sort_by == "name":
        group_stmt = group_stmt.order_by(Pharmacy.name.asc())
    else:
        # distance default
        if body.lat is not None and body.lng is not None:
            group_stmt = group_stmt.order_by(func.min(Pharmacy.distance_to(body.lat, body.lng)).asc().nulls_last())
        else:
            group_stmt = group_stmt.order_by(Pharmacy.name.asc())

    group_stmt = group_stmt.limit(body.limit)

    # Execute “header rows”
    head_res = await db.execute(
        select(
            Pharmacy.id,
            Pharmacy.name,
            Pharmacy.address,
            Pharmacy.city,
            Pharmacy.country,
            Pharmacy.lat,
            Pharmacy.lng,
            # Re-join the aggregation for distance/min price
            func.min(PharmacyInventory.price_cents).label("min_price_cents"),
            func.count(func.distinct(PharmacyInventory.package_id)).label("pkg_count"),
            func.min(Pharmacy.distance_to(body.lat, body.lng)).label("distance_km") if (body.lat is not None and body.lng is not None) else literal_column("NULL").label("distance_km")
        )
        .join(PharmacyInventory, Pharmacy.id == PharmacyInventory.pharmacy_id)
        .where(PharmacyInventory.package_id.in_(body.package_ids))
        .where(PharmacyInventory.stock_quantity.isnot(None), PharmacyInventory.stock_quantity > 0)
        .group_by(Pharmacy.id)
        .having(func.count(func.distinct(PharmacyInventory.package_id)) == len(body.package_ids)) if body.must_have_all else
        select(
            Pharmacy.id,
            Pharmacy.name,
            Pharmacy.address,
            Pharmacy.city,
            Pharmacy.country,
            Pharmacy.lat,
            Pharmacy.lng,
            func.min(PharmacyInventory.price_cents).label("min_price_cents"),
            func.count(func.distinct(PharmacyInventory.package_id)).label("pkg_count"),
            func.min(Pharmacy.distance_to(body.lat, body.lng)).label("distance_km") if (body.lat is not None and body.lng is not None) else literal_column("NULL").label("distance_km")
        )
        .join(PharmacyInventory, Pharmacy.id == PharmacyInventory.pharmacy_id)
        .where(PharmacyInventory.package_id.in_(body.package_ids))
        .where(PharmacyInventory.stock_quantity.isnot(None), PharmacyInventory.stock_quantity > 0)
        .group_by(Pharmacy.id)
    )

    header_rows = head_res.all()
    if not header_rows:
        return []

    pharmacy_ids = [r[0] for r in header_rows]

    # Pull per-package lines for these pharmacies and requested packages
    lines_res = await db.execute(
        select(
            PharmacyInventory.pharmacy_id,
            PharmacyInventory.package_id,
            PharmacyInventory.price_cents,
            PharmacyInventory.currency,
            PharmacyInventory.stock_quantity,
            PharmacyInventory.last_updated,
        )
        .where(PharmacyInventory.pharmacy_id.in_(pharmacy_ids))
        .where(PharmacyInventory.package_id.in_(body.package_ids))
        .where(PharmacyInventory.stock_quantity.isnot(None), PharmacyInventory.stock_quantity > 0)
    )

    lines = lines_res.all()
    per_pharmacy: DefaultDict[str, List[PharmacyPackageLine]] = defaultdict(list)
    for ph_id, pkg_id, price, curr, stock, lu in lines:
        per_pharmacy[ph_id].append(PharmacyPackageLine(
            package_id=pkg_id,
            price_cents=int(price) if price is not None else None,
            currency=curr,
            stock_quantity=stock,
            last_updated=lu.isoformat() if lu else None,
        ))

    # Build final list
    results: List[PharmacySearchResult] = []
    for ph_id, name, addr, city, country, lat, lng, min_price, pkg_count, distance_km in header_rows:
        results.append(PharmacySearchResult(
            pharmacy_id=ph_id,
            pharmacy_name=name,
            address=addr,
            city=city,
            country=country,
            lat=lat,
            lng=lng,
            distance_km=float(distance_km) if distance_km is not None else None,
            packages=per_pharmacy.get(ph_id, []),
        ))

    # Optional sorting on the Python side if needed (already sorted in SQL for distance/price/name)
    # You can also apply limit here if you used a simpler header query.

    return results
