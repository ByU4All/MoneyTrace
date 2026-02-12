"""
pytest configuration and fixtures.
"""

import pytest
import tempfile
import os
import sqlite3
from fastapi.testclient import TestClient
from contextlib import contextmanager


@pytest.fixture(scope="function")  # Each test gets a fresh database
def temp_db():
    """Create a temporary database for testing."""
    with tempfile.NamedTemporaryFile(mode='w', suffix='.db', delete=False) as f:
        db_path = f.name

    # Initialize the database
    from ..db import init_db
    init_db(db_path)

    yield db_path

    # Cleanup
    if os.path.exists(db_path):
        os.remove(db_path)


@pytest.fixture(scope="function", autouse=False)  # Each test gets a fresh client
def client(temp_db):
    """Create a test client with temporary database."""
    from ..api.main import app
    from ..api import deps

    # Store original functions
    original_get_db_connection = deps.get_db_connection
    original_init_database = deps.init_database
    original_db_path = deps.DB_PATH

    # Override the get_db_connection to use temp database
    @contextmanager
    def override_get_db_connection():
        conn = sqlite3.connect(temp_db)
        conn.row_factory = sqlite3.Row
        try:
            yield conn
        finally:
            conn.close()

    # Override init_database to do nothing (we already initialized in temp_db fixture)
    def override_init_database():
        pass

    # Patch the module-level variables and functions
    deps.get_db_connection = override_get_db_connection
    deps.init_database = override_init_database
    deps.DB_PATH = temp_db

    # Use TestClient without auto-triggering lifespan
    test_client = TestClient(app)
    yield test_client
    test_client.close()

    # Restore original functions
    deps.get_db_connection = original_get_db_connection
    deps.init_database = original_init_database
    deps.DB_PATH = original_db_path
    app.dependency_overrides.clear()


@pytest.fixture
def sample_friend(client):
    """Create a sample friend for testing."""
    response = client.post("/api/friends", json={"name": "Test Friend"})
    assert response.status_code == 201
    return response.json()


@pytest.fixture
def sample_event(client):
    """Create a sample event for testing."""
    response = client.post("/api/events", json={
        "event_type": "expense",
        "amount": 5000,
        "category": "food",
        "note": "Test expense"
    })
    assert response.status_code == 201
    return response.json()








