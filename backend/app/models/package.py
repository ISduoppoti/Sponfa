# app/models/package.py
from typing import List
from sqlalchemy import String, Boolean
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.core.db import Base


class Package(Base):
    __tablename__ = "packages"

    id: Mapped[str] = mapped_column(String, primary_key=True)
    product_id: Mapped[str] = mapped_column(String, nullable=False)
    brand_id: Mapped[str] = mapped_column(String, nullable=True)
    gtin: Mapped[str] = mapped_column(String, index=True, unique=True, nullable=True)  # EAN/GTIN, optional
    pack_size: Mapped[str] = mapped_column(String, nullable=True)  # "20 tablets"
    country_code: Mapped[str] = mapped_column(String(2), nullable=True)  # ISO 3166-1 alpha-2

    from sqlalchemy import ForeignKey
    product_id = mapped_column(ForeignKey("products.id"), nullable=False)
    brand_id = mapped_column(ForeignKey("brands.id"), nullable=True)

    # relationships
    product = relationship("Product", back_populates="packages")
    brand = relationship("Brand", back_populates="packages")
    images: Mapped[List["ProductImage"]] = relationship("ProductImage", back_populates="package", cascade="all, delete-orphan")
    inventories: Mapped[List["PharmacyInventory"]] = relationship("PharmacyInventory", back_populates="package", cascade="all, delete-orphan")
