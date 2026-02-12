"""
Event types - the financial primitives from idea.md

This is the SINGLE source of truth for event types.
All other modules import from here.
"""

from enum import Enum


class EventType(str, Enum):
    """
    Financial event types.

    From idea.md Financial Event Impact Matrix:

    | Event                 | Budget Impact | Cash Impact |
    | --------------------- | ------------- | ----------- |
    | Expense               | −ve           | −ve         |
    | Liability created     | −ve           | 0           |
    | Receivable created    | 0             | 0           |
    | Payback (you pay)     | 0             | −ve         |
    | Payback (you receive) | +ve           | +ve         |
    | Budget adjustment     | +ve           | 0           |
    | Transfer              | 0             | 0           |
    | Income                | +ve           | +ve         |
    | Credit Card Payment   | 0             | −ve         |
    | EMI Payment           | −ve           | −ve         |
    """

    # Money actually spent
    EXPENSE = "expense"

    # Money you owe (budget reserved, no cash yet)
    LIABILITY = "liability"

    # Money owed to you (informational only)
    RECEIVABLE = "receivable"

    # You pay back a liability (cash out, budget unchanged)
    SETTLEMENT_PAID = "settlement_paid"

    # You receive payment for receivable (cash in, budget relief)
    SETTLEMENT_RECEIVED = "settlement_received"

    # Extra money available (gift, refund, etc.)
    BUDGET_ADJUSTMENT = "budget_adjustment"

    # Transfer between accounts (no budget impact)
    TRANSFER = "transfer"

    # Income (salary, rental, etc.)
    INCOME = "income"

    # Credit card bill payment
    CREDIT_CARD_PAYMENT = "credit_card_payment"

    # EMI payment for loans
    EMI_PAYMENT = "emi_payment"


class AccountType(str, Enum):
    """Types of accounts that can be tracked."""

    SAVINGS = "savings"
    CURRENT = "current"
    CASH = "cash"
    CREDIT_CARD = "credit_card"
    UPI_WALLET = "upi_wallet"
    DEBIT_CARD = "debit_card"


class RecurringFrequency(str, Enum):
    """Frequency options for recurring transactions."""

    DAILY = "daily"
    WEEKLY = "weekly"
    MONTHLY = "monthly"
    YEARLY = "yearly"


class LoanType(str, Enum):
    """Types of loans/EMIs."""

    HOME_LOAN = "home_loan"
    CAR_LOAN = "car_loan"
    PERSONAL_LOAN = "personal_loan"
    CREDIT_CARD_EMI = "credit_card_emi"
    BNPL = "bnpl"  # Buy Now Pay Later
    OTHER = "other"


class AuditAction(str, Enum):
    """Types of audit trail actions for tracking all changes."""

    # Entity CRUD operations
    CREATE = "create"
    UPDATE = "update"
    DELETE = "delete"

    # Special actions
    CLOSE = "close"  # For loans - closed but record kept
    UNLINK = "unlink"  # For soft deletes - record kept but unlinked


class EntityType(str, Enum):
    """Types of entities that can be audited."""

    EVENT = "event"
    FRIEND = "friend"
    ACCOUNT = "account"
    LOAN = "loan"
    RECURRING = "recurring"
    CATEGORY = "category"
    SETTINGS = "settings"
