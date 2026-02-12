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

        # Insert default categories if empty
        cursor.execute("SELECT COUNT(*) FROM categories")
        if cursor.fetchone()[0] == 0:
            for cat in DEFAULT_CATEGORIES:
                cursor.execute(
                    "INSERT INTO categories (id, name, is_default) VALUES (?, ?, 1)",
                    (str(uuid4()), cat)
                )

        # Insert default budget if not set
        cursor.execute("SELECT value FROM settings WHERE key = 'base_budget'")
        if cursor.fetchone() is None:
            cursor.execute(
                "INSERT INTO settings (key, value) VALUES ('base_budget', '1000000')"
            )  # Default ₹10,000 in paise

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
            "version": "0.2.0",
            "exported_at": date.today().isoformat(),
            "settings": {
                "base_budget": self.get_base_budget(),
            },
            "categories": self.get_categories(),
            "friends": self.get_friends(),
            "events": [
                {**e, "event_date": e["event_date"].isoformat()}
                for e in self.get_events()
            ],
        }

    def import_all(self, data: dict) -> None:
        """Import data from a backup dictionary."""
        cursor = self.conn.cursor()

        # Clear existing data
        cursor.execute("DELETE FROM events")
        cursor.execute("DELETE FROM friends")
        cursor.execute("DELETE FROM categories")

        # Import settings
        if "settings" in data:
            self.set_base_budget(data["settings"].get("base_budget", 1000000))

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

        self.conn.commit()

