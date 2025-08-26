from app.core.db import Base
from sqlalchemy import String
from sqlalchemy.orm import Mapped, mapped_column


class Product(Base):
    __tablename__ = "products"
    id: Mapped[str] = mapped_column(String, primary_key=True)  # UUID text
    name: Mapped[str] = mapped_column(String, index=True)
    form: Mapped[str] = mapped_column(String)
    strength: Mapped[str] = mapped_column(String)
    gtin: Mapped[str] = mapped_column(String, index=True)
    price_cents: Mapped[str] = mapped_column(String)
    currency: Mapped[str] = mapped_column(String)
    pharmacy_id: Mapped[str] = mapped_column(String)
