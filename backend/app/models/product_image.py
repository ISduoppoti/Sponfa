# app/models/product_image.py
from sqlalchemy import String, Boolean
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.core.db import Base


class ProductImage(Base):
    __tablename__ = "product_images"

    id: Mapped[str] = mapped_column(String, primary_key=True)
    package_id: Mapped[str] = mapped_column(String, nullable=False)
    image_url: Mapped[str] = mapped_column(String, nullable=False)  # point to S3/CDN
    is_primary: Mapped[bool] = mapped_column(Boolean, default=False)

    from sqlalchemy import ForeignKey
    package_id = mapped_column(ForeignKey("packages.id"), nullable=False)

    # relationships
    package = relationship("Package", back_populates="images")
