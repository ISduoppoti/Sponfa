from pydantic import BaseModel
from typing import Optional


class PackageBase(BaseModel):
    size: str
    unit: str
    product_id: str


class PackageCreate(PackageBase):
    pass


class PackageUpdate(PackageBase):
    pass


class PackageOut(PackageBase):
    id: str

    class Config:
        from_attributes = True
