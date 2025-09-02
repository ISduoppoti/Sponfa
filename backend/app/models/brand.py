# app/models/brand.py
from typing import List
from sqlalchemy import String
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.core.db import Base


class Brand(Base):
    __tablename__ = "brands"

    id: Mapped[str] = mapped_column(String, primary_key=True)
    product_id: Mapped[str] = mapped_column(String, nullable=False)  # will add FK in below line
    brand_name: Mapped[str] = mapped_column(String, index=True, nullable=False)
    manufacturer: Mapped[str] = mapped_column(String, nullable=True)

    # use a ForeignKey import here to avoid circular import issues at runtime
    from sqlalchemy import ForeignKey  # local import to keep top-level simple
    product_id = mapped_column(ForeignKey("products.id"), nullable=False)

    # relationships
    product = relationship("Product", back_populates="brands")
    packages = relationship("Package", back_populates="brand", cascade="all, delete-orphan")
