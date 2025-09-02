# app/models/pharmacy_inventory.py
from sqlalchemy import String, Integer, Boolean
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.core.db import Base


class PharmacyInventory(Base):
    __tablename__ = "pharmacy_inventory"

    id: Mapped[str] = mapped_column(String, primary_key=True)
    pharmacy_id: Mapped[str] = mapped_column(String, nullable=False)
    package_id: Mapped[str] = mapped_column(String, nullable=False)
    price_cents: Mapped[int] = mapped_column(Integer, nullable=True)
    currency: Mapped[str] = mapped_column(String(3), nullable=True)
    availability: Mapped[bool] = mapped_column(Boolean, default=True)

    from sqlalchemy import ForeignKey
    pharmacy_id = mapped_column(ForeignKey("pharmacies.id"), nullable=False)
    package_id = mapped_column(ForeignKey("packages.id"), nullable=False)

    # relationships
    pharmacy = relationship("Pharmacy", back_populates="inventories")
    package = relationship("Package", back_populates="inventories")
