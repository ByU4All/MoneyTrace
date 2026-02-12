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
    type: str = Field(..., description="Event type: expense, liability, receivable, settlement_paid, settlement_received, budget_adjustment, transfer, income, credit_card_payment, emi_payment")
    amount: int = Field(..., gt=0, description="Amount in paise (must be positive)")
    category: Optional[str] = Field(None, description="Category (required for expense/liability/receivable)")
    description: Optional[str] = Field(None, description="Optional description")
    friend_id: Optional[str] = Field(None, description="Friend ID (required for liability/receivable/settlement)")
    account_id: Optional[str] = Field(None, description="Account used for this transaction")
    from_account_id: Optional[str] = Field(None, description="Source account (for transfers)")
    to_account_id: Optional[str] = Field(None, description="Destination account (for transfers)")
    event_date: Optional[date] = Field(None, description="Event date (defaults to today)")


class EventResponse(BaseModel):
    """Event in API response."""
    id: str
    type: str
    amount: int
    category: Optional[str]
    description: Optional[str]
    friend_id: Optional[str]
    account_id: Optional[str]
    from_account_id: Optional[str]
    to_account_id: Optional[str]
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
    budget_reset_day: int = 1
    budget_reset_enabled: bool = True
    carry_over_enabled: bool = False
    carry_over_cap: Optional[int] = None
    carry_over_negative: bool = False


class SettingsUpdate(BaseModel):
    """Update settings."""
    base_budget: Optional[int] = Field(None, gt=0, description="Monthly budget in paise")
    budget_reset_day: Optional[int] = Field(None, ge=1, le=28, description="Day of month for budget reset (1-28)")
    budget_reset_enabled: Optional[bool] = Field(None, description="Enable automatic budget reset")
    carry_over_enabled: Optional[bool] = Field(None, description="Enable carry over of unused budget")
    carry_over_cap: Optional[int] = Field(None, ge=0, description="Maximum carry over in paise (0 = unlimited)")
    carry_over_negative: Optional[bool] = Field(None, description="Carry over deficits to next month")


# ---------------------------------------------------------------------------
# Category Schemas
# ---------------------------------------------------------------------------

class CategoryCreate(BaseModel):
    """Create a new category."""
    name: str = Field(..., min_length=1, max_length=50, description="Category name")


class CategoryUpdate(BaseModel):
    """Update a category."""
    name: str = Field(..., min_length=1, max_length=50, description="New category name")


class CategoryResponse(BaseModel):
    """Category in API response."""
    id: str
    name: str
    is_default: bool
    usage_count: Optional[int] = None


class CategoryDeleteRequest(BaseModel):
    """Delete a category with reassignment."""
    reassign_to: str = Field("Other", description="Category name to reassign events to")


# ---------------------------------------------------------------------------
# Data Management Schemas
# ---------------------------------------------------------------------------

class ClearDataRequest(BaseModel):
    """Request to clear all data."""
    confirm: str = Field(..., description="Must be 'DELETE' to confirm")
    keep_friends: bool = Field(True, description="Keep friends list when clearing data")


# ---------------------------------------------------------------------------
# Account Schemas
# ---------------------------------------------------------------------------

class AccountCreate(BaseModel):
    """Create a new account."""
    name: str = Field(..., min_length=1, max_length=50)
    type: str = Field(..., description="Account type: savings, current, cash, credit_card, upi_wallet, debit_card")
    institution: Optional[str] = Field(None, max_length=50)
    last_4_digits: Optional[str] = Field(None, max_length=4)
    color: Optional[str] = Field(None, max_length=20)
    icon: Optional[str] = Field(None, max_length=20)
    tracked_balance: bool = Field(False)
    current_balance: int = Field(0, description="Initial balance in paise")
    credit_limit: Optional[int] = Field(None, ge=0, description="Credit limit in paise (for credit cards)")
    billing_day: Optional[int] = Field(None, ge=1, le=28, description="Statement generation day")
    due_day: Optional[int] = Field(None, ge=1, le=28, description="Payment due day")


class AccountUpdate(BaseModel):
    """Update an account."""
    name: Optional[str] = Field(None, min_length=1, max_length=50)
    institution: Optional[str] = None
    last_4_digits: Optional[str] = None
    color: Optional[str] = None
    icon: Optional[str] = None
    tracked_balance: Optional[bool] = None
    current_balance: Optional[int] = None
    credit_limit: Optional[int] = None
    billing_day: Optional[int] = None
    due_day: Optional[int] = None
    is_active: Optional[bool] = None


class AccountResponse(BaseModel):
    """Account in API response."""
    id: str
    name: str
    type: str
    institution: Optional[str]
    last_4_digits: Optional[str]
    color: Optional[str]
    icon: Optional[str]
    tracked_balance: bool
    current_balance: int
    is_credit: bool
    credit_limit: Optional[int]
    billing_day: Optional[int]
    due_day: Optional[int]
    is_active: bool
    is_default: bool


# ---------------------------------------------------------------------------
# Recurring Transaction Schemas
# ---------------------------------------------------------------------------

class RecurringCreate(BaseModel):
    """Create a recurring transaction."""
    name: str = Field(..., min_length=1, max_length=100)
    type: str = Field(..., description="Transaction type: expense, income, emi_payment")
    amount: int = Field(..., gt=0, description="Amount in paise")
    category: Optional[str] = None
    account_id: Optional[str] = None
    frequency: str = Field(..., description="Frequency: daily, weekly, monthly, yearly")
    day_of_month: Optional[int] = Field(None, ge=1, le=28)
    day_of_week: Optional[int] = Field(None, ge=0, le=6)
    start_date: date
    end_date: Optional[date] = None
    requires_verification: bool = True
    auto_apply: bool = False
    is_autopay: bool = Field(False, description="If true, bank auto-deducts (no manual payment needed)")


