"""
Recurring transactions endpoints.

GET    /recurring           - List recurring transactions
POST   /recurring           - Create recurring transaction
GET    /recurring/{id}      - Get details
PUT    /recurring/{id}      - Update
DELETE /recurring/{id}      - Deactivate
GET    /recurring/pending   - Get pending verifications
GET    /recurring/upcoming  - Get upcoming bills
POST   /recurring/pending/{id}/confirm - Confirm pending
POST   /recurring/pending/{id}/skip    - Skip pending
POST   /recurring/{id}/pay-early       - Pay before due date
"""

from datetime import date
from fastapi import APIRouter, HTTPException, Query

from ..schemas import (
    RecurringCreate, RecurringUpdate, RecurringResponse,
    PendingTransactionResponse, EventResponse, UpcomingBillResponse
)
from ..deps import get_db
from ...core.events import EventType, RecurringFrequency

router = APIRouter(prefix="/recurring", tags=["recurring"])

VALID_FREQUENCIES = {e.value for e in RecurringFrequency}


@router.post("", response_model=RecurringResponse, status_code=201)
def create_recurring(recurring: RecurringCreate):
    """Create a new recurring transaction."""
    if recurring.frequency not in VALID_FREQUENCIES:
        raise HTTPException(
            status_code=400,
            detail=f"Invalid frequency. Must be one of: {', '.join(VALID_FREQUENCIES)}"
        )

    try:
        db = get_db()

        rec_id = db.create_recurring_transaction(
            name=recurring.name,
            transaction_type=recurring.type,
            amount=recurring.amount,
            category=recurring.category,
            account_id=recurring.account_id,
            frequency=recurring.frequency,
            day_of_month=recurring.day_of_month,
            day_of_week=recurring.day_of_week,
            start_date=recurring.start_date,
            end_date=recurring.end_date,
            requires_verification=recurring.requires_verification,
            auto_apply=recurring.auto_apply,
            is_autopay=recurring.is_autopay,
        )

        rec = db.get_recurring_transaction(rec_id)
        return _format_recurring(rec)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("", response_model=list[RecurringResponse])
