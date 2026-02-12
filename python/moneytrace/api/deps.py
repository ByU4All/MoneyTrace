# api/deps.py
"""
FastAPI dependencies.

Database connections, config, etc.
"""

import sqlite3
import os
from typing import Generator
from contextlib import contextmanager
from pathlib import Path

# Database path - local SQLite
# Use absolute path relative to the moneytrace package
_db_dir = os.path.dirname(os.path.dirname(__file__))
DB_PATH = os.path.join(_db_dir, "moneytrace.db")

# Base budget in minor units (paise)
# TODO: Make this configurable
BASE_BUDGET_MINOR = 1_000_000  # ₹10,000


def init_database():
    """Initialize the database schema if not exists."""
    from ..db import init_db
    init_db(DB_PATH)


def get_db() -> str:
    """Get database path for dependency injection."""
    # Default to local data directory
    db_dir = Path.home() / ".moneytrace"
    db_dir.mkdir(exist_ok=True)
    return str(db_dir / "ledger.db")


@contextmanager
def get_db_connection() -> Generator[sqlite3.Connection, None, None]:
    """
    Get database connection.
    
    Usage:
        with get_db_connection() as conn:
            cursor = conn.cursor()
            ...
    """
    # Ensure database is initialized
    if not os.path.exists(DB_PATH):
        init_database()

    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row  # Access columns by name
    try:
        yield conn
    finally:
        conn.close()

