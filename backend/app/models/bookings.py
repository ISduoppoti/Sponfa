from app.core.db import Base
from sqlalchemy import String
from sqlalchemy.orm import Mapped, mapped_column


class Booking(Base):
    __tablename__ = "bookings"
    id: Mapped[str] = mapped_column(String, primary_key=True)
    user_uid: Mapped[str] = mapped_column(String, index=True)
    pharmacy_id: Mapped[str] = mapped_column(String)
    product_id: Mapped[str] = mapped_column(String)
    qty: Mapped[str] = mapped_column(String)
    price_cents_at_booking: Mapped[str] = mapped_column(String)
    status: Mapped[str] = mapped_column(String)
    expires_at: Mapped[str] = mapped_column(String)
    created_at: Mapped[str] = mapped_column(String)
