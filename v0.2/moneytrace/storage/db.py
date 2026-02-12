"""
SQLite database layer.

Simple, clean interface for event and friend persistence.
All dates stored as ISO strings, amounts as integers (paise).
"""

import sqlite3
from datetime import date
from pathlib import Path
from typing import Optional
from uuid import uuid4

from ..core.events import EventType


# Default categories from idea.md
DEFAULT_CATEGORIES = [
    "Food & Dining",
    "Transport",
    "Shopping",
    "Entertainment",
    "Bills & Utilities",
    "Health",
    "Travel",
    "Other",
]

# Default settings values
DEFAULT_SETTINGS = {
    "base_budget": "1000000",  # ₹10,000 in paise
    "budget_reset_day": "1",
    "budget_reset_enabled": "true",
    "last_reset_date": "",
    "carry_over_enabled": "false",
    "carry_over_cap": "",  # Empty = unlimited
    "carry_over_negative": "false",
}


class Database:
    """SQLite database wrapper for MoneyTrace."""

    def __init__(self, db_path: str | Path = "moneytrace.db"):
        """
        Initialize database connection.

        Args:
            db_path: Path to SQLite database file
        """
        self.db_path = Path(db_path)
        self.conn: Optional[sqlite3.Connection] = None

    def connect(self) -> None:
        """Open database connection and initialize schema."""
        self.conn = sqlite3.connect(str(self.db_path))
        self.conn.row_factory = sqlite3.Row
        self._init_schema()

    def close(self) -> None:
        """Close database connection."""
        if self.conn:
            self.conn.close()
            self.conn = None

    def __enter__(self):
        self.connect()
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.close()

    # ---------------------------------------------------------------------------
    # Schema
    # ---------------------------------------------------------------------------

    def _init_schema(self) -> None:
        """Create tables if they don't exist."""
        cursor = self.conn.cursor()

        # Settings table
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS settings (
                key TEXT PRIMARY KEY,
                value TEXT NOT NULL
            )
        """)

        # Friends table
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS friends (
                id TEXT PRIMARY KEY,
                name TEXT NOT NULL,
                phone TEXT,
                created_at TEXT NOT NULL
            )
        """)

        # Events table
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS events (
                id TEXT PRIMARY KEY,
                type TEXT NOT NULL,
                amount INTEGER NOT NULL,
                category TEXT,
                description TEXT,
                friend_id TEXT,
                event_date TEXT NOT NULL,
                created_at TEXT NOT NULL,
                FOREIGN KEY (friend_id) REFERENCES friends(id)
            )
        """)

        # Categories table (for user-defined categories)
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS categories (
                id TEXT PRIMARY KEY,
                name TEXT NOT NULL UNIQUE,
                is_default INTEGER NOT NULL DEFAULT 0
            )
        """)

        # Month records table (for carry over tracking)
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS month_records (
                id TEXT PRIMARY KEY,
                year INTEGER NOT NULL,
                month INTEGER NOT NULL,
                base_budget INTEGER NOT NULL,
                carry_over_amount INTEGER NOT NULL DEFAULT 0,
                total_budget INTEGER NOT NULL,
                total_spent INTEGER NOT NULL DEFAULT 0,
                ending_balance INTEGER NOT NULL DEFAULT 0,
                created_at TEXT NOT NULL,
                UNIQUE(year, month)
            )
        """)

        # Insert default categories if empty
        cursor.execute("SELECT COUNT(*) FROM categories")
        if cursor.fetchone()[0] == 0:
            for cat in DEFAULT_CATEGORIES:
                cursor.execute(
                    "INSERT INTO categories (id, name, is_default) VALUES (?, ?, 1)",
                    (str(uuid4()), cat)
                )

        # Insert default settings if not set
        for key, value in DEFAULT_SETTINGS.items():
            cursor.execute("SELECT value FROM settings WHERE key = ?", (key,))
            if cursor.fetchone() is None:
                cursor.execute(
                    "INSERT INTO settings (key, value) VALUES (?, ?)",
                    (key, value)
                )

        self.conn.commit()

    # ---------------------------------------------------------------------------
    # Settings
    # ---------------------------------------------------------------------------

    def get_setting(self, key: str, default: str = None) -> Optional[str]:
        """Get a setting value."""
        cursor = self.conn.cursor()
        cursor.execute("SELECT value FROM settings WHERE key = ?", (key,))
        row = cursor.fetchone()
        return row["value"] if row else default

    def set_setting(self, key: str, value: str) -> None:
        """Set a setting value."""
        cursor = self.conn.cursor()
        cursor.execute(
            "INSERT OR REPLACE INTO settings (key, value) VALUES (?, ?)",
            (key, value)
        )
        self.conn.commit()

    def get_base_budget(self) -> int:
        """Get base monthly budget in paise."""
        return int(self.get_setting("base_budget", "1000000"))

    def set_base_budget(self, amount: int) -> None:
        """Set base monthly budget in paise."""
        self.set_setting("base_budget", str(amount))

    def get_budget_reset_day(self) -> int:
        """Get day of month for budget reset (1-28)."""
        return int(self.get_setting("budget_reset_day", "1"))

    def set_budget_reset_day(self, day: int) -> None:
        """Set day of month for budget reset (1-28)."""
        if not 1 <= day <= 28:
            raise ValueError("Reset day must be between 1 and 28")
        self.set_setting("budget_reset_day", str(day))

    def get_budget_reset_enabled(self) -> bool:
        """Get whether budget reset is enabled."""
        return self.get_setting("budget_reset_enabled", "true").lower() == "true"

    def set_budget_reset_enabled(self, enabled: bool) -> None:
        """Set whether budget reset is enabled."""
        self.set_setting("budget_reset_enabled", "true" if enabled else "false")

    def get_last_reset_date(self) -> Optional[date]:
        """Get date of last budget reset."""
        val = self.get_setting("last_reset_date", "")
        return date.fromisoformat(val) if val else None

    def set_last_reset_date(self, d: date) -> None:
        """Set date of last budget reset."""
        self.set_setting("last_reset_date", d.isoformat())

    def get_carry_over_enabled(self) -> bool:
        """Get whether carry over is enabled."""
        return self.get_setting("carry_over_enabled", "false").lower() == "true"

    def set_carry_over_enabled(self, enabled: bool) -> None:
        """Set whether carry over is enabled."""
        self.set_setting("carry_over_enabled", "true" if enabled else "false")

    def get_carry_over_cap(self) -> Optional[int]:
        """Get carry over cap in paise (None = unlimited)."""
        val = self.get_setting("carry_over_cap", "")
        return int(val) if val else None

    def set_carry_over_cap(self, cap: Optional[int]) -> None:
        """Set carry over cap in paise (None = unlimited)."""
        self.set_setting("carry_over_cap", str(cap) if cap else "")

    def get_carry_over_negative(self) -> bool:
        """Get whether to carry over negative balances (deficits)."""
        return self.get_setting("carry_over_negative", "false").lower() == "true"

    def set_carry_over_negative(self, enabled: bool) -> None:
        """Set whether to carry over negative balances."""
        self.set_setting("carry_over_negative", "true" if enabled else "false")

    # ---------------------------------------------------------------------------
    # Categories
    # ---------------------------------------------------------------------------

    def get_categories(self) -> list[dict]:
        """Get all categories."""
        cursor = self.conn.cursor()
        cursor.execute("SELECT id, name, is_default FROM categories ORDER BY name")
        return [dict(row) for row in cursor.fetchall()]

    def add_category(self, name: str) -> str:
        """Add a new category. Returns category ID."""
        cat_id = str(uuid4())
        cursor = self.conn.cursor()
        cursor.execute(
            "INSERT INTO categories (id, name, is_default) VALUES (?, ?, 0)",
            (cat_id, name)
        )
        self.conn.commit()
        return cat_id

    def get_category(self, cat_id: str) -> Optional[dict]:
        """Get a category by ID."""
        cursor = self.conn.cursor()
        cursor.execute(
            "SELECT id, name, is_default FROM categories WHERE id = ?",
            (cat_id,)
        )
        row = cursor.fetchone()
        return dict(row) if row else None

    def get_category_by_name(self, name: str) -> Optional[dict]:
        """Get a category by name."""
        cursor = self.conn.cursor()
        cursor.execute(
            "SELECT id, name, is_default FROM categories WHERE name = ?",
            (name,)
        )
        row = cursor.fetchone()
        return dict(row) if row else None

    def rename_category(self, cat_id: str, new_name: str) -> bool:
        """Rename a category. Returns True if successful."""
        cursor = self.conn.cursor()

        # Get old name first
        cursor.execute("SELECT name FROM categories WHERE id = ?", (cat_id,))
        row = cursor.fetchone()
        if not row:
            return False
        old_name = row["name"]

        # Update category name
        cursor.execute(
            "UPDATE categories SET name = ? WHERE id = ?",
            (new_name, cat_id)
        )

        # Update all events using this category
        cursor.execute(
            "UPDATE events SET category = ? WHERE category = ?",
            (new_name, old_name)
        )

        self.conn.commit()
        return True

    def get_category_usage(self, cat_id: str) -> int:
        """Get number of events using this category."""
        cursor = self.conn.cursor()
        cursor.execute("SELECT name FROM categories WHERE id = ?", (cat_id,))
        row = cursor.fetchone()
        if not row:
            return 0

        cursor.execute(
            "SELECT COUNT(*) FROM events WHERE category = ?",
            (row["name"],)
        )
        return cursor.fetchone()[0]

    def delete_category(self, cat_id: str, reassign_to: str = "Other") -> bool:
        """
        Delete a category and reassign events to another category.

        Args:
            cat_id: Category ID to delete
            reassign_to: Category name to reassign events to

        Returns:
            True if successful
        """
        cursor = self.conn.cursor()

        # Get category name
        cursor.execute("SELECT name FROM categories WHERE id = ?", (cat_id,))
        row = cursor.fetchone()
        if not row:
            return False
        cat_name = row["name"]

        # Reassign events to the target category
        cursor.execute(
            "UPDATE events SET category = ? WHERE category = ?",
            (reassign_to, cat_name)
        )

        # Delete the category
        cursor.execute("DELETE FROM categories WHERE id = ?", (cat_id,))
        self.conn.commit()
        return True

    # ---------------------------------------------------------------------------
    # Friends
    # ---------------------------------------------------------------------------

    def create_friend(self, name: str, phone: str = None) -> str:
        """Create a new friend. Returns friend ID."""
        friend_id = str(uuid4())
        now = date.today().isoformat()

        cursor = self.conn.cursor()
        cursor.execute(
            "INSERT INTO friends (id, name, phone, created_at) VALUES (?, ?, ?, ?)",
            (friend_id, name, phone, now)
        )
        self.conn.commit()
        return friend_id

    def get_friends(self) -> list[dict]:
        """Get all friends."""
        cursor = self.conn.cursor()
        cursor.execute("SELECT id, name, phone, created_at FROM friends ORDER BY name")
        return [dict(row) for row in cursor.fetchall()]

    def get_friend(self, friend_id: str) -> Optional[dict]:
        """Get a friend by ID."""
        cursor = self.conn.cursor()
        cursor.execute(
            "SELECT id, name, phone, created_at FROM friends WHERE id = ?",
            (friend_id,)
        )
        row = cursor.fetchone()
        return dict(row) if row else None

    # ---------------------------------------------------------------------------
    # Events
    # ---------------------------------------------------------------------------

    def create_event(
        self,
        event_type: EventType | str,
        amount: int,
        category: str = None,
        description: str = None,
        friend_id: str = None,
        event_date: date = None,
    ) -> str:
        """
        Create a new event. Returns event ID.

        Args:
            event_type: Type of event (from EventType enum)
            amount: Amount in paise (must be positive)
            category: Category name (required for expense/liability/receivable)
            description: Optional description
            friend_id: Friend ID (required for liability/receivable/settlement)
            event_date: Date of event (defaults to today)
        """
        if amount <= 0:
            raise ValueError("Amount must be positive")

        # Convert enum to string if needed
        if isinstance(event_type, EventType):
            event_type = event_type.value

        event_id = str(uuid4())
        event_date = event_date or date.today()
        now = date.today().isoformat()

        cursor = self.conn.cursor()
        cursor.execute("""
            INSERT INTO events (id, type, amount, category, description, friend_id, event_date, created_at)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        """, (
            event_id,
            event_type,
            amount,
            category,
            description,
            friend_id,
            event_date.isoformat(),
            now,
        ))
        self.conn.commit()
        return event_id

    def get_events(self, limit: int = None) -> list[dict]:
        """Get all events, newest first."""
        cursor = self.conn.cursor()
        query = """
            SELECT id, type, amount, category, description, friend_id, event_date, created_at
            FROM events
            ORDER BY event_date DESC, created_at DESC
        """
        if limit:
            query += f" LIMIT {limit}"

        cursor.execute(query)
        events = []
        for row in cursor.fetchall():
            event = dict(row)
            event["event_date"] = date.fromisoformat(event["event_date"])
            events.append(event)
        return events

    def get_events_for_engine(self) -> list[dict]:
        """
        Get all events formatted for engine consumption.

        Engine expects: type, amount, category, friend_id, event_date
        """
        cursor = self.conn.cursor()
        cursor.execute("""
            SELECT type, amount, category, friend_id, event_date
            FROM events
            ORDER BY event_date, created_at
        """)

        events = []
        for row in cursor.fetchall():
            events.append({
                "type": EventType(row["type"]),
                "amount": row["amount"],
                "category": row["category"],
                "friend_id": row["friend_id"],
                "event_date": date.fromisoformat(row["event_date"]),
            })
        return events

    def get_events_by_friend(self, friend_id: str) -> list[dict]:
        """Get all events for a specific friend."""
        cursor = self.conn.cursor()
        cursor.execute("""
            SELECT id, type, amount, category, description, friend_id, event_date, created_at
            FROM events
            WHERE friend_id = ?
            ORDER BY event_date DESC, created_at DESC
        """, (friend_id,))

        events = []
        for row in cursor.fetchall():
            event = dict(row)
            event["event_date"] = date.fromisoformat(event["event_date"])
            events.append(event)
        return events

    # ---------------------------------------------------------------------------
    # Export/Import (for backup)
    # ---------------------------------------------------------------------------

    def export_all(self) -> dict:
        """Export all data as a dictionary (for JSON backup)."""
        return {
            "version": "0.3.0",
            "exported_at": date.today().isoformat(),
            "settings": {
                "base_budget": self.get_base_budget(),
                "budget_reset_day": self.get_budget_reset_day(),
                "budget_reset_enabled": self.get_budget_reset_enabled(),
                "carry_over_enabled": self.get_carry_over_enabled(),
                "carry_over_cap": self.get_carry_over_cap(),
                "carry_over_negative": self.get_carry_over_negative(),
            },
            "categories": self.get_categories(),
            "friends": self.get_friends(),
            "events": [
                {**e, "event_date": e["event_date"].isoformat()}
                for e in self.get_events()
            ],
            "month_records": self.get_month_records(),
        }

    def import_all(self, data: dict) -> None:
        """Import data from a backup dictionary."""
        cursor = self.conn.cursor()

        # Clear existing data
        cursor.execute("DELETE FROM events")
        cursor.execute("DELETE FROM friends")
        cursor.execute("DELETE FROM categories")
        cursor.execute("DELETE FROM month_records")

        # Import settings
        if "settings" in data:
            settings = data["settings"]
            self.set_base_budget(settings.get("base_budget", 1000000))
            if "budget_reset_day" in settings:
                self.set_budget_reset_day(settings["budget_reset_day"])
            if "budget_reset_enabled" in settings:
                self.set_budget_reset_enabled(settings["budget_reset_enabled"])
            if "carry_over_enabled" in settings:
                self.set_carry_over_enabled(settings["carry_over_enabled"])
            if "carry_over_cap" in settings:
                self.set_carry_over_cap(settings["carry_over_cap"])
            if "carry_over_negative" in settings:
                self.set_carry_over_negative(settings["carry_over_negative"])

        # Import categories
        for cat in data.get("categories", []):
            cursor.execute(
                "INSERT INTO categories (id, name, is_default) VALUES (?, ?, ?)",
                (cat["id"], cat["name"], cat.get("is_default", 0))
            )

        # Import friends
        for friend in data.get("friends", []):
            cursor.execute(
                "INSERT INTO friends (id, name, phone, created_at) VALUES (?, ?, ?, ?)",
                (friend["id"], friend["name"], friend.get("phone"), friend["created_at"])
            )

        # Import events
        for event in data.get("events", []):
            cursor.execute("""
                INSERT INTO events (id, type, amount, category, description, friend_id, event_date, created_at)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            """, (
                event["id"],
                event["type"],
                event["amount"],
                event.get("category"),
                event.get("description"),
                event.get("friend_id"),
                event["event_date"],
                event["created_at"],
            ))

        # Import month records
        for record in data.get("month_records", []):
            cursor.execute("""
                INSERT INTO month_records (id, year, month, base_budget, carry_over_amount, 
                                          total_budget, total_spent, ending_balance, created_at)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
            """, (
                record["id"],
                record["year"],
                record["month"],
                record["base_budget"],
                record.get("carry_over_amount", 0),
                record["total_budget"],
                record.get("total_spent", 0),
                record.get("ending_balance", 0),
                record["created_at"],
            ))

        self.conn.commit()

    # ---------------------------------------------------------------------------
    # Data Management
    # ---------------------------------------------------------------------------

    def clear_all_data(self, keep_friends: bool = True) -> None:
        """
        Clear all transaction data while keeping settings and categories.

        Args:
            keep_friends: If True, keep friends list; if False, clear friends too
        """
        cursor = self.conn.cursor()

        # Always clear events and month records
        cursor.execute("DELETE FROM events")
        cursor.execute("DELETE FROM month_records")

        # Optionally clear friends
        if not keep_friends:
            cursor.execute("DELETE FROM friends")

        # Reset last reset date
        self.set_setting("last_reset_date", "")

        self.conn.commit()

    # ---------------------------------------------------------------------------
    # Month Records (for carry over tracking)
    # ---------------------------------------------------------------------------

    def get_month_records(self) -> list[dict]:
        """Get all month records."""
        cursor = self.conn.cursor()
        cursor.execute("""
            SELECT id, year, month, base_budget, carry_over_amount, 
                   total_budget, total_spent, ending_balance, created_at
            FROM month_records
            ORDER BY year DESC, month DESC
        """)
        return [dict(row) for row in cursor.fetchall()]

    def get_month_record(self, year: int, month: int) -> Optional[dict]:
        """Get record for a specific month."""
        cursor = self.conn.cursor()
        cursor.execute("""
            SELECT id, year, month, base_budget, carry_over_amount,
                   total_budget, total_spent, ending_balance, created_at
            FROM month_records
            WHERE year = ? AND month = ?
        """, (year, month))
        row = cursor.fetchone()
        return dict(row) if row else None

    def get_previous_month_record(self, year: int, month: int) -> Optional[dict]:
        """Get record for the previous month."""
        if month == 1:
            prev_year, prev_month = year - 1, 12
        else:
            prev_year, prev_month = year, month - 1
        return self.get_month_record(prev_year, prev_month)

    def create_month_record(
        self,
        year: int,
        month: int,
        base_budget: int,
        carry_over_amount: int = 0,
    ) -> str:
        """Create a new month record. Returns record ID."""
        record_id = str(uuid4())
        now = date.today().isoformat()
        total_budget = base_budget + carry_over_amount

        cursor = self.conn.cursor()
        cursor.execute("""
            INSERT INTO month_records (id, year, month, base_budget, carry_over_amount,
                                       total_budget, total_spent, ending_balance, created_at)
            VALUES (?, ?, ?, ?, ?, ?, 0, ?, ?)
        """, (
            record_id, year, month, base_budget, carry_over_amount,
            total_budget, total_budget, now
        ))
        self.conn.commit()
        return record_id

    def update_month_record_spent(self, year: int, month: int, total_spent: int) -> None:
        """Update the total spent and ending balance for a month."""
        cursor = self.conn.cursor()
        cursor.execute("""
            UPDATE month_records 
            SET total_spent = ?, ending_balance = total_budget - ?
            WHERE year = ? AND month = ?
        """, (total_spent, total_spent, year, month))
        self.conn.commit()



