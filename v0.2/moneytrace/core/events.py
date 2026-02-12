"""
Event types - the four financial primitives from idea.md

This is the SINGLE source of truth for event types.
All other modules import from here.
"""

from enum import Enum


class EventType(str, Enum):
    """
    The four financial primitives + budget adjustment.

    From idea.md Financial Event Impact Matrix:

    | Event                 | Budget Impact | Cash Impact |
    | --------------------- | ------------- | ----------- |
    | Expense               | −ve           | −ve         |
    | Liability created     | −ve           | 0           |
    | Receivable created    | 0             | 0           |
    | Payback (you pay)     | 0             | −ve         |
    | Payback (you receive) | +ve           | +ve         |
    | Budget adjustment     | +ve           | 0           |
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

