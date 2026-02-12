"""
Tests for /api/summary and /api/categories endpoints.

These test that engine.py functions are properly wired to the API.
"""

import pytest
from datetime import date


def test_get_summary_basic(client):
    """Test getting monthly summary with no events."""
    current_month = date.today().month
    current_year = date.today().year

    response = client.get(f"/api/summary?month={current_month}&year={current_year}")

    assert response.status_code == 200
    data = response.json()
    assert data["month"] == current_month
    assert data["year"] == current_year
    assert data["monthly_spend"] == 0
    assert data["budget_remaining"] == 1_000_000  # BASE_BUDGET_MINOR
    assert data["outstanding_liabilities"] == 0
    assert data["outstanding_receivables"] == 0


def test_get_summary_with_expense(client):
    """Test summary after creating an expense."""
    current_month = date.today().month
    current_year = date.today().year

    # Create an expense
    client.post("/api/events", json={
        "event_type": "expense",
        "amount": 50000,
        "category": "food",
        "note": "Groceries"
    })

    response = client.get(f"/api/summary?month={current_month}&year={current_year}")

    assert response.status_code == 200
    data = response.json()
    assert data["monthly_spend"] == 50000
    assert data["budget_remaining"] == 950000  # 1_000_000 - 50000


def test_get_categories_empty(client):
    """Test getting categories when no events exist."""
    current_month = date.today().month
    current_year = date.today().year

    response = client.get(f"/api/categories?month={current_month}&year={current_year}")

    assert response.status_code == 200
    data = response.json()
    assert isinstance(data, list)
    assert len(data) == 0


def test_get_categories_with_expenses(client):
    """Test category breakdown after creating expenses."""
    current_month = date.today().month
    current_year = date.today().year

    # Create multiple expenses in different categories
    client.post("/api/events", json={
        "event_type": "expense",
        "amount": 30000,
        "category": "food",
        "note": "Groceries"
    })

    client.post("/api/events", json={
        "event_type": "expense",
        "amount": 20000,
        "category": "food",
        "note": "Restaurant"
    })

    client.post("/api/events", json={
        "event_type": "expense",
        "amount": 15000,
        "category": "transport",
        "note": "Uber"
    })

    response = client.get(f"/api/categories?month={current_month}&year={current_year}")

    assert response.status_code == 200
    data = response.json()
    assert len(data) == 2  # Two categories: food, transport

    # Find the food category
    food_cat = next((c for c in data if c["category"] == "food"), None)
    assert food_cat is not None
    assert food_cat["amount"] == 50000  # 30000 + 20000

    # Find the transport category
    transport_cat = next((c for c in data if c["category"] == "transport"), None)
    assert transport_cat is not None
    assert transport_cat["amount"] == 15000


def test_summary_invalid_month(client):
    """Test summary with invalid month parameter."""
    response = client.get("/api/summary?month=13&year=2026")
    assert response.status_code == 422  # Validation error


def test_summary_invalid_year(client):
    """Test summary with invalid year parameter."""
    response = client.get("/api/summary?month=1&year=1999")
    assert response.status_code == 422  # Validation error

