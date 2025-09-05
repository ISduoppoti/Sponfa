# app/models/translation.py
from sqlalchemy import String
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.core.db import Base


class Translation(Base):
    __tablename__ = "translations"

    id: Mapped[str] = mapped_column(String, primary_key=True)
    product_id: Mapped[str] = mapped_column(String, nullable=False)
    language_code: Mapped[str] = mapped_column(String(5), nullable=False)  # "de", "it", "fr", "en"
    translated_name: Mapped[str] = mapped_column(String, nullable=False)
    translated_description: Mapped[str] = mapped_column(String, nullable=True)

    from sqlalchemy import ForeignKey
    product_id = mapped_column(ForeignKey("products.id"), nullable=False)

    # relationships
    product = relationship("Product", back_populates="translations")