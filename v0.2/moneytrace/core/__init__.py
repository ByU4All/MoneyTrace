"""
Core module - pure business logic with no I/O.
"""

from .events import EventType
from .engine import (
    compute_available_budget,
    compute_monthly_spend,
    compute_outstanding_liabilities,
    compute_outstanding_receivables,
    compute_friend_balances,
    compute_category_spend,
)

__all__ = [
    "EventType",
    "compute_available_budget",
    "compute_monthly_spend",
    "compute_outstanding_liabilities",
    "compute_outstanding_receivables",
    "compute_friend_balances",
    "compute_category_spend",
]

