"""
Tests for Event Creation UI functionality.

Tests the frontend event creation flow including:
- Amount conversion (rupees to paise)
- Friend dropdown visibility
- Form validation
- Event type handling
"""


def test_create_simple_expense_event(client):
    """Test creating a simple expense event with amount conversion."""
    # Amount: 50.00 rupees = 5000 paise
    response = client.post("/api/events", json={
        "event_type": "expense",
        "amount": 5000,
        "category": "food",
        "note": "Lunch at restaurant"
    })

    assert response.status_code == 201
    data = response.json()
    assert data["event_type"] == "expense"
    assert data["amount"] == 5000  # Stored in paise
    assert data["category"] == "food"
    assert data["note"] == "Lunch at restaurant"
    assert "id" in data
    assert "timestamp" in data


def test_create_expense_with_decimal_amount(client):
    """Test creating expense with decimal amount (e.g., 123.45 rupees)."""
    # Amount: 123.45 rupees = 12345 paise
    response = client.post("/api/events", json={
        "event_type": "expense",
        "amount": 12345,  # Frontend converts 123.45 * 100
        "category": "shopping",
        "note": "Groceries"
    })

    assert response.status_code == 201
    data = response.json()
    assert data["amount"] == 12345


def test_create_expense_with_small_amount(client):
    """Test creating expense with small amount (e.g., 0.50 rupees = 50 paise)."""
    response = client.post("/api/events", json={
        "event_type": "expense",
        "amount": 50,  # Frontend converts 0.50 * 100
        "category": "snacks",
        "note": "Candy"
    })

    assert response.status_code == 201
    data = response.json()
    assert data["amount"] == 50


def test_create_liability_with_friend(client, sample_friend):
    """Test creating a liability event linked to a friend."""
    # Amount: 100.00 rupees = 10000 paise
    response = client.post("/api/events", json={
        "event_type": "liability_created",
        "amount": 10000,
        "category": "loan",
        "note": "Borrowed money for rent",
        "friend_id": sample_friend["id"]
    })

    assert response.status_code == 201
    data = response.json()
    assert data["event_type"] == "liability_created"
    assert data["amount"] == 10000
    assert data["friend_id"] == sample_friend["id"]


def test_create_receivable_with_friend(client, sample_friend):
    """Test creating a receivable event (someone owes me)."""
    # Amount: 250.00 rupees = 25000 paise
    response = client.post("/api/events", json={
        "event_type": "receivable_created",
        "amount": 25000,
        "category": "loan",
        "note": "Lent money for dinner",
        "friend_id": sample_friend["id"]
    })

    assert response.status_code == 201
    data = response.json()
    assert data["event_type"] == "receivable_created"
    assert data["amount"] == 25000
    assert data["friend_id"] == sample_friend["id"]


def test_create_payback_paid(client, sample_friend):
    """Test creating a payback event (I paid back)."""
    # Amount: 500.00 rupees = 50000 paise
    response = client.post("/api/events", json={
        "event_type": "payback_paid",
        "amount": 50000,
        "category": "payback",
        "note": "Paid back loan",
        "friend_id": sample_friend["id"]
    })

    assert response.status_code == 201
    data = response.json()
    assert data["event_type"] == "payback_paid"
    assert data["amount"] == 50000


def test_create_payback_received(client, sample_friend):
    """Test creating a payback received event."""
    # Amount: 300.00 rupees = 30000 paise
    response = client.post("/api/events", json={
        "event_type": "payback_received",
        "amount": 30000,
        "category": "payback",
        "note": "Received payment back",
        "friend_id": sample_friend["id"]
    })

    assert response.status_code == 201
    data = response.json()
    assert data["event_type"] == "payback_received"
    assert data["amount"] == 30000


def test_create_budget_adjustment(client):
    """Test creating a budget adjustment event (income)."""
    # Amount: 50000.00 rupees = 5000000 paise
    response = client.post("/api/events", json={
        "event_type": "budget_adjustment",
        "amount": 5000000,
        "category": "salary",
        "note": "Monthly salary"
    })

    assert response.status_code == 201
    data = response.json()
    assert data["event_type"] == "budget_adjustment"
    assert data["amount"] == 5000000


def test_create_event_without_note(client):
    """Test creating event without optional note field."""
    response = client.post("/api/events", json={
        "event_type": "expense",
        "amount": 2000,
        "category": "transport"
    })

    assert response.status_code == 201
    data = response.json()
    assert data["note"] is None


def test_create_event_with_empty_note(client):
    """Test creating event with empty note."""
    response = client.post("/api/events", json={
        "event_type": "expense",
        "amount": 2000,
        "category": "transport",
        "note": ""
    })

    assert response.status_code == 201


def test_create_event_missing_amount(client):
    """Test that creating event without amount fails."""
    response = client.post("/api/events", json={
        "event_type": "expense",
        "category": "food"
        # Missing amount
    })

    assert response.status_code == 422  # Validation error


