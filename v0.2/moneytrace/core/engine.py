"""
Ledger engine — source of truth for all financial calculations.

RULES (from idea.md - NON-NEGOTIABLE):
- All amounts are integers in minor units (paise)
- Budget impact happens exactly once
- Engine is pure: no DB, no IO, no formatting
- Settlements never double-count budget
- Receivables excluded from budget by default
"""

from collections import defaultdict
from datetime import date
from typing import Iterable

from .events import EventType


# ---------------------------------------------------------------------------
# Core Budget Computation
# ---------------------------------------------------------------------------

def compute_available_budget(
    base_budget: int,
    events: Iterable[dict],
) -> int:
    """
    Compute remaining available budget.

    Formula (from idea.md):
        Available Budget = Base Monthly Budget
                         + Sum(BudgetAdjustments)
                         - Sum(Cash Expenses)
                         - Sum(Outstanding Liabilities)

    Args:
        base_budget: Monthly budget in minor units (paise)
        events: List of event dicts with 'type' and 'amount'

    Returns:
        Available budget in minor units
    """
    budget = base_budget

    for e in events:
        etype = e["type"]
        amount = e["amount"]

        if etype == EventType.EXPENSE:
            # Money spent -> budget down
            budget -= amount

        elif etype == EventType.LIABILITY:
            # Money reserved -> budget down
            budget -= amount

        elif etype == EventType.SETTLEMENT_RECEIVED:
            # Payment received -> budget relief
            budget += amount

        elif etype == EventType.BUDGET_ADJUSTMENT:
            # Extra money -> budget up
            budget += amount

        # RECEIVABLE -> no budget impact (informational)
        # SETTLEMENT_PAID -> no budget impact (already counted in LIABILITY)

    return budget


# ---------------------------------------------------------------------------
# Monthly Cash Spend
# ---------------------------------------------------------------------------

def compute_monthly_spend(
    events: Iterable[dict],
    month: int,
    year: int,
) -> int:
    """
    Cash that actually left your wallet in a month.

    Includes:
        - Expenses (direct spending)
        - Settlement paid (paying back liabilities)

    Excludes:
        - Liabilities (no cash out yet)
        - Receivables (no cash movement)
    """
    spend = 0

    for e in events:
        d: date = e["event_date"]
        if d.month != month or d.year != year:
            continue

        if e["type"] in (EventType.EXPENSE, EventType.SETTLEMENT_PAID):
            spend += e["amount"]

    return spend


# ---------------------------------------------------------------------------
# Outstanding Balances
# ---------------------------------------------------------------------------

def compute_outstanding_liabilities(events: Iterable[dict]) -> int:
    """
    Total amount you owe to others.

    LIABILITY creates debt, SETTLEMENT_PAID clears it.
    """
    total = 0

    for e in events:
        if e["type"] == EventType.LIABILITY:
            total += e["amount"]
        elif e["type"] == EventType.SETTLEMENT_PAID:
            total -= e["amount"]

    return max(total, 0)


def compute_outstanding_receivables(events: Iterable[dict]) -> int:
    """
    Total amount others owe you.

    RECEIVABLE creates credit, SETTLEMENT_RECEIVED clears it.
    """
    total = 0

    for e in events:
        if e["type"] == EventType.RECEIVABLE:
            total += e["amount"]
        elif e["type"] == EventType.SETTLEMENT_RECEIVED:
            total -= e["amount"]

    return max(total, 0)


# ---------------------------------------------------------------------------
# Friend Balances
# ---------------------------------------------------------------------------

def compute_friend_balances(events: Iterable[dict]) -> dict[str, int]:
    """
    Net balance per friend.

    Positive  -> friend owes you
    Negative  -> you owe friend
    """
    balances: dict[str, int] = defaultdict(int)

    for e in events:
        friend_id = e.get("friend_id")
        if not friend_id:
            continue

        amount = e["amount"]
        etype = e["type"]

        if etype == EventType.RECEIVABLE:
            # Friend owes you
            balances[friend_id] += amount

        elif etype == EventType.LIABILITY:
            # You owe friend
            balances[friend_id] -= amount

        elif etype == EventType.SETTLEMENT_RECEIVED:
            # Friend paid you back
            balances[friend_id] -= amount

        elif etype == EventType.SETTLEMENT_PAID:
            # You paid friend back
            balances[friend_id] += amount

    return dict(balances)


# ---------------------------------------------------------------------------
# Category Spending
# ---------------------------------------------------------------------------

def compute_category_spend(
    events: Iterable[dict],
    month: int | None = None,
    year: int | None = None,
) -> dict[str, int]:
    """
    Category-wise spending.

    Only EXPENSE events count (from idea.md: Settlement has NO category).
    """
    totals: dict[str, int] = defaultdict(int)

    for e in events:
        if e["type"] != EventType.EXPENSE:
            continue

        # Filter by month/year if specified
        if month and year:
            d: date = e["event_date"]
            if d.month != month or d.year != year:
                continue

        category = e.get("category") or "Uncategorized"
        totals[category] += e["amount"]

    return dict(totals)

