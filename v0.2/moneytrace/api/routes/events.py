"""
Event endpoints.

POST   /events          - Create a new event
GET    /events          - List all events
DELETE /events/{id}     - Delete an event
GET    /timeline        - Get activity timeline (detailed or money-only)
"""

from datetime import date
from fastapi import APIRouter, HTTPException, Query

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
        EventType.INCOME.value,
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

    # Validate transfer accounts
    if event.type == EventType.TRANSFER.value:
        if not event.from_account_id or not event.to_account_id:
            raise HTTPException(
                status_code=400,
                detail="Both from_account_id and to_account_id are required for transfers"
            )

    try:
        db = get_db()
        account_id = event.account_id

        # Update account balances based on event type
        # This creates a closed system where money is tracked properly
        if account_id:
            if event.type == EventType.EXPENSE.value:
                # Money goes out of account
                db.update_account_balance(account_id, -event.amount)
            elif event.type == EventType.INCOME.value:
                # Money comes into account
                db.update_account_balance(account_id, event.amount)
            elif event.type == EventType.LIABILITY.value:
                # Friend paid for me - no change to my account (I owe them)
                # The money didn't come from my account
                pass
            elif event.type == EventType.RECEIVABLE.value:
                # I paid for friend - money goes out of my account
                db.update_account_balance(account_id, -event.amount)
            elif event.type == EventType.SETTLEMENT_PAID.value:
                # I'm paying back friend - money goes out of my account
                db.update_account_balance(account_id, -event.amount)
            elif event.type == EventType.SETTLEMENT_RECEIVED.value:
                # Friend paid me back - money comes into my account
                db.update_account_balance(account_id, event.amount)
            elif event.type == EventType.EMI_PAYMENT.value:
                # EMI deducted from account
                db.update_account_balance(account_id, -event.amount)
            elif event.type == EventType.CREDIT_CARD_PAYMENT.value:
                # Money goes out to pay card
                db.update_account_balance(account_id, -event.amount)

        event_id = db.create_event(
            event_type=event.type,
            amount=event.amount,
            category=event.category,
            description=event.description,
            friend_id=event.friend_id,
            account_id=event.account_id,
            from_account_id=event.from_account_id,
            to_account_id=event.to_account_id,
            event_date=event.event_date or date.today(),
        )

        return EventResponse(
            id=event_id,
            type=event.type,
            amount=event.amount,
            category=event.category,
            description=event.description,
            friend_id=event.friend_id,
            account_id=event.account_id,
            from_account_id=event.from_account_id,
            to_account_id=event.to_account_id,
            event_date=event.event_date or date.today(),
        )
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to create event: {str(e)}")


@router.get("", response_model=list[EventResponse])
def list_events(
    limit: int = Query(None, description="Max number of events to return"),
    account_id: str = Query(None, description="Filter by account ID"),
):
    """Get all events, newest first. Optionally filter by account."""
    try:
        db = get_db()
        events = db.get_events(limit=limit, account_id=account_id)
        return [
            EventResponse(
                id=e["id"],
                type=e["type"],
                amount=e["amount"],
                category=e["category"],
                description=e["description"],
                friend_id=e["friend_id"],
                account_id=e.get("account_id"),
                from_account_id=e.get("from_account_id"),
                to_account_id=e.get("to_account_id"),
                event_date=e["event_date"],
            )
            for e in events
        ]
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to fetch events: {str(e)}")


@router.delete("/{event_id}")
def delete_event(event_id: str):
    """
    Delete an event and reverse its account balance impact.
    The event is permanently removed but logged in audit trail.
    """
    try:
        db = get_db()
        deleted = db.delete_event(event_id)
        return {
            "status": "ok",
            "message": f"Event deleted",
            "deleted_event": {
                "type": deleted["type"],
                "amount": deleted["amount"],
                "description": deleted.get("description"),
            }
        }
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to delete event: {str(e)}")


@router.get("/timeline")
def get_timeline(
    limit: int = Query(100, description="Max number of entries"),
    detailed: bool = Query(False, description="Include all CRUD operations, not just money transactions"),
):
    """
    Get activity timeline.
    - detailed=False: Only money-related transactions (expenses, income, etc.)
    - detailed=True: All activity including edits, deletes, account changes, etc.
    """
    try:
        db = get_db()

        if detailed:
            # Get audit log (all operations)
            audit_entries = db.get_audit_log(limit=limit, money_related_only=False)
            timeline = []
            for entry in audit_entries:
                timeline.append({
                    "id": entry["id"],
                    "type": "audit",
                    "action": entry["action"],
                    "entity_type": entry["entity_type"],
                    "entity_id": entry["entity_id"],
                    "entity_name": entry["entity_name"],
                    "description": entry["description"],
                    "is_money_related": bool(entry["is_money_related"]),
                    "date": entry["created_at"],
                    "old_values": entry.get("old_values"),
                    "new_values": entry.get("new_values"),
                })
            return {"timeline": timeline, "detailed": True}
        else:
            # Get events only (money transactions)
            events = db.get_events(limit=limit)
            timeline = []
            for e in events:
                timeline.append({
                    "id": e["id"],
                    "type": "event",
                    "event_type": e["type"],
                    "amount": e["amount"],
                    "category": e.get("category"),
                    "description": e.get("description"),
                    "account_id": e.get("account_id"),
                    "friend_id": e.get("friend_id"),
                    "date": e["event_date"].isoformat() if hasattr(e["event_date"], 'isoformat') else e["event_date"],
                })
            return {"timeline": timeline, "detailed": False}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to fetch timeline: {str(e)}")
