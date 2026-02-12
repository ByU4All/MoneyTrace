from pydantic import BaseModel, Field
from typing import Optional
from uuid import UUID, uuid4
from datetime import date


class Event(BaseModel):
    id: UUID = Field(default_factory=uuid4)
    type: str
    amount : int  # amount in minor units (paise)
    currency: str = "INR"  # currency code like "INR", "USD"
    category: str | None = None
    friend : str | None = None
    description : str | None = None
    even_date : date
    created_at: date = Field(default_factory=date.today)
    updated_at: date = Field(default_factory=date.today)
    
