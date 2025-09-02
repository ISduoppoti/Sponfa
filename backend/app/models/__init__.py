# No import directrly because it will lead to circularity
# from . import bookings, pharmacies, product
# app/models/__init__.py
from app.core.db import Base

# import all models so Base.metadata contains them for Alembic
from app.models.product import Product
from app.models.brand import Brand
from app.models.package import Package
from app.models.product_image import ProductImage
from app.models.translation import Translation
from app.models.pharmacies import Pharmacy
from app.models.pharmacy_inventory import PharmacyInventory
from app.models.bookings import Booking

__all__ = [
    "Base",
    "Product", "Brand", "Package", "ProductImage", "Translation", "Pharmacy", "PharmacyInventory", "Booking"
]

