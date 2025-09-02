from pydantic import BaseModel
from typing import Optional


class TranslationBase(BaseModel):
    product_id: str
    language_code: str  # e.g., "de", "sk"
    name: Optional[str] = None
    description: Optional[str] = None


class TranslationCreate(TranslationBase):
    pass


class TranslationUpdate(TranslationBase):
    pass


class TranslationOut(TranslationBase):
    id: str

    class Config:
        from_attributes = True
