# app/routers/products.py
from fastapi import APIRouter, Depends, Query, HTTPException
from sqlalchemy import select, or_, and_, func
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload
from typing import Optional, List, Dict, DefaultDict
from collections import defaultdict

from ..core.db import get_db
from ..models import Product, Package, Brand, PharmacyInventory, Pharmacy, Translation
from ..schemas.product import (
    ProductSearchItem,
    ProductDetailModel,
    PackageAvailabilityInfo,
    PharmacyLocationInfo,
)

router = APIRouter(prefix="/products", tags=["products"])

@router.get("/search", response_model=list[ProductSearchItem])
async def search_products(
    q: str,
    limit: int = Query(20, ge=1, le=100),
    language: Optional[str] = Query("en"),
    db: AsyncSession = Depends(get_db)
):
    """
    Simple product search for typeahead/search functionality.
    Returns minimal product info without inventory/location data.
    """
    q_like = f"%{q}%"

    stmt = (
        select(Product)
        .options(
            selectinload(Product.brands),
            selectinload(Product.translations)
        )
        .join(Brand, isouter=True)
        .join(Translation, isouter=True)
        .where(
            or_(
                Product.inn_name.ilike(q_like),
                Product.atc_code.ilike(q_like),
                Brand.brand_name.ilike(q_like),
                and_(
                    Translation.language_code == language,
                    Translation.translated_name.ilike(q_like),
                ),
            )
        )
        .distinct()
        .limit(limit)
    )

    res = await db.execute(stmt)
    products = res.scalars().all()

    items: list[ProductSearchItem] = []
    for p in products:
        display_name = p.inn_name
        for t in p.translations:
            if t.language_code == language and t.translated_name:
                display_name = t.translated_name
                break
        
        items.append(ProductSearchItem(
            product_id=p.id,
            inn_name=p.inn_name,
            display_name=display_name,
            form=p.form,
            strength=p.strength,
        ))

    return items



@router.get("/{product_id}/packages", response_model=ProductDetailModel)
async def get_product_packages(
    product_id: str,
    language: Optional[str] = Query("en"),
    lat: Optional[float] = Query(None),
    lng: Optional[float] = Query(None),
    radius_km: Optional[int] = Query(120, ge=1, le=200),
    only_in_stock: bool = True,
    db: AsyncSession = Depends(get_db),
):
    """
    Search for packages of a specific product with their pharmacy locations and prices.
    Now includes proper location filtering to prevent fetching from entire database.
    Only returns packages that have pharmacies within the specified location criteria.
    """
    # 1) Load product + brands + translations (no inventories yet)
    prod_stmt = (
        select(Product)
        .options(
            selectinload(Product.brands),
            selectinload(Product.translations),
        )
        .where(Product.id == product_id)
    )
    prod_res = await db.execute(prod_stmt)
    product = prod_res.scalar_one_or_none()
    if not product:
        raise HTTPException(404, "Product not found")

    # choose display name
    display_name = product.inn_name
    description = None
    for t in product.translations:
        if t.language_code == language and t.translated_name:
            display_name = t.translated_name
            description = t.translated_description
            break

    # 2) Load packages for product
    pkg_stmt = (
        select(Package)
        .options(selectinload(Package.brand))
        .where(Package.product_id == product_id)
    )
    pkg_res = await db.execute(pkg_stmt)
    packages = pkg_res.scalars().all()
    if not packages:
        return ProductDetailModel(
            product_id=product.id,
            inn_name=product.inn_name,
            display_name=display_name,
            description=description,
            atc_code=product.atc_code,
            form=product.form,
            strength=product.strength,
            brand_names=sorted({b.brand_name for b in product.brands}),
            available_packages=[],
            language=language,
        )

    package_ids = [p.id for p in packages]

    # 3) Load inventories + pharmacies for these packages with LOCATION FILTERING
    # This is the key improvement - filter pharmacies by location BEFORE loading inventory
    inv_stmt = (
        select(PharmacyInventory, Pharmacy)
        .join(Pharmacy, PharmacyInventory.pharmacy_id == Pharmacy.id)
        .where(PharmacyInventory.package_id.in_(package_ids))
    )

    # Apply location filtering first to limit the pharmacy set
    if lat is not None and lng is not None and radius_km is not None:
        # Only include pharmacies with coordinates within radius
        inv_stmt = inv_stmt.where(Pharmacy.lat.isnot(None), Pharmacy.lng.isnot(None))
        inv_stmt = inv_stmt.where(Pharmacy.distance_to(lat, lng) <= radius_km)
    else:
        # If no location provided, still require pharmacies to have coordinates
        # to avoid returning pharmacies without location data
        inv_stmt = inv_stmt.where(Pharmacy.lat.isnot(None), Pharmacy.lng.isnot(None))

    # Apply stock filtering
    if only_in_stock:
        inv_stmt = inv_stmt.where(PharmacyInventory.stock_quantity.isnot(None)) \
                           .where(PharmacyInventory.stock_quantity > 0)

    inv_res = await db.execute(inv_stmt)
    rows = inv_res.all()

    # 4) Group inventories by package_id
    pkg_map: Dict[str, Package] = {p.id: p for p in packages}
    grouped: DefaultDict[str, List[PharmacyLocationInfo]] = defaultdict(list)

    for inv, ph in rows:
        grouped[inv.package_id].append(PharmacyLocationInfo(
            pharmacy_id=ph.id,
            pharmacy_name=ph.name,
            pharmacy_address=ph.address or "",
            pharmacy_city=ph.city or "",
            pharmacy_country=ph.country or "",
            lat=ph.lat,
            lng=ph.lng,
            price_cents=int(inv.price_cents) if inv.price_cents is not None else None,
            currency=inv.currency or "EUR",
            stock_quantity=inv.stock_quantity or 0,
            last_updated=inv.last_updated.isoformat() if inv.last_updated else None,
        ))

    # 5) Build response packages; only include packages with pharmacy locations in the specified area
    available_packages: List[PackageAvailabilityInfo] = []
    for pid, locations in grouped.items():
        pkg = pkg_map.get(pid)
        if not pkg:
            continue
        # Only include packages that have at least one pharmacy location
        if locations:
            available_packages.append(PackageAvailabilityInfo(
                package_id=pid,
                gtin=pkg.gtin,
                pack_size=pkg.pack_size,
                brand_name=pkg.brand.brand_name if pkg.brand else None,
                manufacturer=pkg.brand.manufacturer if pkg.brand else None,
                country_code=pkg.country_code,
                pharmacy_locations=locations
            ))

    return ProductDetailModel(
        product_id=product.id,
        inn_name=product.inn_name,
        display_name=display_name,
        description=description,
        atc_code=product.atc_code,
        form=product.form,
        strength=product.strength,
        brand_names=sorted({b.brand_name for b in product.brands}),
        available_packages=available_packages,
        language=language,
    )