class RecurringUpdate(BaseModel):
    """Update a recurring transaction."""
    name: Optional[str] = Field(None, min_length=1, max_length=100)
    amount: Optional[int] = Field(None, gt=0, description="Amount in paise")
    category: Optional[str] = None
    account_id: Optional[str] = None
    frequency: Optional[str] = Field(None, description="Frequency: daily, weekly, monthly, yearly")
    day_of_month: Optional[int] = Field(None, ge=1, le=28)
    day_of_week: Optional[int] = Field(None, ge=0, le=6)
    end_date: Optional[date] = None
    requires_verification: Optional[bool] = None
    auto_apply: Optional[bool] = None
    is_autopay: Optional[bool] = Field(None, description="If true, bank auto-deducts")
    is_active: Optional[bool] = None


class RecurringResponse(BaseModel):
    """Recurring transaction in API response."""
    id: str
    name: str
    type: str
    amount: int
    category: Optional[str]
    account_id: Optional[str]
    frequency: str
    day_of_month: Optional[int]
    day_of_week: Optional[int]
    start_date: str
    end_date: Optional[str]
    requires_verification: bool
    auto_apply: bool
    is_autopay: bool
    is_active: bool
    last_applied_date: Optional[str]
    next_due_date: Optional[str]
    linked_loan_id: Optional[str]


class UpcomingBillResponse(BaseModel):
    """Upcoming bill for display."""
    id: str
    name: str
    type: str
    amount: int
    category: Optional[str]
    next_due_date: str
    due_date_formatted: str
    days_until_due: int
    is_overdue: bool
    is_autopay: bool
    is_paid_this_cycle: bool


class PendingTransactionResponse(BaseModel):
    """Pending transaction awaiting verification."""
    id: str
    recurring_id: str
    name: str
    type: str
    amount: int
    category: Optional[str]
    account_id: Optional[str]
    due_date: str
    status: str


# ---------------------------------------------------------------------------
# Loan Schemas
# ---------------------------------------------------------------------------

class LoanCreate(BaseModel):
    """Create a new loan."""
    name: str = Field(..., min_length=1, max_length=100)
    type: str = Field(..., description="Loan type: home_loan, car_loan, personal_loan, credit_card_emi, bnpl, other")
    principal: int = Field(..., gt=0, description="Principal amount in paise")
    interest_rate: float = Field(..., ge=0, description="Annual interest rate %")
    tenure_months: int = Field(..., gt=0, description="Tenure in months")
    emi_amount: int = Field(..., gt=0, description="Monthly EMI in paise")
    start_date: date
    emi_day: int = Field(..., ge=1, le=28, description="EMI due day of month")
    payment_account_id: Optional[str] = None
    payment_type: str = Field("manual", description="Payment type: manual, auto_debit, credit_card")
    credit_card_id: Optional[str] = None
    lender: Optional[str] = None
    purpose: Optional[str] = None


class LoanUpdate(BaseModel):
    """Update a loan."""
    name: Optional[str] = Field(None, min_length=1, max_length=100)
    emi_amount: Optional[int] = Field(None, gt=0, description="Monthly EMI in paise")
    emi_day: Optional[int] = Field(None, ge=1, le=28, description="EMI due day of month")
    payment_account_id: Optional[str] = None
    payment_type: Optional[str] = Field(None, description="Payment type: manual, auto_debit, credit_card")
    credit_card_id: Optional[str] = None
    lender: Optional[str] = None
    purpose: Optional[str] = None
    is_active: Optional[bool] = None


class LoanResponse(BaseModel):
    """Loan in API response."""
    id: str
    name: str
    type: str
    principal: int
    interest_rate: float
    tenure_months: int
    emi_amount: int
    start_date: str
    emi_day: int
    payments_made: int
    payments_remaining: int
    payment_account_id: Optional[str]
    payment_type: str
    credit_card_id: Optional[str]
    lender: Optional[str]
    purpose: Optional[str]
    is_active: bool
    total_paid: int
    outstanding: int


# ---------------------------------------------------------------------------
# Credit Card Statement Schemas
# ---------------------------------------------------------------------------

class CreditCardStatementCreate(BaseModel):
    """Create a credit card statement."""
    card_account_id: str
    statement_date: date
    due_date: date
    statement_amount: int = Field(..., gt=0)
    minimum_due: int = Field(..., gt=0)


class CreditCardStatementResponse(BaseModel):
    """Credit card statement in API response."""
    id: str
    card_account_id: str
    card_name: Optional[str]
    statement_date: str
    due_date: str
    statement_amount: int
    minimum_due: int
    paid_amount: int
    remaining: int
    is_fully_paid: bool
    days_until_due: Optional[int]
    is_overdue: bool


class CreditCardPaymentRequest(BaseModel):
    """Pay credit card bill."""
    statement_id: str
    amount: int = Field(..., gt=0)
    from_account_id: str


# ---------------------------------------------------------------------------
# Transfer Schema
# ---------------------------------------------------------------------------

class TransferCreate(BaseModel):
    """Create a transfer between accounts."""
    amount: int = Field(..., gt=0, description="Amount in paise")
    from_account_id: str
    to_account_id: str
    description: Optional[str] = None
    event_date: Optional[date] = None


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
    accounts: List[dict]
    recurring_transactions: List[dict]
    loans: List[dict]

