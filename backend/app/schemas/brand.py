from pydantic import BaseModel
from typing import Optional


class BrandBase(BaseModel):
    name: str
    description: Optional[str] = None


class BrandCreate(BrandBase):
    pass


class BrandUpdate(BrandBase):
    pass


class BrandOut(BrandBase):
    id: str

    class Config:
        from_attributes = True
