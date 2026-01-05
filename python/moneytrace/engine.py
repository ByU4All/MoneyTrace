# engine.py
"""
Ledger engine — source of truth for all financial calculations.

RULES (NON-NEGOTIABLE):
- All amounts are integers in minor units (paise / cents)
- Budget impact happens exactly once
- Engine is currency-agnostic
- Engine is pure: no DB, no IO, no formatting
"""


from collections import defaultdict
from typing import Iterable
from datetime import date, datetime


# Event types constants
EXPENSE = "expense"
LIABILITY_CREATED = "liability_created"
RECEIVABLE_CREATED = "receivable_created"
PAYBACK_PAID = "payback_paid"
PAYBACK_RECEIVED = "payback_received"
BUDGET_ADJUSTMENT = "budget_adjustment"


# ---------------------------------------------------------------------------
# Core Budget Computation
# ---------------------------------------------------------------------------

def compute_available_budget(
        base_budget_minor: int,
        events: Iterable[dict],
) -> int:
    """
    Computes remaining available budget.

    Formula : 
        base_budget
      + budget_adjustments
      - expenses
      - outstanding liabilities
      + received settlements
    """
    budget = base_budget_minor

    for e in events:
        etype = e["type"]
        amount = e["amount"]

        if etype == EXPENSE:
            budget -= amount

        elif etype == LIABILITY_CREATED:
            budget -= amount
        
        elif etype == PAYBACK_RECEIVED:
            budget += amount

        elif etype == BUDGET_ADJUSTMENT:
            budget += amount
        
        # RECEIVABLE_CREATED -> no budget impact
        # PAYBACK_PAID -> already accounted in LIABILITY_CREATED
    
    return budget


# ---------------------------------------------------------------------------
# Monthly Spend (Cash Out Only)
# ---------------------------------------------------------------------------

def compute_monthly_spend(
        events: Iterable[dict],
        month: int,
        year: int,
) -> int:
    """
    Cash that actually left your wallet in a month.

    Includes:
    - Expenses
    - Paybacks you made

    Excludes:
    - Liabilities
    - Receivables
    """

    spend = 0

    for e in events:
        d: date = e["event_date"]
        if d.month != month or d.year != year:
            continue

        if e["type"] in (EXPENSE, PAYBACK_PAID):
            spend += e["amount"]

    return spend


# ---------------------------------------------------------------------------
# Outstanding Liabilities
# ---------------------------------------------------------------------------


def compute_outstanding_liabilities(
        events: Iterable[dict],
) -> int:
    """
    Total amount you owe to others.
    """

    total = 0

    for e in events:
        if e["type"] == LIABILITY_CREATED:
            total += e["amount"]
        elif e["type"] == PAYBACK_PAID:
            total -= e["amount"]

    return max(total, 0)


# ---------------------------------------------------------------------------
# Outstanding Receivables
# ---------------------------------------------------------------------------


def compute_outstanding_receivables(events: Iterable[dict]) -> int:
    """
    Total amount others owe you.
    """

    total = 0

    for e in events:
        if e["type"] == RECEIVABLE_CREATED:
            total += e["amount"]
        elif e["type"] == PAYBACK_RECEIVED:
            total -= e["amount"]

    return max(total, 0)



# ---------------------------------------------------------------------------
# Per-Friend Balances
# ---------------------------------------------------------------------------

def compute_friend_balances(events: Iterable[dict]) -> dict[str, int]:
    """
    Net balance per friend.

    Positive  -> friend owes you
    Negative  -> you owe friend
    """

    balances: dict[str, int] = defaultdict(int)

    for e in events:
        friend = e.get("friend")
        if not friend:
            continue

        amt = e["amount"]
        etype = e["type"]

        if etype == RECEIVABLE_CREATED:
            balances[friend] += amt

        elif etype == LIABILITY_CREATED:
            balances[friend] -= amt

        elif etype == PAYBACK_RECEIVED:
            balances[friend] -= amt

        elif etype == PAYBACK_PAID:
            balances[friend] += amt

    return dict(balances)



# ---------------------------------------------------------------------------
# Category-wise Spend
# ---------------------------------------------------------------------------

def compute_category_spend(
    events: Iterable[dict],
    month: int | None = None,
    year: int | None = None,
) -> dict[str, int]:
    """
    Category-wise cash spend.

    Only EXPENSE events count.
    """

    totals: dict[str, int] = defaultdict(int)

    for e in events:
        if e["type"] != EXPENSE:
            continue

        d: date = e["event_date"]
        if month and year:
            if d.month != month or d.year != year:
                continue

        category = e.get("category", "uncategorized")
        totals[category] += e["amount"]

    return dict(totals)


# ---------------------------------------------------------------------------
# Invariant Checks (Debug / Tests)
# ---------------------------------------------------------------------------

def validate_invariants(events: Iterable[dict]) -> None:
    """
    Raises AssertionError if ledger invariants are violated.
    """

    for e in events:
        assert e["amount"] >= 0, "Amount must be positive minor units"
        assert isinstance(e["amount"], int), "Amount must be int"
        assert e["type"] in {
            EXPENSE,
            LIABILITY_CREATED,
            RECEIVABLE_CREATED,
            PAYBACK_PAID,
            PAYBACK_RECEIVED,
            BUDGET_ADJUSTMENT,
        }, f"Unknown event type: {e['type']}"

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
def events_for_budget_month(events, month, year):
    """
    Include:
    - all liabilities / receivables (carry forward)
    - only expenses & settlements from the given month
    """
    filtered = []

    for e in events:
        etype = e["type"]
        d = e["event_date"]

        if etype in ("liability_created", "receivable_created"):
            filtered.append(e)
        else:
            if d.month == month and d.year == year:
                filtered.append(e)

    return filtered
