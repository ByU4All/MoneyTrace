"""
Pydantic schemas for API request/response validation.

Clean separation between API contracts and internal models.
"""

from datetime import date
from typing import Optional, List
from pydantic import BaseModel, Field

from ..core.events import EventType


# ---------------------------------------------------------------------------
# Event Schemas
# ---------------------------------------------------------------------------

class EventCreate(BaseModel):
    """Create a new event."""
    type: str = Field(..., description="Event type: expense, liability, receivable, settlement_paid, settlement_received, budget_adjustment")
    amount: int = Field(..., gt=0, description="Amount in paise (must be positive)")
    category: Optional[str] = Field(None, description="Category (required for expense/liability/receivable)")
    description: Optional[str] = Field(None, description="Optional description")
    friend_id: Optional[str] = Field(None, description="Friend ID (required for liability/receivable/settlement)")
    event_date: Optional[date] = Field(None, description="Event date (defaults to today)")


class EventResponse(BaseModel):
    """Event in API response."""
    id: str
    type: str
    amount: int
    category: Optional[str]
    description: Optional[str]
    friend_id: Optional[str]
    event_date: date


# ---------------------------------------------------------------------------
# Friend Schemas
# ---------------------------------------------------------------------------

class FriendCreate(BaseModel):
    """Create a new friend."""
    name: str = Field(..., min_length=1, description="Friend's name")
    phone: Optional[str] = Field(None, description="Optional phone number")


class FriendResponse(BaseModel):
    """Friend in API response."""
    id: str
    name: str
    phone: Optional[str]


class FriendWithBalance(BaseModel):
    """Friend with computed balance."""
    id: str
    name: str
    phone: Optional[str]
    balance: int  # Positive = owes you, Negative = you owe them


# ---------------------------------------------------------------------------
# Summary Schemas
# ---------------------------------------------------------------------------

class SummaryResponse(BaseModel):
    """Monthly financial summary."""
    month: int
    year: int
    base_budget: int
    budget_remaining: int
    monthly_spend: int
    outstanding_liabilities: int
    outstanding_receivables: int


class CategorySpend(BaseModel):
    """Spending per category."""
    category: str
    amount: int


# ---------------------------------------------------------------------------
# Settings Schemas
# ---------------------------------------------------------------------------

class SettingsResponse(BaseModel):
    """Application settings."""
    base_budget: int
    currency_symbol: str = "₹"


class SettingsUpdate(BaseModel):
    """Update settings."""
    base_budget: Optional[int] = Field(None, gt=0, description="Monthly budget in paise")


# ---------------------------------------------------------------------------
# Export/Import Schemas
# ---------------------------------------------------------------------------

class ExportResponse(BaseModel):
    """Data export response."""
    version: str
    exported_at: str
    settings: dict
    categories: List[dict]
    friends: List[dict]
    events: List[dict]

