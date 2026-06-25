"""
Settings management.

Provides typed access to application settings stored in SQLite.
"""

from datetime import date
from typing import Optional
from .db import Database


class Settings:
    """Typed wrapper around database settings."""

    def __init__(self, db: Database):
        self.db = db

    @property
    def base_budget(self) -> int:
        """Get monthly base budget in paise."""
        return self.db.get_base_budget()

    @base_budget.setter
    def base_budget(self, value: int) -> None:
        """Set monthly base budget in paise."""
        if value < 0:
            raise ValueError("Budget cannot be negative")
        self.db.set_base_budget(value)

    @property
    def base_budget_rupees(self) -> float:
        """Get monthly base budget in rupees."""
        return self.base_budget / 100

    @base_budget_rupees.setter
    def base_budget_rupees(self, value: float) -> None:
        """Set monthly base budget in rupees."""
        self.base_budget = int(value * 100)

    @property
    def currency_symbol(self) -> str:
        """Get currency symbol (fixed to ₹ for V1)."""
        return "₹"

    # -------------------------------------------------------------------------
    # Budget Reset Settings
    # -------------------------------------------------------------------------

    @property
    def budget_reset_day(self) -> int:
        """Get day of month for budget reset (1-28)."""
        return self.db.get_budget_reset_day()

    @budget_reset_day.setter
    def budget_reset_day(self, value: int) -> None:
        """Set day of month for budget reset (1-28)."""
        self.db.set_budget_reset_day(value)

    @property
    def budget_reset_enabled(self) -> bool:
        """Get whether auto budget reset is enabled."""
        return self.db.get_budget_reset_enabled()

    @budget_reset_enabled.setter
    def budget_reset_enabled(self, value: bool) -> None:
        """Set whether auto budget reset is enabled."""
        self.db.set_budget_reset_enabled(value)

    @property
    def last_reset_date(self) -> Optional[date]:
        """Get date of last budget reset."""
        return self.db.get_last_reset_date()

    @last_reset_date.setter
    def last_reset_date(self, value: date) -> None:
        """Set date of last budget reset."""
        self.db.set_last_reset_date(value)

    # -------------------------------------------------------------------------
    # Carry Over Settings
    # -------------------------------------------------------------------------

    @property
    def carry_over_enabled(self) -> bool:
        """Get whether carry over is enabled."""
        return self.db.get_carry_over_enabled()

    @carry_over_enabled.setter
    def carry_over_enabled(self, value: bool) -> None:
        """Set whether carry over is enabled."""
        self.db.set_carry_over_enabled(value)

    @property
    def carry_over_cap(self) -> Optional[int]:
        """Get carry over cap in paise (None = unlimited)."""
        return self.db.get_carry_over_cap()

    @carry_over_cap.setter
    def carry_over_cap(self, value: Optional[int]) -> None:
        """Set carry over cap in paise (None = unlimited)."""
        self.db.set_carry_over_cap(value)

    @property
    def carry_over_negative(self) -> bool:
        """Get whether to carry over negative balances."""
        return self.db.get_carry_over_negative()

    @carry_over_negative.setter
    def carry_over_negative(self, value: bool) -> None:
        """Set whether to carry over negative balances."""
        self.db.set_carry_over_negative(value)

