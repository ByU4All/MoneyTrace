"""
Budget reset and carry over logic.

Handles monthly budget cycling with optional carry over calculations.
"""

from datetime import date
from typing import Optional

from .events import EventType


def should_reset_budget(
    today: date,
    reset_day: int,
    last_reset_date: Optional[date],
    reset_enabled: bool = True,
) -> bool:
    """
    Check if budget should be reset.

    Args:
        today: Current date
        reset_day: Day of month for reset (1-28)
        last_reset_date: Date of last reset (None if never reset)
        reset_enabled: Whether auto-reset is enabled

    Returns:
        True if reset should happen
    """
    if not reset_enabled:
        return False

    # If never reset, check if we're past reset day this month
    if last_reset_date is None:
        return today.day >= reset_day

    # Calculate the expected reset date for current period
    # If today is before reset_day, the last reset should be from previous month
    if today.day >= reset_day:
        # Reset should have happened this month on reset_day
        expected_reset_year = today.year
        expected_reset_month = today.month
    else:
        # Reset should have happened last month
        if today.month == 1:
            expected_reset_year = today.year - 1
            expected_reset_month = 12
        else:
            expected_reset_year = today.year
            expected_reset_month = today.month - 1

    expected_reset = date(expected_reset_year, expected_reset_month, reset_day)

    # Need reset if last reset is before the expected reset date
    return last_reset_date < expected_reset


def calculate_carry_over(
    ending_balance: int,
    carry_over_enabled: bool,
    carry_over_cap: Optional[int] = None,
    carry_over_negative: bool = False,
) -> int:
    """
    Calculate carry over amount from previous month.

    Args:
        ending_balance: Ending balance from previous month (can be negative)
        carry_over_enabled: Whether carry over is enabled
        carry_over_cap: Maximum carry over (None = unlimited)
        carry_over_negative: Whether to carry negative balances (deficits)

    Returns:
        Amount to carry over (positive, negative, or zero)
    """
    if not carry_over_enabled:
        return 0

    # Handle negative balance
    if ending_balance < 0:
        if carry_over_negative:
            return ending_balance  # Carry the deficit
        else:
            return 0  # Don't carry negative

    # Handle positive balance
    if carry_over_cap is not None and ending_balance > carry_over_cap:
        return carry_over_cap

    return ending_balance


def calculate_month_spend(events: list[dict], year: int, month: int) -> int:
    """
    Calculate total spending for a specific month.

    Includes expenses and settlement_paid events.
    """
    total = 0
    for e in events:
        event_date: date = e["event_date"]
        if event_date.year == year and event_date.month == month:
            if e["type"] in (EventType.EXPENSE, EventType.SETTLEMENT_PAID):
                total += e["amount"]
    return total


def get_budget_period(today: date, reset_day: int) -> tuple[int, int]:
    """
    Get the budget period (year, month) for a given date.

    If reset_day is 15 and today is Jan 10, the budget period is December.
    If reset_day is 15 and today is Jan 20, the budget period is January.

    Args:
        today: Current date
        reset_day: Day of month when budget resets

    Returns:
        (year, month) tuple for the current budget period
    """
    if today.day >= reset_day:
        return today.year, today.month
    else:
        if today.month == 1:
            return today.year - 1, 12
        else:
            return today.year, today.month - 1

