# api/routes/events.py
"""
Event endpoints.

POST /events - Create a new financial event
GET /events - List all events

Thin layer - validates input, delegates to db.py for persistence.
Engine.py remains pure (no I/O).
"""

from fastapi import APIRouter, HTTPException
from datetime import date
from ..schemas import EventCreate, EventResponse
from ..deps import get_db_connection
from ...db import create_event, get_all_events
from ...events import EventType

router = APIRouter(prefix="/events", tags=["events"])


# Valid event types from engine
VALID_EVENT_TYPES = {e.value for e in EventType}


@router.post("", response_model=EventResponse, status_code=201)
def create_event_endpoint(event_data: EventCreate):
    """Create a new event and persist to ledger."""
    try:
        # Validate event type
        if event_data.event_type not in VALID_EVENT_TYPES:
            raise HTTPException(
                status_code=400,
                detail=f"Invalid event_type. Must be one of: {', '.join(VALID_EVENT_TYPES)}"
            )

        with get_db_connection() as conn:
            # Prepare event data for db
            event_dict = {
                "type": event_data.event_type,
                "amount": event_data.amount,
                "category": event_data.category,
                "description": event_data.note,
                "friend_id": event_data.friend_id,
                "event_date": date.today(),  # Use current date
            }

            # Persist to database
            event_id = create_event(conn, event_dict)

            # Return response
            return EventResponse(
                id=event_id,
                timestamp=date.today(),
                event_type=event_data.event_type,
                amount=event_data.amount,
                category=event_data.category,
                note=event_data.note,
                friend_id=event_data.friend_id,
                parent_event_id=event_data.parent_event_id,
            )
    except HTTPException:
        raise
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to create event: {str(e)}")


@router.get("", response_model=list[EventResponse])
def list_events_endpoint():
    """Get all events from the ledger."""
    try:
        with get_db_connection() as conn:
            events = get_all_events(conn)
            return [
                EventResponse(
                    id=e["id"],
                    timestamp=e["event_date"],
                    event_type=e["type"],
                    amount=e["amount"],
                    category=e["category"],
                    note=e["description"],
                    friend_id=e["friend_id"],
                    parent_event_id=None,  # Not stored in current schema
                )
                for e in events
            ]
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to fetch events: {str(e)}")



