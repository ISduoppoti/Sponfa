# app/models/pharmacies.py
from typing import List
from sqlalchemy import String
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.core.db import Base


class Pharmacy(Base):
    __tablename__ = "pharmacies"

    id: Mapped[str] = mapped_column(String, primary_key=True)
    name: Mapped[str] = mapped_column(String, index=True, nullable=False)
    address: Mapped[str] = mapped_column(String, nullable=True)
    lat: Mapped[str] = mapped_column(String, nullable=True)
    lng: Mapped[str] = mapped_column(String, nullable=True)
    phone: Mapped[str] = mapped_column(String, nullable=True)
    opening_hours: Mapped[dict] = mapped_column(JSONB, nullable=True)

    # relationships
    inventories: Mapped[List["PharmacyInventory"]] = relationship("PharmacyInventory", back_populates="pharmacy", cascade="all, delete-orphan")
