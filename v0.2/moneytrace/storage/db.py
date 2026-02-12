"""
SQLite database layer.

Simple, clean interface for event and friend persistence.
All dates stored as ISO strings, amounts as integers (paise).
"""

import sqlite3
from datetime import date, timedelta
from pathlib import Path
from typing import Optional
from uuid import uuid4

from ..core.events import EventType, AccountType, RecurringFrequency, LoanType


# Default categories from idea.md
DEFAULT_CATEGORIES = [
    "Food & Dining",
    "Transport",
    "Shopping",
    "Entertainment",
    "Bills & Utilities",
    "Health",
    "Travel",
    "Salary",
    "EMI",
    "Investment",
    "Other",
]

# Default settings values
DEFAULT_SETTINGS = {
    "base_budget": "0",  # ₹0 - user must set their budget
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

        # Accounts table
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS accounts (
                id TEXT PRIMARY KEY,
                name TEXT NOT NULL,
                type TEXT NOT NULL,
                institution TEXT,
                last_4_digits TEXT,
                color TEXT,
                icon TEXT,
                tracked_balance INTEGER NOT NULL DEFAULT 0,
                current_balance INTEGER DEFAULT 0,
                is_credit INTEGER NOT NULL DEFAULT 0,
                credit_limit INTEGER,
                billing_day INTEGER,
                due_day INTEGER,
                is_active INTEGER NOT NULL DEFAULT 1,
                is_default INTEGER NOT NULL DEFAULT 0,
                created_at TEXT NOT NULL
            )
        """)

        # Events table (updated with account_id and from/to account for transfers)
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS events (
                id TEXT PRIMARY KEY,
                type TEXT NOT NULL,
                amount INTEGER NOT NULL,
                category TEXT,
                description TEXT,
                friend_id TEXT,
                account_id TEXT,
                from_account_id TEXT,
                to_account_id TEXT,
                recurring_id TEXT,
                loan_id TEXT,
                event_date TEXT NOT NULL,
                created_at TEXT NOT NULL,
                FOREIGN KEY (friend_id) REFERENCES friends(id),
                FOREIGN KEY (account_id) REFERENCES accounts(id),
                FOREIGN KEY (from_account_id) REFERENCES accounts(id),
                FOREIGN KEY (to_account_id) REFERENCES accounts(id),
                FOREIGN KEY (recurring_id) REFERENCES recurring_transactions(id),
                FOREIGN KEY (loan_id) REFERENCES loans(id)
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

        # Recurring transactions table
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS recurring_transactions (
                id TEXT PRIMARY KEY,
                name TEXT NOT NULL,
                type TEXT NOT NULL,
                amount INTEGER NOT NULL,
                category TEXT,
                account_id TEXT,
                frequency TEXT NOT NULL,
                day_of_month INTEGER,
                day_of_week INTEGER,
                start_date TEXT NOT NULL,
                end_date TEXT,
                requires_verification INTEGER NOT NULL DEFAULT 1,
                auto_apply INTEGER NOT NULL DEFAULT 0,
                is_autopay INTEGER NOT NULL DEFAULT 0,
                is_active INTEGER NOT NULL DEFAULT 1,
                last_applied_date TEXT,
                next_due_date TEXT,
                linked_loan_id TEXT,
                created_at TEXT NOT NULL,
                FOREIGN KEY (account_id) REFERENCES accounts(id),
                FOREIGN KEY (linked_loan_id) REFERENCES loans(id)
            )
        """)

        # Migration: Add is_autopay column if it doesn't exist
        try:
            cursor.execute("ALTER TABLE recurring_transactions ADD COLUMN is_autopay INTEGER NOT NULL DEFAULT 0")
        except:
            pass  # Column already exists

        # Pending recurring transactions (for verification)
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS pending_transactions (
                id TEXT PRIMARY KEY,
                recurring_id TEXT NOT NULL,
                due_date TEXT NOT NULL,
                amount INTEGER NOT NULL,
                status TEXT NOT NULL DEFAULT 'pending',
                action_date TEXT,
                created_at TEXT NOT NULL,
                FOREIGN KEY (recurring_id) REFERENCES recurring_transactions(id)
            )
        """)

        # Loans table
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS loans (
                id TEXT PRIMARY KEY,
                name TEXT NOT NULL,
                type TEXT NOT NULL,
                principal INTEGER NOT NULL,
                interest_rate REAL NOT NULL,
                tenure_months INTEGER NOT NULL,
                emi_amount INTEGER NOT NULL,
                start_date TEXT NOT NULL,
                emi_day INTEGER NOT NULL,
                payments_made INTEGER NOT NULL DEFAULT 0,
                payment_account_id TEXT,
                payment_type TEXT NOT NULL DEFAULT 'manual',
                credit_card_id TEXT,
                lender TEXT,
                purpose TEXT,
                is_active INTEGER NOT NULL DEFAULT 1,
                foreclosure_amount INTEGER,
                created_at TEXT NOT NULL,
                FOREIGN KEY (payment_account_id) REFERENCES accounts(id),
                FOREIGN KEY (credit_card_id) REFERENCES accounts(id)
            )
        """)

        # Credit card statements table
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS credit_card_statements (
                id TEXT PRIMARY KEY,
                card_account_id TEXT NOT NULL,
                statement_date TEXT NOT NULL,
                due_date TEXT NOT NULL,
                statement_amount INTEGER NOT NULL,
                minimum_due INTEGER NOT NULL,
                paid_amount INTEGER NOT NULL DEFAULT 0,
                paid_date TEXT,
                is_fully_paid INTEGER NOT NULL DEFAULT 0,
                created_at TEXT NOT NULL,
                FOREIGN KEY (card_account_id) REFERENCES accounts(id)
            )
        """)

        # Audit log table - tracks all CRUD operations for timeline
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS audit_log (
                id TEXT PRIMARY KEY,
                action TEXT NOT NULL,
                entity_type TEXT NOT NULL,
                entity_id TEXT NOT NULL,
                entity_name TEXT,
                old_values TEXT,
                new_values TEXT,
                description TEXT,
                is_money_related INTEGER NOT NULL DEFAULT 0,
                created_at TEXT NOT NULL
            )
        """)

        # Add new columns to events table if they don't exist (migration)
        try:
            cursor.execute("ALTER TABLE events ADD COLUMN account_id TEXT")
        except sqlite3.OperationalError:
            pass
        try:
            cursor.execute("ALTER TABLE events ADD COLUMN from_account_id TEXT")
        except sqlite3.OperationalError:
            pass
        try:
            cursor.execute("ALTER TABLE events ADD COLUMN to_account_id TEXT")
        except sqlite3.OperationalError:
            pass
        try:
            cursor.execute("ALTER TABLE events ADD COLUMN recurring_id TEXT")
        except sqlite3.OperationalError:
            pass
        try:
            cursor.execute("ALTER TABLE events ADD COLUMN loan_id TEXT")
        except sqlite3.OperationalError:
            pass

        # Insert default categories if empty
        cursor.execute("SELECT COUNT(*) FROM categories")
        if cursor.fetchone()[0] == 0:
            for cat in DEFAULT_CATEGORIES:
                cursor.execute(
                    "INSERT INTO categories (id, name, is_default) VALUES (?, ?, 1)",
                    (str(uuid4()), cat)
                )

        # Insert default Cash account if no accounts exist
        cursor.execute("SELECT COUNT(*) FROM accounts")
        if cursor.fetchone()[0] == 0:
            cursor.execute("""
                INSERT INTO accounts (id, name, type, is_default, created_at)
                VALUES (?, ?, ?, 1, ?)
            """, (str(uuid4()), "Cash", AccountType.CASH.value, date.today().isoformat()))

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
    # Accounts
    # ---------------------------------------------------------------------------

    def create_account(
        self,
        name: str,
        account_type: str,
        institution: str = None,
        last_4_digits: str = None,
        color: str = None,
        icon: str = None,
        tracked_balance: bool = False,
        current_balance: int = 0,
        is_credit: bool = False,
        credit_limit: int = None,
        billing_day: int = None,
        due_day: int = None,
    ) -> str:
        """Create a new account. Returns account ID."""
        account_id = str(uuid4())
        now = date.today().isoformat()

        cursor = self.conn.cursor()
        cursor.execute("""
            INSERT INTO accounts (
                id, name, type, institution, last_4_digits, color, icon,
                tracked_balance, current_balance, is_credit, credit_limit,
                billing_day, due_day, is_active, created_at
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 1, ?)
        """, (
            account_id, name, account_type, institution, last_4_digits,
            color, icon, 1 if tracked_balance else 0, current_balance,
            1 if is_credit else 0, credit_limit, billing_day, due_day, now
        ))
        self.conn.commit()
        return account_id

    def get_accounts(self, include_inactive: bool = False) -> list[dict]:
        """Get all accounts."""
        cursor = self.conn.cursor()
        if include_inactive:
            cursor.execute("""
                SELECT id, name, type, institution, last_4_digits, color, icon,
                       tracked_balance, current_balance, is_credit, credit_limit,
                       billing_day, due_day, is_active, is_default, created_at
                FROM accounts ORDER BY is_default DESC, name
            """)
        else:
            cursor.execute("""
                SELECT id, name, type, institution, last_4_digits, color, icon,
                       tracked_balance, current_balance, is_credit, credit_limit,
                       billing_day, due_day, is_active, is_default, created_at
                FROM accounts WHERE is_active = 1 ORDER BY is_default DESC, name
            """)
        return [dict(row) for row in cursor.fetchall()]

    def get_account(self, account_id: str) -> Optional[dict]:
        """Get an account by ID."""
        cursor = self.conn.cursor()
        cursor.execute("""
            SELECT id, name, type, institution, last_4_digits, color, icon,
                   tracked_balance, current_balance, is_credit, credit_limit,
                   billing_day, due_day, is_active, is_default, created_at
            FROM accounts WHERE id = ?
        """, (account_id,))
        row = cursor.fetchone()
        return dict(row) if row else None

    def get_default_account(self) -> Optional[dict]:
        """Get the default account (usually Cash)."""
        cursor = self.conn.cursor()
        cursor.execute("""
            SELECT id, name, type, institution, last_4_digits, color, icon,
                   tracked_balance, current_balance, is_credit, credit_limit,
                   billing_day, due_day, is_active, is_default, created_at
            FROM accounts WHERE is_default = 1 LIMIT 1
        """)
        row = cursor.fetchone()
        return dict(row) if row else None

    def get_credit_cards(self) -> list[dict]:
        """Get all credit card accounts."""
        cursor = self.conn.cursor()
        cursor.execute("""
            SELECT id, name, type, institution, last_4_digits, color, icon,
                   tracked_balance, current_balance, is_credit, credit_limit,
                   billing_day, due_day, is_active, is_default, created_at
            FROM accounts WHERE type = 'credit_card' AND is_active = 1
            ORDER BY name
        """)
        return [dict(row) for row in cursor.fetchall()]

    def update_account(
        self,
        account_id: str,
        name: str = None,
        institution: str = None,
        last_4_digits: str = None,
        color: str = None,
        icon: str = None,
        tracked_balance: bool = None,
        current_balance: int = None,
        credit_limit: int = None,
        billing_day: int = None,
        due_day: int = None,
        is_active: bool = None,
    ) -> bool:
        """Update an account. Returns True if successful."""
        cursor = self.conn.cursor()

        updates = []
        values = []

        if name is not None:
            updates.append("name = ?")
            values.append(name)
        if institution is not None:
            updates.append("institution = ?")
            values.append(institution)
        if last_4_digits is not None:
            updates.append("last_4_digits = ?")
            values.append(last_4_digits)
        if color is not None:
            updates.append("color = ?")
            values.append(color)
        if icon is not None:
            updates.append("icon = ?")
            values.append(icon)
        if tracked_balance is not None:
            updates.append("tracked_balance = ?")
            values.append(1 if tracked_balance else 0)
        if current_balance is not None:
            updates.append("current_balance = ?")
            values.append(current_balance)
        if credit_limit is not None:
            updates.append("credit_limit = ?")
            values.append(credit_limit)
        if billing_day is not None:
            updates.append("billing_day = ?")
            values.append(billing_day)
        if due_day is not None:
            updates.append("due_day = ?")
            values.append(due_day)
        if is_active is not None:
            updates.append("is_active = ?")
            values.append(1 if is_active else 0)

        if not updates:
            return True

        values.append(account_id)
        cursor.execute(
            f"UPDATE accounts SET {', '.join(updates)} WHERE id = ?",
            values
        )
        self.conn.commit()
        return cursor.rowcount > 0

    def delete_account(self, account_id: str) -> bool:
        """Soft delete an account (mark as inactive)."""
        return self.update_account(account_id, is_active=False)

    def update_account_balance(self, account_id: str, amount_change: int) -> None:
        """Update account balance by a delta amount."""
        cursor = self.conn.cursor()
        cursor.execute(
            "UPDATE accounts SET current_balance = current_balance + ? WHERE id = ?",
            (amount_change, account_id)
        )
        self.conn.commit()

    def get_account_events(self, account_id: str, limit: int = None) -> list[dict]:
        """Get all events for a specific account."""
        cursor = self.conn.cursor()
        query = """
            SELECT id, type, amount, category, description, friend_id,
                   account_id, from_account_id, to_account_id, event_date, created_at
            FROM events
            WHERE account_id = ? OR from_account_id = ? OR to_account_id = ?
            ORDER BY event_date DESC, created_at DESC
        """
        if limit:
            query += f" LIMIT {limit}"

        cursor.execute(query, (account_id, account_id, account_id))
        events = []
        for row in cursor.fetchall():
            event = dict(row)
            event["event_date"] = date.fromisoformat(event["event_date"])
            events.append(event)
        return events

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
        account_id: str = None,
        from_account_id: str = None,
        to_account_id: str = None,
        recurring_id: str = None,
        loan_id: str = None,
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
            account_id: Account used for this transaction
            from_account_id: Source account (for transfers)
            to_account_id: Destination account (for transfers)
            recurring_id: Linked recurring transaction ID
            loan_id: Linked loan ID (for EMI payments)
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
            INSERT INTO events (id, type, amount, category, description, friend_id,
                               account_id, from_account_id, to_account_id, recurring_id,
                               loan_id, event_date, created_at)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """, (
            event_id,
            event_type,
            amount,
            category,
            description,
            friend_id,
            account_id,
            from_account_id,
            to_account_id,
            recurring_id,
            loan_id,
            event_date.isoformat(),
            now,
        ))
        self.conn.commit()
        return event_id

    def get_events(self, limit: int = None, account_id: str = None) -> list[dict]:
        """Get all events, newest first. Optionally filter by account."""
        cursor = self.conn.cursor()

        if account_id:
            query = """
                SELECT id, type, amount, category, description, friend_id,
                       account_id, from_account_id, to_account_id, recurring_id,
                       loan_id, event_date, created_at
                FROM events
                WHERE account_id = ? OR from_account_id = ? OR to_account_id = ?
                ORDER BY event_date DESC, created_at DESC
            """
            params = [account_id, account_id, account_id]
        else:
            query = """
                SELECT id, type, amount, category, description, friend_id,
                       account_id, from_account_id, to_account_id, recurring_id,
                       loan_id, event_date, created_at
                FROM events
                ORDER BY event_date DESC, created_at DESC
            """
            params = []

        if limit:
            query += f" LIMIT {limit}"

        cursor.execute(query, params)
        events = []
        for row in cursor.fetchall():
            event = dict(row)
            event["event_date"] = date.fromisoformat(event["event_date"])
            events.append(event)
        return events

    def get_events_for_engine(self) -> list[dict]:
        """
        Get all events formatted for engine consumption.

        Engine expects: type, amount, category, friend_id, event_date, account_id
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
            "version": "0.4.0",
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
            "accounts": self.get_accounts(include_inactive=True),
            "events": [
                {**e, "event_date": e["event_date"].isoformat()}
                for e in self.get_events()
            ],
            "month_records": self.get_month_records(),
            "recurring_transactions": self.get_recurring_transactions(active_only=False),
            "loans": self.get_loans(active_only=False),
            "credit_card_statements": self.get_credit_card_statements(),
        }

    def import_all(self, data: dict) -> None:
        """Import data from a backup dictionary."""
        cursor = self.conn.cursor()

        # Clear existing data
        cursor.execute("DELETE FROM events")
        cursor.execute("DELETE FROM friends")
        cursor.execute("DELETE FROM categories")
        cursor.execute("DELETE FROM month_records")
        cursor.execute("DELETE FROM accounts")
        cursor.execute("DELETE FROM recurring_transactions")
        cursor.execute("DELETE FROM pending_transactions")
        cursor.execute("DELETE FROM loans")
        cursor.execute("DELETE FROM credit_card_statements")

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

    # ---------------------------------------------------------------------------
    # Recurring Transactions
    # ---------------------------------------------------------------------------

    def create_recurring_transaction(
        self,
        name: str,
        transaction_type: str,
        amount: int,
        frequency: str,
        start_date: date,
        category: str = None,
        account_id: str = None,
        day_of_month: int = None,
        day_of_week: int = None,
        end_date: date = None,
        requires_verification: bool = True,
        auto_apply: bool = False,
        is_autopay: bool = False,
        linked_loan_id: str = None,
    ) -> str:
        """Create a new recurring transaction. Returns ID."""
        rec_id = str(uuid4())
        now = date.today().isoformat()

        # Calculate next due date
        next_due = self._calculate_next_due_date(
            frequency, start_date, day_of_month, day_of_week
        )

        cursor = self.conn.cursor()
        cursor.execute("""
            INSERT INTO recurring_transactions (
                id, name, type, amount, category, account_id, frequency,
                day_of_month, day_of_week, start_date, end_date,
                requires_verification, auto_apply, is_autopay, is_active,
                next_due_date, linked_loan_id, created_at
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 1, ?, ?, ?)
        """, (
            rec_id, name, transaction_type, amount, category, account_id,
            frequency, day_of_month, day_of_week, start_date.isoformat(),
            end_date.isoformat() if end_date else None,
            1 if requires_verification else 0, 1 if auto_apply else 0,
            1 if is_autopay else 0,
            next_due.isoformat() if next_due else None, linked_loan_id, now
        ))
        self.conn.commit()
        return rec_id

    def _calculate_next_due_date(
        self,
        frequency: str,
        start_date: date,
        day_of_month: int = None,
        day_of_week: int = None,
    ) -> Optional[date]:
        """Calculate the next due date for a recurring transaction."""
        today = date.today()

        if frequency == RecurringFrequency.MONTHLY.value:
            day = day_of_month or start_date.day
            # Start with current month
            year, month = today.year, today.month
            try:
                next_due = date(year, month, min(day, 28))
            except ValueError:
                next_due = date(year, month, 28)

            # If already past this month's due date, move to next month
            if next_due <= today:
                month += 1
                if month > 12:
                    month = 1
                    year += 1
                try:
                    next_due = date(year, month, min(day, 28))
                except ValueError:
                    next_due = date(year, month, 28)

            return next_due

        elif frequency == RecurringFrequency.WEEKLY.value:
            day = day_of_week if day_of_week is not None else start_date.weekday()
            days_ahead = day - today.weekday()
            if days_ahead <= 0:
                days_ahead += 7
            return today + timedelta(days=days_ahead)

        elif frequency == RecurringFrequency.DAILY.value:
            return today + timedelta(days=1)

        elif frequency == RecurringFrequency.YEARLY.value:
            next_due = date(today.year, start_date.month, start_date.day)
            if next_due <= today:
                next_due = date(today.year + 1, start_date.month, start_date.day)
            return next_due

        return None

    def get_recurring_transactions(self, active_only: bool = True) -> list[dict]:
        """Get all recurring transactions."""
        cursor = self.conn.cursor()
        if active_only:
            cursor.execute("""
                SELECT id, name, type, amount, category, account_id, frequency,
                       day_of_month, day_of_week, start_date, end_date,
                       requires_verification, auto_apply, is_autopay, is_active,
                       last_applied_date, next_due_date, linked_loan_id, created_at
                FROM recurring_transactions
                WHERE is_active = 1
                ORDER BY next_due_date
            """)
        else:
            cursor.execute("""
                SELECT id, name, type, amount, category, account_id, frequency,
                       day_of_month, day_of_week, start_date, end_date,
                       requires_verification, auto_apply, is_autopay, is_active,
                       last_applied_date, next_due_date, linked_loan_id, created_at
                FROM recurring_transactions
                ORDER BY next_due_date
            """)
        return [dict(row) for row in cursor.fetchall()]

    def get_recurring_transaction(self, rec_id: str) -> Optional[dict]:
        """Get a recurring transaction by ID."""
        cursor = self.conn.cursor()
        cursor.execute("""
            SELECT id, name, type, amount, category, account_id, frequency,
                   day_of_month, day_of_week, start_date, end_date,
                   requires_verification, auto_apply, is_autopay, is_active,
                   last_applied_date, next_due_date, linked_loan_id, created_at
            FROM recurring_transactions WHERE id = ?
        """, (rec_id,))
        row = cursor.fetchone()
        return dict(row) if row else None

    def get_due_recurring_transactions(self) -> list[dict]:
        """Get recurring transactions that are due today or earlier."""
        today = date.today().isoformat()
        cursor = self.conn.cursor()
        cursor.execute("""
            SELECT id, name, type, amount, category, account_id, frequency,
                   day_of_month, day_of_week, start_date, end_date,
                   requires_verification, auto_apply, is_autopay, is_active,
                   last_applied_date, next_due_date, linked_loan_id, created_at
            FROM recurring_transactions
            WHERE is_active = 1 AND next_due_date <= ?
            ORDER BY next_due_date
        """, (today,))
        return [dict(row) for row in cursor.fetchall()]

    def update_recurring_transaction_applied(self, rec_id: str) -> None:
        """Mark a recurring transaction as applied and update next due date."""
        cursor = self.conn.cursor()
        rec = self.get_recurring_transaction(rec_id)
        if not rec:
            return

        today = date.today()
        next_due = self._calculate_next_due_date(
            rec["frequency"],
            date.fromisoformat(rec["start_date"]),
            rec["day_of_month"],
            rec["day_of_week"]
        )

        # Check if we've reached the end date
        end_date = date.fromisoformat(rec["end_date"]) if rec["end_date"] else None
        is_active = 1
        if end_date and next_due and next_due > end_date:
            is_active = 0
            next_due = None

        cursor.execute("""
            UPDATE recurring_transactions
            SET last_applied_date = ?, next_due_date = ?, is_active = ?
            WHERE id = ?
        """, (
            today.isoformat(),
            next_due.isoformat() if next_due else None,
            is_active,
            rec_id
        ))
        self.conn.commit()

    def get_unpaid_recurring_for_month(self, year: int = None, month: int = None) -> list[dict]:
        """
        Get active recurring transactions due this month that haven't been paid yet.
        Only returns expense types (expense, emi_payment) that reduce budget.
        """
        today = date.today()
        year = year or today.year
        month = month or today.month

        # Calculate month boundaries
        month_start = date(year, month, 1)
        if month == 12:
            month_end = date(year + 1, 1, 1)
        else:
            month_end = date(year, month + 1, 1)

        cursor = self.conn.cursor()

        # Get active recurring where:
        # 1. next_due_date is within this month
        # 2. type is expense or emi_payment (reduces budget)
        # 3. last_applied_date is NOT in current month (not yet paid this cycle)
        cursor.execute("""
            SELECT r.id, r.name, r.type, r.amount, r.category, r.account_id,
                   r.frequency, r.next_due_date, r.is_autopay, r.linked_loan_id
            FROM recurring_transactions r
            WHERE r.is_active = 1
              AND r.type IN ('expense', 'emi_payment')
              AND r.next_due_date >= ?
              AND r.next_due_date < ?
              AND (r.last_applied_date IS NULL 
                   OR r.last_applied_date < ?)
            ORDER BY r.next_due_date
        """, (
            month_start.isoformat(),
            month_end.isoformat(),
            month_start.isoformat()
        ))

        results = []
        for row in cursor.fetchall():
            rec = dict(row)
            # Calculate days until due
            if rec["next_due_date"]:
                due_date = date.fromisoformat(rec["next_due_date"])
                rec["days_until_due"] = (due_date - today).days
                rec["is_overdue"] = rec["days_until_due"] < 0
            else:
                rec["days_until_due"] = None
                rec["is_overdue"] = False
            results.append(rec)

        return results

    def get_upcoming_bills(self, days_ahead: int = 30) -> list[dict]:
        """
        Get all upcoming bills (recurring transactions) within the next N days.
        Includes payment status for current cycle.
        """
        today = date.today()
        end_date = today + timedelta(days=days_ahead)

        cursor = self.conn.cursor()

        # Get active recurring where next_due_date is within range
        cursor.execute("""
            SELECT r.id, r.name, r.type, r.amount, r.category, r.account_id,
                   r.frequency, r.next_due_date, r.is_autopay, r.last_applied_date,
                   r.linked_loan_id
            FROM recurring_transactions r
            WHERE r.is_active = 1
              AND r.next_due_date IS NOT NULL
              AND r.next_due_date <= ?
            ORDER BY r.next_due_date
        """, (end_date.isoformat(),))

        results = []
        for row in cursor.fetchall():
            rec = dict(row)
            due_date = date.fromisoformat(rec["next_due_date"])
            rec["days_until_due"] = (due_date - today).days
            rec["is_overdue"] = rec["days_until_due"] < 0
            rec["due_date_formatted"] = due_date.strftime("%b %d")

            # Check if already paid this cycle (last_applied_date is after previous due date)
            # For simplicity, if last_applied_date is in current month, consider paid
            if rec["last_applied_date"]:
                last_applied = date.fromisoformat(rec["last_applied_date"])
                rec["is_paid_this_cycle"] = (last_applied.year == today.year and
                                              last_applied.month == today.month)
            else:
                rec["is_paid_this_cycle"] = False

            results.append(rec)

        return results

    def update_recurring_transaction(
        self,
        rec_id: str,
        name: str = None,
        amount: int = None,
        category: str = None,
        account_id: str = None,
        frequency: str = None,
        day_of_month: int = None,
        day_of_week: int = None,
        end_date: str = None,
        requires_verification: bool = None,
        auto_apply: bool = None,
        is_autopay: bool = None,
        is_active: bool = None,
    ) -> bool:
        """Update a recurring transaction. Returns True if successful."""
        cursor = self.conn.cursor()

        updates = []
        values = []

        if name is not None:
            updates.append("name = ?")
            values.append(name)
        if amount is not None:
            updates.append("amount = ?")
            values.append(amount)
        if category is not None:
            updates.append("category = ?")
            values.append(category)
        if account_id is not None:
            updates.append("account_id = ?")
            values.append(account_id)
        if frequency is not None:
            updates.append("frequency = ?")
            values.append(frequency)
        if day_of_month is not None:
            updates.append("day_of_month = ?")
            values.append(day_of_month)
        if day_of_week is not None:
            updates.append("day_of_week = ?")
            values.append(day_of_week)
        if end_date is not None:
            updates.append("end_date = ?")
            values.append(end_date)
        if requires_verification is not None:
            updates.append("requires_verification = ?")
            values.append(1 if requires_verification else 0)
        if auto_apply is not None:
            updates.append("auto_apply = ?")
            values.append(1 if auto_apply else 0)
        if is_autopay is not None:
            updates.append("is_autopay = ?")
            values.append(1 if is_autopay else 0)
        if is_active is not None:
            updates.append("is_active = ?")
            values.append(1 if is_active else 0)

        if not updates:
            return True

        values.append(rec_id)
        cursor.execute(
            f"UPDATE recurring_transactions SET {', '.join(updates)} WHERE id = ?",
            values
        )
        self.conn.commit()
        return cursor.rowcount > 0

    def delete_recurring_transaction(self, rec_id: str) -> bool:
        """Soft delete a recurring transaction."""
        cursor = self.conn.cursor()
        cursor.execute(
            "UPDATE recurring_transactions SET is_active = 0 WHERE id = ?",
            (rec_id,)
        )
        self.conn.commit()
        return cursor.rowcount > 0

    # ---------------------------------------------------------------------------
    # Pending Transactions (for verification)
    # ---------------------------------------------------------------------------

    def create_pending_transaction(
        self,
        recurring_id: str,
        due_date: date,
        amount: int,
    ) -> str:
        """Create a pending transaction for verification."""
        pending_id = str(uuid4())
        now = date.today().isoformat()

        cursor = self.conn.cursor()
        cursor.execute("""
            INSERT INTO pending_transactions (
                id, recurring_id, due_date, amount, status, created_at
            ) VALUES (?, ?, ?, ?, 'pending', ?)
        """, (pending_id, recurring_id, due_date.isoformat(), amount, now))
        self.conn.commit()
        return pending_id

    def get_pending_transactions(self) -> list[dict]:
        """Get all pending transactions awaiting verification."""
        cursor = self.conn.cursor()
        cursor.execute("""
            SELECT p.id, p.recurring_id, p.due_date, p.amount, p.status,
                   p.action_date, p.created_at,
                   r.name, r.type, r.category, r.account_id
            FROM pending_transactions p
            JOIN recurring_transactions r ON p.recurring_id = r.id
            WHERE p.status = 'pending'
            ORDER BY p.due_date
        """)
        return [dict(row) for row in cursor.fetchall()]

    def confirm_pending_transaction(self, pending_id: str) -> str:
        """Confirm a pending transaction and create the event. Returns event ID."""
        cursor = self.conn.cursor()
        cursor.execute("""
            SELECT p.*, r.name, r.type, r.category, r.account_id, r.linked_loan_id
            FROM pending_transactions p
            JOIN recurring_transactions r ON p.recurring_id = r.id
            WHERE p.id = ?
        """, (pending_id,))
        row = cursor.fetchone()
        if not row:
            raise ValueError("Pending transaction not found")

        pending = dict(row)

        # Create the event
        event_id = self.create_event(
            event_type=pending["type"],
            amount=pending["amount"],
            category=pending["category"],
            description=f"Recurring: {pending['name']}",
            account_id=pending["account_id"],
            recurring_id=pending["recurring_id"],
            loan_id=pending["linked_loan_id"],
            event_date=date.fromisoformat(pending["due_date"]),
        )

        # Update pending status
        cursor.execute("""
            UPDATE pending_transactions
            SET status = 'confirmed', action_date = ?
            WHERE id = ?
        """, (date.today().isoformat(), pending_id))

        # Update recurring transaction
        self.update_recurring_transaction_applied(pending["recurring_id"])

        self.conn.commit()
        return event_id

    def skip_pending_transaction(self, pending_id: str) -> None:
        """Skip a pending transaction."""
        cursor = self.conn.cursor()

        # Get the recurring_id first
        cursor.execute(
            "SELECT recurring_id FROM pending_transactions WHERE id = ?",
            (pending_id,)
        )
        row = cursor.fetchone()
        if row:
            # Update pending status
            cursor.execute("""
                UPDATE pending_transactions
                SET status = 'skipped', action_date = ?
                WHERE id = ?
            """, (date.today().isoformat(), pending_id))

            # Update recurring transaction to move to next date
            self.update_recurring_transaction_applied(row["recurring_id"])

            self.conn.commit()

    # ---------------------------------------------------------------------------
    # Loans
    # ---------------------------------------------------------------------------

    def create_loan(
        self,
        name: str,
        loan_type: str,
        principal: int,
        interest_rate: float,
        tenure_months: int,
        emi_amount: int,
        start_date: date,
        emi_day: int,
        payment_account_id: str = None,
        payment_type: str = "manual",
        credit_card_id: str = None,
        lender: str = None,
        purpose: str = None,
    ) -> str:
        """Create a new loan. Returns loan ID."""
        loan_id = str(uuid4())
        now = date.today().isoformat()

        cursor = self.conn.cursor()
        cursor.execute("""
            INSERT INTO loans (
                id, name, type, principal, interest_rate, tenure_months,
                emi_amount, start_date, emi_day, payments_made,
                payment_account_id, payment_type, credit_card_id,
                lender, purpose, is_active, created_at
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 0, ?, ?, ?, ?, ?, 1, ?)
        """, (
            loan_id, name, loan_type, principal, interest_rate, tenure_months,
            emi_amount, start_date.isoformat(), emi_day, payment_account_id,
            payment_type, credit_card_id, lender, purpose, now
        ))
        self.conn.commit()

        # Auto-create recurring transaction for this loan
        end_date = start_date
        for _ in range(tenure_months):
            if end_date.month == 12:
                end_date = date(end_date.year + 1, 1, end_date.day)
            else:
                try:
                    end_date = date(end_date.year, end_date.month + 1, end_date.day)
                except ValueError:
                    end_date = date(end_date.year, end_date.month + 1, 28)

        self.create_recurring_transaction(
            name=f"{name} EMI",
            transaction_type=EventType.EMI_PAYMENT.value,
            amount=emi_amount,
            frequency=RecurringFrequency.MONTHLY.value,
            start_date=start_date,
            category="EMI",
            account_id=payment_account_id,
            day_of_month=emi_day,
            end_date=end_date,
            requires_verification=True,
            auto_apply=False,
            linked_loan_id=loan_id,
        )

        return loan_id

    def get_loans(self, active_only: bool = True) -> list[dict]:
        """Get all loans."""
        cursor = self.conn.cursor()
        if active_only:
            cursor.execute("""
                SELECT id, name, type, principal, interest_rate, tenure_months,
                       emi_amount, start_date, emi_day, payments_made,
                       payment_account_id, payment_type, credit_card_id,
                       lender, purpose, is_active, foreclosure_amount, created_at
                FROM loans WHERE is_active = 1
                ORDER BY created_at DESC
            """)
        else:
            cursor.execute("""
                SELECT id, name, type, principal, interest_rate, tenure_months,
                       emi_amount, start_date, emi_day, payments_made,
                       payment_account_id, payment_type, credit_card_id,
                       lender, purpose, is_active, foreclosure_amount, created_at
                FROM loans
                ORDER BY created_at DESC
            """)
        return [dict(row) for row in cursor.fetchall()]

    def get_loan(self, loan_id: str) -> Optional[dict]:
        """Get a loan by ID."""
        cursor = self.conn.cursor()
        cursor.execute("""
            SELECT id, name, type, principal, interest_rate, tenure_months,
                   emi_amount, start_date, emi_day, payments_made,
                   payment_account_id, payment_type, credit_card_id,
                   lender, purpose, is_active, foreclosure_amount, created_at
            FROM loans WHERE id = ?
        """, (loan_id,))
        row = cursor.fetchone()
        return dict(row) if row else None

    def update_loan(
        self,
        loan_id: str,
        name: str = None,
        emi_amount: int = None,
        emi_day: int = None,
        payment_account_id: str = None,
        payment_type: str = None,
        credit_card_id: str = None,
        lender: str = None,
        purpose: str = None,
        is_active: bool = None,
    ) -> bool:
        """Update a loan. Returns True if successful."""
        cursor = self.conn.cursor()

        updates = []
        values = []

        if name is not None:
            updates.append("name = ?")
            values.append(name)
        if emi_amount is not None:
            updates.append("emi_amount = ?")
            values.append(emi_amount)
        if emi_day is not None:
            updates.append("emi_day = ?")
            values.append(emi_day)
        if payment_account_id is not None:
            updates.append("payment_account_id = ?")
            values.append(payment_account_id)
        if payment_type is not None:
            updates.append("payment_type = ?")
            values.append(payment_type)
        if credit_card_id is not None:
            updates.append("credit_card_id = ?")
            values.append(credit_card_id)
        if lender is not None:
            updates.append("lender = ?")
            values.append(lender)
        if purpose is not None:
            updates.append("purpose = ?")
            values.append(purpose)
        if is_active is not None:
            updates.append("is_active = ?")
            values.append(1 if is_active else 0)

        if not updates:
            return True

        values.append(loan_id)
        cursor.execute(
            f"UPDATE loans SET {', '.join(updates)} WHERE id = ?",
            values
        )
        self.conn.commit()
        return cursor.rowcount > 0

    def update_loan_payment(self, loan_id: str) -> None:
        """Increment the payment count for a loan."""
        cursor = self.conn.cursor()
        cursor.execute(
            "UPDATE loans SET payments_made = payments_made + 1 WHERE id = ?",
            (loan_id,)
        )

        # Check if loan is fully paid
        loan = self.get_loan(loan_id)
        if loan and loan["payments_made"] >= loan["tenure_months"]:
            cursor.execute(
                "UPDATE loans SET is_active = 0 WHERE id = ?",
                (loan_id,)
            )

        self.conn.commit()

    def close_loan(self, loan_id: str) -> bool:
        """Close a loan (foreclosure or completion)."""
        cursor = self.conn.cursor()
        cursor.execute(
            "UPDATE loans SET is_active = 0 WHERE id = ?",
            (loan_id,)
        )
        self.conn.commit()
        return cursor.rowcount > 0

    # ---------------------------------------------------------------------------
    # Credit Card Statements
    # ---------------------------------------------------------------------------

    def create_credit_card_statement(
        self,
        card_account_id: str,
        statement_date: date,
        due_date: date,
        statement_amount: int,
        minimum_due: int,
    ) -> str:
        """Create a new credit card statement. Returns statement ID."""
        stmt_id = str(uuid4())
        now = date.today().isoformat()

        cursor = self.conn.cursor()
        cursor.execute("""
            INSERT INTO credit_card_statements (
                id, card_account_id, statement_date, due_date,
                statement_amount, minimum_due, paid_amount, is_fully_paid, created_at
            ) VALUES (?, ?, ?, ?, ?, ?, 0, 0, ?)
        """, (
            stmt_id, card_account_id, statement_date.isoformat(),
            due_date.isoformat(), statement_amount, minimum_due, now
        ))
        self.conn.commit()
        return stmt_id

    def get_credit_card_statements(
        self,
        card_account_id: str = None,
        unpaid_only: bool = False,
    ) -> list[dict]:
        """Get credit card statements."""
        cursor = self.conn.cursor()

        query = """
            SELECT id, card_account_id, statement_date, due_date,
                   statement_amount, minimum_due, paid_amount, paid_date,
                   is_fully_paid, created_at
            FROM credit_card_statements
        """
        conditions = []
        params = []

        if card_account_id:
            conditions.append("card_account_id = ?")
            params.append(card_account_id)
        if unpaid_only:
            conditions.append("is_fully_paid = 0")

        if conditions:
            query += " WHERE " + " AND ".join(conditions)

        query += " ORDER BY due_date DESC"

        cursor.execute(query, params)
        return [dict(row) for row in cursor.fetchall()]

    def get_credit_card_statement(self, stmt_id: str) -> Optional[dict]:
        """Get a credit card statement by ID."""
        cursor = self.conn.cursor()
        cursor.execute("""
            SELECT id, card_account_id, statement_date, due_date,
                   statement_amount, minimum_due, paid_amount, paid_date,
                   is_fully_paid, created_at
            FROM credit_card_statements WHERE id = ?
        """, (stmt_id,))
        row = cursor.fetchone()
        return dict(row) if row else None

    def record_credit_card_payment(
        self,
        stmt_id: str,
        amount: int,
        from_account_id: str,
    ) -> str:
        """Record a payment towards a credit card statement. Returns event ID."""
        cursor = self.conn.cursor()
        stmt = self.get_credit_card_statement(stmt_id)
        if not stmt:
            raise ValueError("Statement not found")

        # Update statement
        new_paid = stmt["paid_amount"] + amount
        is_fully_paid = new_paid >= stmt["statement_amount"]

        cursor.execute("""
            UPDATE credit_card_statements
            SET paid_amount = ?, paid_date = ?, is_fully_paid = ?
            WHERE id = ?
        """, (new_paid, date.today().isoformat(), 1 if is_fully_paid else 0, stmt_id))

        # Get card account
        card = self.get_account(stmt["card_account_id"])

        # Create the payment event
        event_id = self.create_event(
            event_type=EventType.CREDIT_CARD_PAYMENT.value,
            amount=amount,
            description=f"Credit card payment - {card['name'] if card else 'Card'}",
            account_id=from_account_id,
            to_account_id=stmt["card_account_id"],
            event_date=date.today(),
        )

        # Update account balances
        if from_account_id:
            self.update_account_balance(from_account_id, -amount)
        self.update_account_balance(stmt["card_account_id"], -amount)

        self.conn.commit()
        return event_id

    def get_card_outstanding(self, card_account_id: str) -> int:
        """Get total outstanding amount on a credit card."""
        cursor = self.conn.cursor()

        # Sum of expenses on this card
        cursor.execute("""
            SELECT COALESCE(SUM(amount), 0) FROM events
            WHERE account_id = ? AND type IN ('expense', 'emi_payment')
        """, (card_account_id,))
        expenses = cursor.fetchone()[0]

        # Sum of payments to this card
        cursor.execute("""
            SELECT COALESCE(SUM(amount), 0) FROM events
            WHERE to_account_id = ? AND type = 'credit_card_payment'
        """, (card_account_id,))
        payments = cursor.fetchone()[0]

        return expenses - payments

    # ---------------------------------------------------------------------------
    # Audit Log (for detailed timeline)
    # ---------------------------------------------------------------------------

    def create_audit_log(
        self,
        action: str,
        entity_type: str,
        entity_id: str,
        entity_name: str = None,
        old_values: str = None,
        new_values: str = None,
        description: str = None,
        is_money_related: bool = False,
    ) -> str:
        """Create an audit log entry. Returns audit ID."""
        import json
        audit_id = str(uuid4())
        now = date.today().isoformat()

        cursor = self.conn.cursor()
        cursor.execute("""
            INSERT INTO audit_log (
                id, action, entity_type, entity_id, entity_name,
                old_values, new_values, description, is_money_related, created_at
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """, (
            audit_id, action, entity_type, entity_id, entity_name,
            json.dumps(old_values) if old_values else None,
            json.dumps(new_values) if new_values else None,
            description, 1 if is_money_related else 0, now
        ))
        self.conn.commit()
        return audit_id

    def get_audit_log(
        self,
        limit: int = None,
        money_related_only: bool = False,
        entity_type: str = None,
    ) -> list[dict]:
        """Get audit log entries."""
        import json
        cursor = self.conn.cursor()

        query = """
            SELECT id, action, entity_type, entity_id, entity_name,
                   old_values, new_values, description, is_money_related, created_at
            FROM audit_log
        """
        conditions = []
        params = []

        if money_related_only:
            conditions.append("is_money_related = 1")
        if entity_type:
            conditions.append("entity_type = ?")
            params.append(entity_type)

        if conditions:
            query += " WHERE " + " AND ".join(conditions)

        query += " ORDER BY created_at DESC"

        if limit:
            query += f" LIMIT {limit}"

        cursor.execute(query, params)

        results = []
        for row in cursor.fetchall():
            entry = dict(row)
            if entry["old_values"]:
                try:
                    entry["old_values"] = json.loads(entry["old_values"])
                except:
                    pass
            if entry["new_values"]:
                try:
                    entry["new_values"] = json.loads(entry["new_values"])
                except:
                    pass
            results.append(entry)
        return results

    # ---------------------------------------------------------------------------
    # CRUD Operations with Audit Trail
    # ---------------------------------------------------------------------------

    def update_friend(
        self,
        friend_id: str,
        name: str = None,
        phone: str = None,
    ) -> bool:
        """Update a friend. Returns True if successful."""
        cursor = self.conn.cursor()
        old_friend = self.get_friend(friend_id)
        if not old_friend:
            return False

        updates = []
        values = []

        if name is not None:
            updates.append("name = ?")
            values.append(name)
        if phone is not None:
            updates.append("phone = ?")
            values.append(phone)

        if not updates:
            return True

        values.append(friend_id)
        cursor.execute(
            f"UPDATE friends SET {', '.join(updates)} WHERE id = ?",
            values
        )
        self.conn.commit()

        # Log the update
        new_friend = self.get_friend(friend_id)
        self.create_audit_log(
            action="update",
            entity_type="friend",
            entity_id=friend_id,
            entity_name=new_friend["name"],
            old_values=old_friend,
            new_values=new_friend,
            description=f"Updated friend: {old_friend['name']} → {new_friend['name']}",
            is_money_related=False,
        )

        return cursor.rowcount > 0

    def delete_friend(self, friend_id: str) -> dict:
        """
        Delete a friend (unlink from transactions).
        - Friends with outstanding balance cannot be deleted
        - All past transactions are kept but friend_id is preserved for reference
        Returns the deleted friend data.
        """
        from ..core.engine import compute_friend_balances
        cursor = self.conn.cursor()

        friend = self.get_friend(friend_id)
        if not friend:
            raise ValueError("Friend not found")

        # Check if friend has outstanding balance
        events = self.get_events_for_engine()
        balances = compute_friend_balances(events)
        friend_balance = balances.get(friend_id, 0)

        if friend_balance != 0:
            raise ValueError(
                f"Cannot delete friend with outstanding balance (₹{abs(friend_balance)/100:.2f})"
            )

        # Delete friend but keep transactions intact (friend_id remains for reference)
        cursor.execute("DELETE FROM friends WHERE id = ?", (friend_id,))
        self.conn.commit()

        # Log the deletion
        self.create_audit_log(
            action="delete",
            entity_type="friend",
            entity_id=friend_id,
            entity_name=friend["name"],
            old_values=friend,
            description=f"Deleted friend: {friend['name']} (transactions preserved)",
            is_money_related=False,
        )

        return friend

    def delete_account(self, account_id: str, permanent: bool = False) -> dict:
        """
        Delete/deactivate an account.
        - Soft delete (is_active=0) by default, keeps all data
        - Past transactions are kept with account_id preserved
        Returns the account data.
        """
        cursor = self.conn.cursor()

        account = self.get_account(account_id)
        if not account:
            raise ValueError("Account not found")

        if account["is_default"]:
            raise ValueError("Cannot delete the default account")

        if permanent:
            # Unlink transactions (set account_id to null)
            cursor.execute(
                "UPDATE events SET account_id = NULL WHERE account_id = ?",
                (account_id,)
            )
            cursor.execute(
                "UPDATE events SET from_account_id = NULL WHERE from_account_id = ?",
                (account_id,)
            )
            cursor.execute(
                "UPDATE events SET to_account_id = NULL WHERE to_account_id = ?",
                (account_id,)
            )
            cursor.execute("DELETE FROM accounts WHERE id = ?", (account_id,))
            action = "delete"
        else:
            # Soft delete
            cursor.execute(
                "UPDATE accounts SET is_active = 0 WHERE id = ?",
                (account_id,)
            )
            action = "close"

        self.conn.commit()

        # Log the deletion
        self.create_audit_log(
            action=action,
            entity_type="account",
            entity_id=account_id,
            entity_name=account["name"],
            old_values=account,
            description=f"{'Deleted' if permanent else 'Closed'} account: {account['name']}",
            is_money_related=True,
        )

        return account

    def delete_event(self, event_id: str) -> dict:
        """
        Delete an event and reverse account balance impact.
        Returns the deleted event data.
        """
        cursor = self.conn.cursor()

        # Get event first
        cursor.execute("""
            SELECT id, type, amount, category, description, friend_id,
                   account_id, from_account_id, to_account_id, event_date, created_at
            FROM events WHERE id = ?
        """, (event_id,))
        row = cursor.fetchone()
        if not row:
            raise ValueError("Event not found")

        event = dict(row)

        # Reverse account balance impact
        account_id = event.get("account_id")
        event_type = event["type"]
        amount = event["amount"]

        if account_id:
            if event_type == EventType.EXPENSE.value:
                # Expense removed - add back to account
                self.update_account_balance(account_id, amount)
            elif event_type == EventType.INCOME.value:
                # Income removed - subtract from account
                self.update_account_balance(account_id, -amount)
            elif event_type == EventType.RECEIVABLE.value:
                # Paid for friend removed - add back
                self.update_account_balance(account_id, amount)
            elif event_type == EventType.SETTLEMENT_PAID.value:
                # Settlement paid removed - add back
                self.update_account_balance(account_id, amount)
            elif event_type == EventType.SETTLEMENT_RECEIVED.value:
                # Settlement received removed - subtract
                self.update_account_balance(account_id, -amount)
            elif event_type == EventType.EMI_PAYMENT.value:
                # EMI removed - add back
                self.update_account_balance(account_id, amount)
            elif event_type == EventType.CREDIT_CARD_PAYMENT.value:
                # CC payment removed - add back
                self.update_account_balance(account_id, amount)

        # Handle transfer reversal
        if event_type == EventType.TRANSFER.value:
            from_id = event.get("from_account_id")
            to_id = event.get("to_account_id")
            if from_id:
                self.update_account_balance(from_id, amount)  # Add back to source
            if to_id:
                self.update_account_balance(to_id, -amount)  # Subtract from destination

        # Delete the event
        cursor.execute("DELETE FROM events WHERE id = ?", (event_id,))
        self.conn.commit()

        # Log the deletion
        self.create_audit_log(
            action="delete",
            entity_type="event",
            entity_id=event_id,
            entity_name=f"{event_type}: ₹{amount/100:.2f}",
            old_values=event,
            description=f"Deleted {event_type}: ₹{amount/100:.2f}" +
                       (f" - {event['description']}" if event.get('description') else ''),
            is_money_related=True,
        )

        return event

    def delete_loan(self, loan_id: str, permanent: bool = False) -> dict:
        """
        Delete or close a loan.
        - permanent=False: Close loan (keep record, mark inactive)
        - permanent=True: Delete loan and unlink transactions
        Returns the loan data.
        """
        cursor = self.conn.cursor()

        loan = self.get_loan(loan_id)
        if not loan:
            raise ValueError("Loan not found")

        if permanent:
            # Delete linked recurring transaction
            cursor.execute(
                "DELETE FROM recurring_transactions WHERE linked_loan_id = ?",
                (loan_id,)
            )
            # Unlink events
            cursor.execute(
                "UPDATE events SET loan_id = NULL WHERE loan_id = ?",
                (loan_id,)
            )
            # Delete the loan
            cursor.execute("DELETE FROM loans WHERE id = ?", (loan_id,))
            action = "delete"
        else:
            # Close loan (soft delete)
            cursor.execute(
                "UPDATE loans SET is_active = 0 WHERE id = ?",
                (loan_id,)
            )
            # Also deactivate linked recurring
            cursor.execute(
                "UPDATE recurring_transactions SET is_active = 0 WHERE linked_loan_id = ?",
                (loan_id,)
            )
            action = "close"

        self.conn.commit()

        # Log the action
        self.create_audit_log(
            action=action,
            entity_type="loan",
            entity_id=loan_id,
            entity_name=loan["name"],
            old_values=loan,
            description=f"{'Deleted' if permanent else 'Closed'} loan: {loan['name']}",
            is_money_related=True,
        )

        return loan

    def delete_recurring(self, rec_id: str, permanent: bool = False) -> dict:
        """
        Delete or deactivate a recurring transaction.
        - permanent=False: Deactivate (keep record)
        - permanent=True: Delete record
        Returns the recurring transaction data.
        """
        cursor = self.conn.cursor()

        rec = self.get_recurring_transaction(rec_id)
        if not rec:
            raise ValueError("Recurring transaction not found")

        if permanent:
            # Delete pending transactions
            cursor.execute(
                "DELETE FROM pending_transactions WHERE recurring_id = ?",
                (rec_id,)
            )
            # Unlink events
            cursor.execute(
                "UPDATE events SET recurring_id = NULL WHERE recurring_id = ?",
                (rec_id,)
            )
            # Delete the recurring
            cursor.execute("DELETE FROM recurring_transactions WHERE id = ?", (rec_id,))
            action = "delete"
        else:
            # Soft delete
            cursor.execute(
                "UPDATE recurring_transactions SET is_active = 0 WHERE id = ?",
                (rec_id,)
            )
            action = "close"

        self.conn.commit()

        # Log the action
        self.create_audit_log(
            action=action,
            entity_type="recurring",
            entity_id=rec_id,
            entity_name=rec["name"],
            old_values=rec,
            description=f"{'Deleted' if permanent else 'Deactivated'} recurring: {rec['name']}",
            is_money_related=True,
        )

        return rec
