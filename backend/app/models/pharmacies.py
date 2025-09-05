# app/models/pharmacies.py
from typing import List
from sqlalchemy import String, func, cast, Float
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy.ext.hybrid import hybrid_method
from app.core.db import Base


class Pharmacy(Base):
    __tablename__ = "pharmacies"

    id: Mapped[str] = mapped_column(String, primary_key=True)
    name: Mapped[str] = mapped_column(String, index=True, nullable=False)
    country: Mapped[str] = mapped_column(String(2), nullable=False)  # e.g. "AT"
    city: Mapped[str] = mapped_column(String, nullable=False)
    address: Mapped[str] = mapped_column(String, nullable=True)
    lat: Mapped[str] = mapped_column(String, nullable=True)
    lng: Mapped[str] = mapped_column(String, nullable=True)
    phone: Mapped[str] = mapped_column(String, nullable=True)
    opening_hours: Mapped[dict] = mapped_column(JSONB, nullable=True)

    # relationships
    inventories: Mapped[List["PharmacyInventory"]] = relationship("PharmacyInventory", back_populates="pharmacy", cascade="all, delete-orphan")

    @hybrid_method
    def distance_to(self, lat: float, lng: float):
        """
        Returns the distance (in km) between this pharmacy and a given point.
        """
        # Explicitly cast lat and lng to Float
        lat_f = cast(self.lat, Float)
        lng_f = cast(self.lng, Float)

        return 6371 * func.acos(
            func.cos(func.radians(lat)) *
            func.cos(func.radians(lat_f)) *
            func.cos(func.radians(lng_f) - func.radians(lng)) +
            func.sin(func.radians(lat)) *
            func.sin(func.radians(lat_f))
        )