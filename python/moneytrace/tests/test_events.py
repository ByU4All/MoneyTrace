"""
Tests for /api/events endpoints.

Simple smoke tests - verify endpoints work, not deep business logic.
"""

import pytest


def test_create_expense_event(client):
    """Test creating a basic expense event."""
    response = client.post("/api/events", json={
        "event_type": "expense",
        "amount": 5000,
        "category": "food",
        "note": "Lunch"
    })

    assert response.status_code == 201
    data = response.json()
    assert data["event_type"] == "expense"
    assert data["amount"] == 5000
    assert data["category"] == "food"
    assert data["note"] == "Lunch"
    assert "id" in data
    assert "timestamp" in data


def test_create_income_event(client):
    """Test creating a budget adjustment event (equivalent to income)."""
    response = client.post("/api/events", json={
        "event_type": "budget_adjustment",
        "amount": 100000,
        "category": "salary",
        "note": "Monthly salary"
    })

    assert response.status_code == 201
    data = response.json()
    assert data["event_type"] == "budget_adjustment"
    assert data["amount"] == 100000


def test_create_event_with_friend(client, sample_friend):
    """Test creating an event linked to a friend (liability)."""
    response = client.post("/api/events", json={
        "event_type": "liability_created",
        "amount": 2000,
        "category": "loan",
        "note": "Borrowed money from friend",
        "friend_id": sample_friend["id"]
    })

    assert response.status_code == 201
    data = response.json()
    assert data["friend_id"] == sample_friend["id"]


def test_list_events_empty(client):
    """Test listing events when none exist."""
    response = client.get("/api/events")

    assert response.status_code == 200
    data = response.json()
    assert isinstance(data, list)
    assert len(data) == 0


def test_list_events_with_data(client, sample_event):
    """Test listing events after creating some."""
    response = client.get("/api/events")

    assert response.status_code == 200
    data = response.json()
    assert isinstance(data, list)
    assert len(data) >= 1
    assert any(e["id"] == sample_event["id"] for e in data)


def test_create_event_invalid_type(client):
    """Test creating event with invalid event_type."""
    response = client.post("/api/events", json={
        "event_type": "invalid_type",
        "amount": 1000,
        "category": "test"
    })

    # Should fail validation or business logic
    assert response.status_code in [400, 422]


def test_create_event_missing_required_fields(client):
    """Test creating event without required fields."""
    response = client.post("/api/events", json={
        "event_type": "expense"
        # Missing amount and category
    })

    assert response.status_code == 422  # Validation error