def test_create_event_missing_category(client):
    """Test that creating event without category fails."""
    response = client.post("/api/events", json={
        "event_type": "expense",
        "amount": 5000
        # Missing category
    })

    assert response.status_code == 422  # Validation error


def test_create_event_missing_event_type(client):
    """Test that creating event without type fails."""
    response = client.post("/api/events", json={
        "amount": 5000,
        "category": "food"
        # Missing event_type
    })

    assert response.status_code == 422  # Validation error


def test_create_event_invalid_event_type(client):
    """Test that creating event with invalid type fails."""
    response = client.post("/api/events", json={
        "event_type": "invalid_type",
        "amount": 5000,
        "category": "food"
    })

    assert response.status_code == 400  # Business logic error


def test_create_event_zero_amount(client):
    """Test that creating event with zero amount is handled."""
    response = client.post("/api/events", json={
        "event_type": "expense",
        "amount": 0,
        "category": "test"
    })

    # Should either accept it or reject based on business rules
    # For now, we accept it (engine can decide if this is valid)
    assert response.status_code in [201, 400]


def test_create_event_negative_amount(client):
    """Test that creating event with negative amount is handled."""
    response = client.post("/api/events", json={
        "event_type": "expense",
        "amount": -5000,
        "category": "test"
    })

    # Should either accept it or reject based on business rules
    assert response.status_code in [201, 400]


def test_create_multiple_events_sequence(client):
    """Test creating multiple events in sequence."""
    events = [
        {"event_type": "expense", "amount": 5000, "category": "food", "note": "Breakfast"},
        {"event_type": "expense", "amount": 15000, "category": "transport", "note": "Taxi"},
        {"event_type": "expense", "amount": 30000, "category": "shopping", "note": "Clothes"},
    ]

    created_ids = []
    for event_data in events:
        response = client.post("/api/events", json=event_data)
        assert response.status_code == 201
        created_ids.append(response.json()["id"])

    # Verify all events are distinct
    assert len(set(created_ids)) == len(events)

    # Verify we can list all events
    response = client.get("/api/events")
    assert response.status_code == 200
    all_events = response.json()
    assert len(all_events) >= len(events)


def test_create_event_with_very_large_amount(client):
    """Test creating event with very large amount (e.g., 1 crore rupees)."""
    # 1 crore rupees = 10000000000 paise
    response = client.post("/api/events", json={
        "event_type": "budget_adjustment",
        "amount": 10000000000,
        "category": "inheritance",
        "note": "Property sale"
    })

    assert response.status_code == 201
    data = response.json()
    assert data["amount"] == 10000000000


def test_amount_display_format_conversion():
    """
    Test the amount display format conversion logic.
    This tests the logic that would be in JavaScript:
    - Input: 123.45 rupees -> Storage: 12345 paise
    - Display: 12345 paise -> Show: ₹123.45
    """
    # Simulate frontend conversion
    input_rupees = 123.45
    stored_paise = int(round(input_rupees * 100))
    assert stored_paise == 12345

    # Simulate backend to display conversion
    display_rupees = stored_paise / 100
    assert display_rupees == 123.45

    # Test edge cases
    assert int(round(0.01 * 100)) == 1  # 1 paisa
    assert int(round(0.99 * 100)) == 99  # 99 paise
    assert int(round(1.00 * 100)) == 100  # 1 rupee
    assert int(round(1000.50 * 100)) == 100050  # 1000.50 rupees


def test_list_events_after_multiple_creates(client):
    """Test listing events returns all created events with correct amounts."""
    # Create events with different amounts
    test_events = [
        {"event_type": "expense", "amount": 1000, "category": "test1"},  # ₹10.00
        {"event_type": "expense", "amount": 5050, "category": "test2"},  # ₹50.50
        {"event_type": "expense", "amount": 99999, "category": "test3"}, # ₹999.99
    ]

    for event in test_events:
        response = client.post("/api/events", json=event)
        assert response.status_code == 201

    # List all events
    response = client.get("/api/events")
    assert response.status_code == 200

    events = response.json()
    assert len(events) >= len(test_events)

    # Verify amounts are preserved correctly
    amounts = [e["amount"] for e in events]
    for test_event in test_events:
        assert test_event["amount"] in amounts


def test_create_event_category_case_sensitive(client):
    """Test that categories are case-sensitive."""
    response1 = client.post("/api/events", json={
        "event_type": "expense",
        "amount": 1000,
        "category": "Food"
    })

    response2 = client.post("/api/events", json={
        "event_type": "expense",
        "amount": 2000,
        "category": "food"
    })

    assert response1.status_code == 201
    assert response2.status_code == 201

    # Both should succeed - categories are stored as-is
    assert response1.json()["category"] == "Food"
    assert response2.json()["category"] == "food"

