from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from sqlalchemy.orm import selectinload

from app.database import get_db
from app.models import Package, Product, Brand, PharmacyInventory, Pharmacy
from app.schemas import PackageDetailModel  # <-- you'll need to define this

router = APIRouter(prefix="/packages", tags=["packages"])
