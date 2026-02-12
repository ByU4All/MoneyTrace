"""
Settings management.

Provides typed access to application settings stored in SQLite.
"""

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