def list_recurring(active_only: bool = True):
    """Get all recurring transactions."""
    try:
        db = get_db()
        recurrings = db.get_recurring_transactions(active_only=active_only)
        return [_format_recurring(r) for r in recurrings]
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/pending", response_model=list[PendingTransactionResponse])
def get_pending_transactions():
    """Get pending transactions awaiting verification."""
    try:
        db = get_db()
        pending = db.get_pending_transactions()
        return [
            PendingTransactionResponse(
                id=p["id"],
                recurring_id=p["recurring_id"],
                name=p["name"],
                type=p["type"],
                amount=p["amount"],
                category=p["category"],
                account_id=p["account_id"],
                due_date=p["due_date"],
                status=p["status"],
            )
            for p in pending
        ]
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/due")
def get_due_transactions():
    """Get recurring transactions that are due (for processing)."""
    try:
        db = get_db()
        due = db.get_due_recurring_transactions()

        # Create pending transactions for those requiring verification
        created = []
        for rec in due:
            if rec["requires_verification"]:
                pending_id = db.create_pending_transaction(
                    recurring_id=rec["id"],
                    due_date=date.fromisoformat(rec["next_due_date"]) if rec["next_due_date"] else date.today(),
                    amount=rec["amount"],
                )
                created.append(pending_id)
            elif rec["auto_apply"]:
                # Auto-apply without verification
                db.create_event(
                    event_type=rec["type"],
                    amount=rec["amount"],
                    category=rec["category"],
                    description=f"Auto: {rec['name']}",
                    account_id=rec["account_id"],
                    recurring_id=rec["id"],
                    loan_id=rec["linked_loan_id"],
                    event_date=date.fromisoformat(rec["next_due_date"]) if rec["next_due_date"] else date.today(),
                )
                db.update_recurring_transaction_applied(rec["id"])

        return {
            "due_count": len(due),
            "pending_created": len(created),
            "auto_applied": len(due) - len(created),
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/{rec_id}", response_model=RecurringResponse)
def get_recurring(rec_id: str):
    """Get a recurring transaction by ID."""
    try:
        db = get_db()
        rec = db.get_recurring_transaction(rec_id)
        if not rec:
            raise HTTPException(status_code=404, detail="Recurring transaction not found")
        return _format_recurring(rec)
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.put("/{rec_id}", response_model=RecurringResponse)
def update_recurring(rec_id: str, updates: RecurringUpdate):
    """Update a recurring transaction."""
    try:
        db = get_db()
        rec = db.get_recurring_transaction(rec_id)
        if not rec:
            raise HTTPException(status_code=404, detail="Recurring transaction not found")

        # Build update dict from provided fields
        update_data = {}
        if updates.name is not None:
            update_data["name"] = updates.name
        if updates.amount is not None:
            update_data["amount"] = updates.amount
        if updates.category is not None:
            update_data["category"] = updates.category
        if updates.account_id is not None:
            update_data["account_id"] = updates.account_id
        if updates.frequency is not None:
            if updates.frequency not in VALID_FREQUENCIES:
                raise HTTPException(
                    status_code=400,
                    detail=f"Invalid frequency. Must be one of: {', '.join(VALID_FREQUENCIES)}"
                )
            update_data["frequency"] = updates.frequency
        if updates.day_of_month is not None:
            update_data["day_of_month"] = updates.day_of_month
        if updates.day_of_week is not None:
            update_data["day_of_week"] = updates.day_of_week
        if updates.end_date is not None:
            update_data["end_date"] = updates.end_date.isoformat()
        if updates.requires_verification is not None:
            update_data["requires_verification"] = updates.requires_verification
        if updates.auto_apply is not None:
            update_data["auto_apply"] = updates.auto_apply
        if updates.is_autopay is not None:
            update_data["is_autopay"] = updates.is_autopay
        if updates.is_active is not None:
            update_data["is_active"] = updates.is_active

        if update_data:
            db.update_recurring_transaction(rec_id, **update_data)

        rec = db.get_recurring_transaction(rec_id)
        return _format_recurring(rec)
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.delete("/{rec_id}")
def delete_recurring(rec_id: str):
    """Deactivate a recurring transaction."""
    try:
        db = get_db()
        if not db.get_recurring_transaction(rec_id):
            raise HTTPException(status_code=404, detail="Recurring transaction not found")

        db.delete_recurring_transaction(rec_id)
        return {"status": "ok", "message": "Recurring transaction deactivated"}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/pending/{pending_id}/confirm", response_model=EventResponse)
def confirm_pending(pending_id: str):
    """Confirm a pending transaction and create the event."""
    try:
        db = get_db()
        event_id = db.confirm_pending_transaction(pending_id)

        events = db.get_events(limit=1)
        if events:
            e = events[0]
            return EventResponse(
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
        raise HTTPException(status_code=500, detail="Event created but not found")
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/pending/{pending_id}/skip")
def skip_pending(pending_id: str):
    """Skip a pending transaction."""
    try:
        db = get_db()
        db.skip_pending_transaction(pending_id)
        return {"status": "ok", "message": "Transaction skipped"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/upcoming", response_model=list[UpcomingBillResponse])
def get_upcoming_bills(days: int = Query(30, ge=1, le=90, description="Days ahead to look")):
    """
    Get upcoming bills (recurring transactions) within the next N days.
    Includes payment status for current cycle.
    """
    try:
        db = get_db()
        bills = db.get_upcoming_bills(days_ahead=days)
        return [
            UpcomingBillResponse(
                id=b["id"],
                name=b["name"],
                type=b["type"],
                amount=b["amount"],
                category=b.get("category"),
                next_due_date=b["next_due_date"],
                due_date_formatted=b["due_date_formatted"],
                days_until_due=b["days_until_due"],
                is_overdue=b["is_overdue"],
                is_autopay=bool(b.get("is_autopay", 0)),
                is_paid_this_cycle=b["is_paid_this_cycle"],
            )
            for b in bills
        ]
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/{rec_id}/pay-early", response_model=EventResponse)
def pay_recurring_early(rec_id: str, account_id: str = None):
    """
    Pay a recurring transaction before its due date.
    Creates the event immediately and advances to next cycle.
    """
    try:
        db = get_db()
        rec = db.get_recurring_transaction(rec_id)
        if not rec:
            raise HTTPException(status_code=404, detail="Recurring transaction not found")

        if not rec["is_active"]:
            raise HTTPException(status_code=400, detail="Recurring transaction is not active")

        # Check if already paid this cycle
        today = date.today()
        if rec["last_applied_date"]:
            last_applied = date.fromisoformat(rec["last_applied_date"])
            if last_applied.year == today.year and last_applied.month == today.month:
                raise HTTPException(status_code=400, detail="Already paid for current cycle")

        # Use provided account_id or the recurring's default account
        use_account_id = account_id or rec["account_id"]

        # Create the event
        event_id = db.create_event(
            event_type=rec["type"],
            amount=rec["amount"],
            category=rec["category"],
            description=f"Early payment: {rec['name']}",
            account_id=use_account_id,
            recurring_id=rec_id,
            loan_id=rec.get("linked_loan_id"),
            event_date=today,
        )

        # Mark as applied and advance to next due date
        db.update_recurring_transaction_applied(rec_id)

        # Get and return the created event
        events = db.get_events(limit=1)
        if events:
            e = events[0]
            return EventResponse(
                id=e["id"],
                type=e["type"],
                amount=e["amount"],
                category=e.get("category"),
                description=e.get("description"),
                friend_id=e.get("friend_id"),
                account_id=e.get("account_id"),
                from_account_id=e.get("from_account_id"),
                to_account_id=e.get("to_account_id"),
                event_date=date.fromisoformat(e["event_date"]),
            )

        raise HTTPException(status_code=500, detail="Event creation failed")
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


def _format_recurring(rec: dict) -> RecurringResponse:
    """Format recurring transaction for response."""
    return RecurringResponse(
        id=rec["id"],
        name=rec["name"],
        type=rec["type"],
        amount=rec["amount"],
        category=rec["category"],
        account_id=rec["account_id"],
        frequency=rec["frequency"],
        day_of_month=rec["day_of_month"],
        day_of_week=rec["day_of_week"],
        start_date=rec["start_date"],
        end_date=rec["end_date"],
        requires_verification=bool(rec["requires_verification"]),
        auto_apply=bool(rec["auto_apply"]),
        is_autopay=bool(rec.get("is_autopay", 0)),
        is_active=bool(rec["is_active"]),
        last_applied_date=rec["last_applied_date"],
        next_due_date=rec["next_due_date"],
        linked_loan_id=rec["linked_loan_id"],
    )

