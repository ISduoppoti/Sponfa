# app/schemas/product.py
from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime

# Simple search result for typeahead/search
class ProductSearchItem(BaseModel):
    product_id: str
    inn_name: str
    display_name: str  # Translated name or inn_name
    form: Optional[str] = None
    strength: Optional[str] = None

    class Config:
        from_attributes = True

# Detailed pharmacy location info
class PharmacyLocationInfo(BaseModel):
    pharmacy_id: str
    pharmacy_name: str
    pharmacy_address: str
    pharmacy_city: str
    pharmacy_country: str
    lat: Optional[float] = None
    lng: Optional[float] = None
    price_cents: Optional[int] = None
    currency: str = "EUR"
    stock_quantity: int
    last_updated: Optional[str] = None

    class Config:
        from_attributes = True

# Package availability with pharmacy locations
class PackageAvailabilityInfo(BaseModel):
    package_id: str
    gtin: Optional[str] = None
    pack_size: Optional[str] = None
    brand_name: Optional[str] = None
    manufacturer: Optional[str] = None
    country_code: Optional[str] = None
    pharmacy_locations: List[PharmacyLocationInfo]

    class Config:
        from_attributes = True

# Detailed product response with full information
class ProductDetailModel(BaseModel):
    product_id: str
    inn_name: str
    display_name: str  # Translated name or inn_name
    description: Optional[str] = None  # Translated description
    atc_code: Optional[str] = None
    form: Optional[str] = None
    strength: Optional[str] = None
    brand_names: List[str]
    available_packages: List[PackageAvailabilityInfo]
    language: str

    class Config:
        from_attributes = True

# Pharmacy search request
class PharmaciesSearchRequest(BaseModel):
    package_ids: List[str]
    lat: Optional[float] = None
    lng: Optional[float] = None
    radius_km: Optional[int] = 120
    must_have_all: bool = False
    sort_by: str = "distance"  # "distance", "price", "name"
    limit: int = 50

# Individual package line in pharmacy search results
class PharmacyPackageLine(BaseModel):
    package_id: str
    price_cents: Optional[int] = None
    currency: Optional[str] = "EUR"
    stock_quantity: int
    last_updated: Optional[str] = None

    class Config:
        from_attributes = True

# Pharmacy search result
class PharmacySearchResult(BaseModel):
    pharmacy_id: str
    pharmacy_name: str
    address: Optional[str] = None
    city: Optional[str] = None
    country: Optional[str] = None
    lat: Optional[float] = None
    lng: Optional[float] = None
    distance_km: Optional[float] = None
    packages: List[PharmacyPackageLine]

    class Config:
        from_attributes = True

# Legacy schema names for backward compatibility
ProductTypeaheadItem = ProductSearchItem  # Alias for backward compatibility