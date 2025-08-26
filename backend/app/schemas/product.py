from pydantic import BaseModel


class ProductOut(BaseModel):
    id: str
    name: str
    form: str
    strength: str
    gtin: str
    price_cents: int | None = None
    currency: str | None = None
    pharmacy_id: str | None = None
