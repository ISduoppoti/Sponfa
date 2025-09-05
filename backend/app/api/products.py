# app/routers/products.py
from fastapi import APIRouter, Depends, Query
from sqlalchemy import select, or_, and_
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload
from typing import Optional
from ..core.db import get_db
from ..models import Product, Package, Brand, PharmacyInventory, Pharmacy, Translation
from ..schemas.product import ProductSearchResponse

router = APIRouter(prefix="/products", tags=["products"])

@router.get("/search", response_model=list[ProductSearchResponse])
async def search_products(
    q: str, 
    limit: int = Query(20, ge=1, le=100),
    language: Optional[str] = Query("en", description="Language code for translations"),
    lat: Optional[float] = None,
    lng: Optional[float] = None,
    radius_km: Optional[int] = Query(120, ge=1, le=200),
    db: AsyncSession = Depends(get_db)
):
    """
    Search for products with full pharmacy availability info
    """
    # Build the complex query with all relationships
    stmt = (
        select(Product)
        .options(
            # Load brands
            selectinload(Product.brands),
            
            # Load packages with their pharmacy inventories and pharmacy details
            selectinload(Product.packages)
            .selectinload(Package.inventories)
            .selectinload(PharmacyInventory.pharmacy),
            
            # Load packages with their brand info
            selectinload(Product.packages)
            .selectinload(Package.brand),
            
            # Load translations
            selectinload(Product.translations)
        )
        .join(Translation, isouter=True)  # Left join for translations
        .join(Brand, isouter=True)        # Left join for brands
        .join(Package, isouter=True)      # Left join for packages
        .join(PharmacyInventory, Package.id == PharmacyInventory.package_id, isouter=True)
        .join(Pharmacy, PharmacyInventory.pharmacy_id == Pharmacy.id, isouter=True)
        .where(
            or_(
                # Search in INN name
                Product.inn_name.ilike(f"%{q}%"),
                # Search in ATC code
                Product.atc_code.ilike(f"%{q}%"),
                # Search in brand names
                Brand.brand_name.ilike(f"%{q}%"),
                # Search in translations
                and_(
                    Translation.language_code == language,
                    Translation.translated_name.ilike(f"%{q}%")
                )
            )
        )
        .distinct()
        .limit(limit)
    )
    
    # Add location filtering if provided
    if lat is not None and lng is not None and radius_km is not None:
        print("I AM FILTERING")
        stmt = stmt.where(Pharmacy.distance_to(lat, lng) <= radius_km)
    
    result = await db.execute(stmt)
    products = result.scalars().all()
    
    # Transform to response format
    search_results = []
    
    for product in products:
        # Get translation for current language
        product_name = product.inn_name  # default
        product_description = None
        
        # TODO: Translation descr, name
        for translation in product.translations:
            if translation.language_code == language and translation.translated_name:
                product_name = translation.translated_name
                product_description = translation.translated_description
                break
        
        # Process packages with availability
        available_packages = []
        
        for package in product.packages:
            # Only include packages that have inventory
            if not package.inventories:
                continue
                
            # Filter for packages with stock > 0 TODO:
            in_stock_inventories = [
                inv for inv in package.inventories 
                # if inv.stock_quantity and inv.stock_quantity > 0
            ]
            
            if not in_stock_inventories:
                continue
                
            # Build pharmacy info for this package
            pharmacy_locations = []
            for inventory in in_stock_inventories:
                if inventory.pharmacy:
                    pharmacy_locations.append({
                        "pharmacy_id": inventory.pharmacy.id,
                        "pharmacy_name": inventory.pharmacy.name,
                        "pharmacy_country": inventory.pharmacy.country, # eg "AT"
                        "pharmacy_city": inventory.pharmacy.city,
                        "pharmacy_address": inventory.pharmacy.address,
                        "price_cents": int(inventory.price_cents) if inventory.price_cents else None,
                        "currency": inventory.currency,
                        "stock_quantity": inventory.stock_quantity,
                        "last_updated": inventory.last_updated,
                    })
            
            if pharmacy_locations:
                available_packages.append({
                    "package_id": package.id,
                    "gtin": package.gtin,
                    "pack_size": package.pack_size,
                    "brand_name": package.brand.brand_name if package.brand else None,
                    "manufacturer": package.brand.manufacturer if package.brand else None,
                    "country_code": package.country_code,
                    "pharmacy_locations": pharmacy_locations
                })
        
        # Only include products that have available packages
        if available_packages:
            search_results.append({
                "product_id": product.id,
                "inn_name": product.inn_name,
                "display_name": product_name,  # Translated name or fallback to INN
                "description": product_description,
                "atc_code": product.atc_code,
                "form": product.form,
                "strength": product.strength,
                "brand_names": list(set(brand.brand_name for brand in product.brands)),
                "available_packages": available_packages,
                "language": language
            })

    import json
    print("SAVING>>>>>>")
    with open("search_results.json", "w", encoding="utf-8") as f:
        json.dump(search_results, f, ensure_ascii=False, indent=2)
    return search_results


@router.get("/products/{product_id}/pharmacies")
async def get_product_pharmacies(
    product_id: str,
    lat: Optional[float] = None,
    lng: Optional[float] = None,
    radius_km: Optional[int] = Query(None, ge=1, le=100),
    db: AsyncSession = Depends(get_db),
):
    stmt = (
        select(Pharmacy, PharmacyInventory, Package)
        .join(PharmacyInventory, Pharmacy.id == PharmacyInventory.pharmacy_id)
        .join(Package, Package.id == PharmacyInventory.package_id)
        .where(Package.product_id == product_id)
    )

    # Apply radius filter
    if lat is not None and lng is not None and radius_km is not None:
        stmt = stmt.where(Pharmacy.distance_to(lat, lng) <= radius_km)
        stmt = stmt.add_columns(distance_expr.label("distance_km"))
        stmt = stmt.order_by("distance_km")

    result = await db.execute(stmt)
    rows = result.all()

    pharmacies = []
    for row in rows:
        pharmacy = row[0]
        inventory = row[1]
        package = row[2]
        distance = getattr(row, "distance_km", None)

        pharmacies.append({
            "id": pharmacy.id,
            "name": pharmacy.name,
            "latitude": pharmacy.latitude,
            "longitude": pharmacy.longitude,
            "distance_km": distance,
            "stock": inventory.stock_quantity,
            "package_id": package.id,
        })

    return pharmacies
