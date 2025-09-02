# app/models/product.py
from typing import List
from sqlalchemy import String, Column
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.core.db import Base


class Product(Base):
    __tablename__ = "products"

    # canonical product (one row per substance+strength+form)
    id: Mapped[str] = mapped_column(String, primary_key=True)  # UUID stored as text
    inn_name: Mapped[str] = mapped_column(String, index=True, nullable=False)  # e.g., "ibuprofen"
    atc_code: Mapped[str] = mapped_column(String, index=True, nullable=True)  # optional WHO ATC
    form: Mapped[str] = mapped_column(String, nullable=True)  # tablet, capsule, cream
    strength: Mapped[str] = mapped_column(String, nullable=True)  # 400 mg

    # relationships
    brands: Mapped[List["Brand"]] = relationship("Brand", back_populates="product", cascade="all, delete-orphan")
    packages: Mapped[List["Package"]] = relationship("Package", back_populates="product", cascade="all, delete-orphan")
    translations: Mapped[List["Translation"]] = relationship("Translation", back_populates="product", cascade="all, delete-orphan")
