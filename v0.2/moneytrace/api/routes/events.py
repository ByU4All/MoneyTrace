"""
Event endpoints.

POST /events      - Create a new event
GET  /events      - List all events
"""

from datetime import date
from fastapi import APIRouter, HTTPException

from ..schemas import EventCreate, EventResponse
from ..deps import get_db
from ...core.events import EventType

router = APIRouter(prefix="/events", tags=["events"])

# Valid event types
VALID_TYPES = {e.value for e in EventType}


@router.post("", response_model=EventResponse, status_code=201)
def create_event(event: EventCreate):
    """Create a new financial event."""

    # Validate event type
    if event.type not in VALID_TYPES:
        raise HTTPException(
            status_code=400,
            detail=f"Invalid event type. Must be one of: {', '.join(VALID_TYPES)}"
        )

    # Validate category requirement
    needs_category = event.type in (
        EventType.EXPENSE.value,
        EventType.LIABILITY.value,
        EventType.RECEIVABLE.value,
    )
    if needs_category and not event.category:
        raise HTTPException(
            status_code=400,
            detail=f"Category is required for {event.type} events"
        )

    # Validate friend requirement
    needs_friend = event.type in (
        EventType.LIABILITY.value,
        EventType.RECEIVABLE.value,
        EventType.SETTLEMENT_PAID.value,
        EventType.SETTLEMENT_RECEIVED.value,
    )
    if needs_friend and not event.friend_id:
        raise HTTPException(
            status_code=400,
            detail=f"Friend is required for {event.type} events"
        )

    try:
        db = get_db()
        event_id = db.create_event(
            event_type=event.type,
            amount=event.amount,
            category=event.category,
            description=event.description,
            friend_id=event.friend_id,
            event_date=event.event_date or date.today(),
        )

        return EventResponse(
            id=event_id,
            type=event.type,
            amount=event.amount,
            category=event.category,
            description=event.description,
            friend_id=event.friend_id,
            event_date=event.event_date or date.today(),
        )
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to create event: {str(e)}")


@router.get("", response_model=list[EventResponse])
def list_events(limit: int = None):
    """Get all events, newest first."""
    try:
        db = get_db()
        events = db.get_events(limit=limit)
        return [
            EventResponse(
                id=e["id"],
                type=e["type"],
                amount=e["amount"],
                category=e["category"],
                description=e["description"],
                friend_id=e["friend_id"],
                event_date=e["event_date"],
            )
            for e in events
        ]
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to fetch events: {str(e)}")


