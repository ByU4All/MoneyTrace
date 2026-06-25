"""
FastAPI dependencies.

Database connection management and shared dependencies.
"""

from pathlib import Path
from contextlib import contextmanager
from ..storage.db import Database


# Database path - in home directory for persistent storage
def get_db_path() -> Path:
    """Get database path, creating directory if needed."""
    data_dir = Path.home() / ".moneytrace"
    data_dir.mkdir(exist_ok=True)
    return data_dir / "moneytrace.db"


def get_db() -> Database:
    """
    Get a new database connection.

    Creates a fresh connection each time to avoid SQLite threading issues.
    The Database class handles connection lifecycle.
    """
    db = Database(get_db_path())
    db.connect()
    return db


@contextmanager
def get_db_context():
    """Context manager for database connections."""
    db = get_db()
    try:
        yield db
    finally:
        db.close()


def close_db() -> None:
    """Placeholder for compatibility - connections are closed per-request."""
    pass

