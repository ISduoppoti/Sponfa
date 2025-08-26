from fastapi import APIRouter, Depends
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from ..core.db import get_db
from ..models.product import Product
from ..schemas.product import ProductOut

router = APIRouter(prefix="/products", tags=["products"])


@router.get("/search", response_model=list[ProductOut])
async def search_products(q: str, limit: int = 20, db: AsyncSession = Depends(get_db)):
    # MVP: simple name ILIKE; later replace with Algolia/Elastic
    stmt = select(Product).where(Product.name.ilike(f"%{q}%")).limit(limit)
    rows = (await db.execute(stmt)).scalars().all()
    return [
        ProductOut(id=r.id, name=r.name, form=r.form, strength=r.strength, gtin=r.gtin)
        for r in rows
    ]
