# friends.py
from pydantic import BaseModel, Field
from uuid import UUID, uuid4
from typing import Optional

class Friend(BaseModel):
    id: UUID = Field(default_factory=uuid4)
    name: str
    phone: Optional[str] = None  # E.164 preferred, but not enforced
    is_contact: bool = False     # True if mapped to phone contacts
