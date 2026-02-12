# api/schemas.py
"""
Pydantic schemas for API request/response validation.

These are separate from internal models to allow API evolution
without affecting core logic.
"""

from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import date, datetime
from enum import Enum


class EventType(str, Enum):
    """Valid event types."""
    EXPENSE = "expense"
    LIABILITY_CREATED = "liability_created"
    RECEIVABLE_CREATED = "receivable_created"
    PAYBACK_PAID = "payback_paid"
    PAYBACK_RECEIVED = "payback_received"
    BUDGET_ADJUSTMENT = "budget_adjustment"


# ---------------------------------------------------------------------------
# Event Schemas
# ---------------------------------------------------------------------------

class EventCreate(BaseModel):
    """Schema for creating a new event."""
    event_type: str = Field(..., description="Event type from engine.EventType")
    amount: int = Field(..., description="Amount in minor units (paise/cents)")
    category: str
    note: Optional[str] = None
    friend_id: Optional[str] = None
    parent_event_id: Optional[str] = None


class EventResponse(BaseModel):
    """Schema for event in API responses."""
    id: str
    timestamp: date
    event_type: str
    amount: int
    category: Optional[str]
    note: Optional[str]
    friend_id: Optional[str]
    parent_event_id: Optional[str]


# ---------------------------------------------------------------------------
# Friend Schemas
# ---------------------------------------------------------------------------

class FriendCreate(BaseModel):
    """Schema for creating a new friend."""
    name: str = Field(..., min_length=1)


class FriendUpdate(BaseModel):
    """Schema for updating an existing friend."""
    name: str = Field(..., min_length=1)


class FriendResponse(BaseModel):
    """Schema for friend in API responses."""
    id: str
    name: str


class FriendBalance(BaseModel):
    """Schema for friend balance information."""
    friend_id: int
    friend_name: str
    net_balance: int
    description: str


# ---------------------------------------------------------------------------
# View Schemas
# ---------------------------------------------------------------------------

class SummaryResponse(BaseModel):
    """Monthly summary response."""
    month: int
    year: int
    monthly_spend: int  # Cash that left wallet
    budget_remaining: int  # Available budget
    outstanding_liabilities: int  # What you owe
    outstanding_receivables: int  # What's owed to you


class CategorySpendResponse(BaseModel):
    """Category spending response."""
    category: str
    amount: int


class FriendBalanceResponse(BaseModel):
    """Friend balance response."""
    friend_id: str
    balance: int  # Positive = friend owes you, Negative = you owe friend


class BudgetSummary(BaseModel):
    """Schema for budget summary."""
    total_income: int
    total_expenses: int
    owed_to_others: int
    owed_to_me: int
    net_budget_impact: int


class CategorySummary(BaseModel):
    """Schema for category summary."""
    category: str
    total_amount: int
    event_count: int


class FriendDetail(BaseModel):
    """Detailed friend information including events."""
    friend: FriendResponse
    balance: int
    events: List[EventResponse]

