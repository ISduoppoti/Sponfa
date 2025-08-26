from app.core.db import Base
from sqlalchemy import String
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import Mapped, mapped_column


class Pharmacy(Base):
    __tablename__ = "pharmacies"
    id: Mapped[str] = mapped_column(String, primary_key=True)  # UUID text
    name: Mapped[str] = mapped_column(String, index=True)
    address: Mapped[str] = mapped_column(String)
    lat: Mapped[str] = mapped_column(String)
    lng: Mapped[str] = mapped_column(String)
    phone: Mapped[str] = mapped_column(String)
    opening_hours: Mapped[dict] = mapped_column(JSONB)
