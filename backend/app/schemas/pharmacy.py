from pydantic import BaseModel
from typing import List, Optional


class PharmacyBase(BaseModel):
    name: str
    address: str
    city: str
    country: str


class PharmacyCreate(PharmacyBase):
    pass


class PharmacyUpdate(PharmacyBase):
    pass


class PharmacyOut(PharmacyBase):
    id: str

    class Config:
        from_attributes = True


class PharmacyInventoryBase(BaseModel):
    pharmacy_id: str
    package_id: str
    price: int
    stock: int


class PharmacyInventoryCreate(PharmacyInventoryBase):
    pass


class PharmacyInventoryUpdate(PharmacyInventoryBase):
    pass


class PharmacyInventoryOut(PharmacyInventoryBase):
    id: str

    class Config:
        from_attributes = True
