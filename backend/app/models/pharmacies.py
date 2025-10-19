# app/models/pharmacies.py
from typing import List
from sqlalchemy import String, func, cast, literal
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy.ext.hybrid import hybrid_method
from app.core.db import Base
from sqlalchemy.types import Float
import math

EARTH_RADIUS_KM = 6371

class Pharmacy(Base):
    __tablename__ = "pharmacies"

    id: Mapped[str] = mapped_column(String, primary_key=True)
    name: Mapped[str] = mapped_column(String, index=True, nullable=False)
    country: Mapped[str] = mapped_column(String(2), nullable=False)  # e.g. "AT"
    city: Mapped[str] = mapped_column(String, nullable=False)
    address: Mapped[str] = mapped_column(String, nullable=True)
    lat: Mapped[str] = mapped_column(String, nullable=True) # TODO: Change to INT type
    lng: Mapped[str] = mapped_column(String, nullable=True)
    phone: Mapped[str] = mapped_column(String, nullable=True)
    opening_hours: Mapped[dict] = mapped_column(JSONB, nullable=True)

    # relationships
    inventories: Mapped[List["PharmacyInventory"]] = relationship("PharmacyInventory", back_populates="pharmacy", cascade="all, delete-orphan")

    @hybrid_method
    def distance_to(self, lat: float, lng: float) -> float:
        """
        Haversine (in km). Returns None if pharmacy lat/lng is null or invalid.
        """
        if self.lat is None or self.lng is None:
            return None
        try:
            plat = float(self.lat)
            plng = float(self.lng)
        except ValueError:
            return None
        dlat = math.radians(plat - lat)
        dlng = math.radians(plng - lng)
        a = math.sin(dlat / 2) ** 2 + \
            math.cos(math.radians(lat)) * math.cos(math.radians(plat)) * \
            math.sin(dlng / 2) ** 2
        c = 2 * math.asin(math.sqrt(a))
        return EARTH_RADIUS_KM * c

    @distance_to.expression
    def distance_to(cls, lat: float, lng: float):
        lat1 = func.radians(literal(lat))
        lng1 = func.radians(literal(lng))
        lat2 = func.radians(cast(cls.lat, Float))
        lng2 = func.radians(cast(cls.lng, Float))
        dlat = lat2 - lat1
        dlng = lng2 - lng1
        a = func.power(func.sin(dlat / 2), 2) + \
            func.cos(lat1) * func.cos(lat2) * func.power(func.sin(dlng / 2), 2)
        c = 2 * func.asin(func.sqrt(a))
        return literal(EARTH_RADIUS_KM) * c
    