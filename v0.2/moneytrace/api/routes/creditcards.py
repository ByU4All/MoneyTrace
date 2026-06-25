"""
Credit card management endpoints.

GET    /credit-cards                  - List credit cards
GET    /credit-cards/{id}             - Get card details with outstanding
GET    /credit-cards/{id}/statements  - Get statements
POST   /credit-cards/{id}/statements  - Create statement
POST   /credit-cards/pay              - Pay credit card bill
"""

from datetime import date
from fastapi import APIRouter, HTTPException

from ..schemas import (
    AccountResponse, CreditCardStatementCreate,
    CreditCardStatementResponse, CreditCardPaymentRequest, EventResponse
)
from ..deps import get_db
from ...core.events import AccountType

router = APIRouter(prefix="/credit-cards", tags=["credit-cards"])


@router.get("", response_model=list[AccountResponse])
def list_credit_cards():
    """Get all credit card accounts."""
    try:
        db = get_db()
        cards = db.get_credit_cards()
        return [
            AccountResponse(
                id=card["id"],
                name=card["name"],
                type=card["type"],
                institution=card["institution"],
                last_4_digits=card["last_4_digits"],
                color=card["color"],
                icon=card["icon"],
                tracked_balance=bool(card["tracked_balance"]),
                current_balance=card["current_balance"] or 0,
                is_credit=True,
                credit_limit=card["credit_limit"],
                billing_day=card["billing_day"],
                due_day=card["due_day"],
                is_active=bool(card["is_active"]),
                is_default=bool(card["is_default"]),
            )
            for card in cards
        ]
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/{card_id}")
def get_credit_card_details(card_id: str):
    """Get credit card details with outstanding balance."""
    try:
        db = get_db()
        card = db.get_account(card_id)
        if not card or card["type"] != AccountType.CREDIT_CARD.value:
            raise HTTPException(status_code=404, detail="Credit card not found")

        outstanding = db.get_card_outstanding(card_id)
        available = (card["credit_limit"] or 0) - outstanding

        # Get unpaid statements
        unpaid = db.get_credit_card_statements(card_id, unpaid_only=True)

        return {
            "id": card["id"],
            "name": card["name"],
            "institution": card["institution"],
            "last_4_digits": card["last_4_digits"],
            "credit_limit": card["credit_limit"],
            "outstanding": outstanding,
            "available_limit": max(0, available),
            "utilization_percent": round((outstanding / card["credit_limit"]) * 100, 1) if card["credit_limit"] else 0,
            "billing_day": card["billing_day"],
            "due_day": card["due_day"],
            "unpaid_statements": len(unpaid),
            "total_due": sum(s["statement_amount"] - s["paid_amount"] for s in unpaid),
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/{card_id}/statements", response_model=list[CreditCardStatementResponse])
def get_card_statements(card_id: str, unpaid_only: bool = False):
    """Get statements for a credit card."""
    try:
        db = get_db()
        card = db.get_account(card_id)
        if not card or card["type"] != AccountType.CREDIT_CARD.value:
            raise HTTPException(status_code=404, detail="Credit card not found")

        statements = db.get_credit_card_statements(card_id, unpaid_only=unpaid_only)

        return [
            _format_statement(s, card["name"])
            for s in statements
        ]
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/{card_id}/statements", response_model=CreditCardStatementResponse, status_code=201)
def create_statement(card_id: str, statement: CreditCardStatementCreate):
    """Create a new credit card statement."""
    if statement.card_account_id != card_id:
        raise HTTPException(status_code=400, detail="Card ID mismatch")

    try:
        db = get_db()
        card = db.get_account(card_id)
        if not card or card["type"] != AccountType.CREDIT_CARD.value:
            raise HTTPException(status_code=404, detail="Credit card not found")

        stmt_id = db.create_credit_card_statement(
            card_account_id=card_id,
            statement_date=statement.statement_date,
            due_date=statement.due_date,
            statement_amount=statement.statement_amount,
            minimum_due=statement.minimum_due,
        )

        stmt = db.get_credit_card_statement(stmt_id)
        return _format_statement(stmt, card["name"])
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/pay", response_model=EventResponse)
def pay_credit_card(payment: CreditCardPaymentRequest):
    """Pay credit card bill."""
    try:
        db = get_db()

        stmt = db.get_credit_card_statement(payment.statement_id)
        if not stmt:
            raise HTTPException(status_code=404, detail="Statement not found")

        from_acc = db.get_account(payment.from_account_id)
        if not from_acc:
            raise HTTPException(status_code=400, detail="Payment account not found")

        event_id = db.record_credit_card_payment(
            stmt_id=payment.statement_id,
            amount=payment.amount,
            from_account_id=payment.from_account_id,
        )

        # Get the created event
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
        raise HTTPException(status_code=500, detail="Payment recorded but event not found")
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


def _format_statement(stmt: dict, card_name: str = None) -> CreditCardStatementResponse:
    """Format statement for response."""
    remaining = stmt["statement_amount"] - stmt["paid_amount"]
    due_date = date.fromisoformat(stmt["due_date"])
    today = date.today()
    days_until_due = (due_date - today).days if due_date >= today else None
    is_overdue = due_date < today and not stmt["is_fully_paid"]

    return CreditCardStatementResponse(
        id=stmt["id"],
        card_account_id=stmt["card_account_id"],
        card_name=card_name,
        statement_date=stmt["statement_date"],
        due_date=stmt["due_date"],
        statement_amount=stmt["statement_amount"],
        minimum_due=stmt["minimum_due"],
        paid_amount=stmt["paid_amount"],
        remaining=remaining,
        is_fully_paid=bool(stmt["is_fully_paid"]),
        days_until_due=days_until_due,
        is_overdue=is_overdue,
    )

