# app/schemas/product.py
from pydantic import BaseModel
from typing import List, Optional

class PharmacyLocationInfo(BaseModel):
    """Information about where a package is available"""
    pharmacy_id: str  # Changed to str to match your schema
    pharmacy_name: str
    pharmacy_address: str
    pharmacy_city: str
    pharmacy_country: str
    price_cents: Optional[int]  # Price in cents (e.g., 1250 = €12.50)
    currency: str = "EUR"
    stock_quantity: int
    last_updated: Optional[str]  # ISO format datetime string

class PackageAvailabilityInfo(BaseModel):
    """A package with all its availability information"""
    package_id: str
    gtin: Optional[str]
    pack_size: Optional[str]  # e.g., "20 tablets"
    brand_name: Optional[str]
    manufacturer: Optional[str]
    country_code: Optional[str]
    pharmacy_locations: List[PharmacyLocationInfo]  # All pharmacies where this package is available

class ProductSearchResponse(BaseModel):
    """Complete search response with all connected data"""
    product_id: str
    inn_name: str  # Original INN name
    display_name: str  # Translated name or INN fallback
    description: Optional[str]  # Translated description
    atc_code: Optional[str]
    form: Optional[str]  # tablet, capsule, etc.
    strength: Optional[str]  # 500mg, etc.
    brand_names: List[str]  # All brand names for this product
    available_packages: List[PackageAvailabilityInfo]
    language: str  # Language of the translation used
    
    class Config:
        from_attributes = True

# Simple response for basic searches (backward compatibility)
class ProductSimpleResponse(BaseModel):
    product_id: str
    display_name: str
    form: Optional[str]
    strength: Optional[str]
    brand_names: List[str]
    min_price_cents: Optional[int]  # Lowest price across all packages
    total_stock: int  # Total stock across all pharmacies
    
    class Config:
        from_attributes = True