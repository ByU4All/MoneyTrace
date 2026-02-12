"""
Account management endpoints.

GET    /accounts           - List all accounts
POST   /accounts           - Create account
GET    /accounts/{id}      - Get account details
PUT    /accounts/{id}      - Update account
DELETE /accounts/{id}      - Deactivate account
GET    /accounts/{id}/events - Get account transactions
POST   /accounts/transfer  - Transfer between accounts
"""

from datetime import date
from fastapi import APIRouter, HTTPException

from ..schemas import (
    AccountCreate, AccountUpdate, AccountResponse,
    TransferCreate, EventResponse
)
from ..deps import get_db
from ...core.events import EventType, AccountType

router = APIRouter(prefix="/accounts", tags=["accounts"])

# Valid account types
VALID_ACCOUNT_TYPES = {e.value for e in AccountType}


@router.post("", response_model=AccountResponse, status_code=201)
def create_account(account: AccountCreate):
    """Create a new account."""
    if account.type not in VALID_ACCOUNT_TYPES:
        raise HTTPException(
            status_code=400,
            detail=f"Invalid account type. Must be one of: {', '.join(VALID_ACCOUNT_TYPES)}"
        )

    try:
        db = get_db()

        is_credit = account.type == AccountType.CREDIT_CARD.value

        account_id = db.create_account(
            name=account.name,
            account_type=account.type,
            institution=account.institution,
            last_4_digits=account.last_4_digits,
            color=account.color,
            icon=account.icon,
            tracked_balance=account.tracked_balance,
            current_balance=account.current_balance,
            is_credit=is_credit,
            credit_limit=account.credit_limit if is_credit else None,
            billing_day=account.billing_day if is_credit else None,
            due_day=account.due_day if is_credit else None,
        )

        acc = db.get_account(account_id)
        return AccountResponse(
            id=acc["id"],
            name=acc["name"],
            type=acc["type"],
            institution=acc["institution"],
            last_4_digits=acc["last_4_digits"],
            color=acc["color"],
            icon=acc["icon"],
            tracked_balance=bool(acc["tracked_balance"]),
            current_balance=acc["current_balance"] or 0,
            is_credit=bool(acc["is_credit"]),
            credit_limit=acc["credit_limit"],
            billing_day=acc["billing_day"],
            due_day=acc["due_day"],
            is_active=bool(acc["is_active"]),
            is_default=bool(acc["is_default"]),
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("", response_model=list[AccountResponse])
def list_accounts(include_inactive: bool = False):
    """Get all accounts."""
    try:
        db = get_db()
        accounts = db.get_accounts(include_inactive=include_inactive)
        return [
            AccountResponse(
                id=acc["id"],
                name=acc["name"],
                type=acc["type"],
                institution=acc["institution"],
                last_4_digits=acc["last_4_digits"],
                color=acc["color"],
                icon=acc["icon"],
                tracked_balance=bool(acc["tracked_balance"]),
                current_balance=acc["current_balance"] or 0,
                is_credit=bool(acc["is_credit"]),
                credit_limit=acc["credit_limit"],
                billing_day=acc["billing_day"],
                due_day=acc["due_day"],
                is_active=bool(acc["is_active"]),
                is_default=bool(acc["is_default"]),
            )
            for acc in accounts
        ]
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/{account_id}", response_model=AccountResponse)
def get_account(account_id: str):
    """Get account details."""
    try:
        db = get_db()
        acc = db.get_account(account_id)
        if not acc:
            raise HTTPException(status_code=404, detail="Account not found")

        return AccountResponse(
            id=acc["id"],
            name=acc["name"],
            type=acc["type"],
            institution=acc["institution"],
            last_4_digits=acc["last_4_digits"],
            color=acc["color"],
            icon=acc["icon"],
            tracked_balance=bool(acc["tracked_balance"]),
            current_balance=acc["current_balance"] or 0,
            is_credit=bool(acc["is_credit"]),
            credit_limit=acc["credit_limit"],
            billing_day=acc["billing_day"],
            due_day=acc["due_day"],
            is_active=bool(acc["is_active"]),
            is_default=bool(acc["is_default"]),
        )
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.put("/{account_id}", response_model=AccountResponse)
def update_account(account_id: str, update: AccountUpdate):
    """Update an account."""
    try:
        db = get_db()

        if not db.get_account(account_id):
            raise HTTPException(status_code=404, detail="Account not found")

        db.update_account(
            account_id,
            name=update.name,
            institution=update.institution,
            last_4_digits=update.last_4_digits,
            color=update.color,
            icon=update.icon,
            tracked_balance=update.tracked_balance,
            current_balance=update.current_balance,
            credit_limit=update.credit_limit,
            billing_day=update.billing_day,
            due_day=update.due_day,
            is_active=update.is_active,
        )

        acc = db.get_account(account_id)
        return AccountResponse(
            id=acc["id"],
            name=acc["name"],
            type=acc["type"],
            institution=acc["institution"],
            last_4_digits=acc["last_4_digits"],
            color=acc["color"],
            icon=acc["icon"],
            tracked_balance=bool(acc["tracked_balance"]),
            current_balance=acc["current_balance"] or 0,
            is_credit=bool(acc["is_credit"]),
            credit_limit=acc["credit_limit"],
            billing_day=acc["billing_day"],
            due_day=acc["due_day"],
            is_active=bool(acc["is_active"]),
            is_default=bool(acc["is_default"]),
        )
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.delete("/{account_id}")
def delete_account(
    account_id: str,
    permanent: bool = False,
):
    """
    Delete or deactivate an account.
    - permanent=False (default): Deactivate (keep record, transactions preserved)
    - permanent=True: Delete account and unlink all transactions
    """
    try:
        db = get_db()

        acc = db.get_account(account_id)
        if not acc:
            raise HTTPException(status_code=404, detail="Account not found")

        if acc["is_default"]:
            raise HTTPException(status_code=400, detail="Cannot delete default account")

        from ...storage.db import Database
        # Use the enhanced delete method
        deleted = db.delete_account(account_id, permanent=permanent)

        if permanent:
            return {
                "status": "ok",
                "message": f"Account '{deleted['name']}' permanently deleted",
                "transactions_unlinked": True
            }
        else:
            return {
                "status": "ok",
                "message": f"Account '{deleted['name']}' deactivated",
                "record_preserved": True
            }
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/{account_id}/events", response_model=list[EventResponse])
def get_account_events(account_id: str, limit: int = 50):
    """Get transactions for a specific account."""
    try:
        db = get_db()

        if not db.get_account(account_id):
            raise HTTPException(status_code=404, detail="Account not found")

        events = db.get_account_events(account_id, limit=limit)
        return [
            EventResponse(
                id=e["id"],
                type=e["type"],
                amount=e["amount"],
                category=e["category"],
                description=e["description"],
                friend_id=e["friend_id"],
                account_id=e["account_id"],
                from_account_id=e["from_account_id"],
                to_account_id=e["to_account_id"],
                event_date=e["event_date"],
            )
            for e in events
        ]
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/transfer", response_model=EventResponse, status_code=201)
def create_transfer(transfer: TransferCreate):
    """Transfer money between accounts."""
    try:
        db = get_db()

        # Validate accounts exist
        from_acc = db.get_account(transfer.from_account_id)
        to_acc = db.get_account(transfer.to_account_id)

        if not from_acc:
            raise HTTPException(status_code=400, detail="Source account not found")
        if not to_acc:
            raise HTTPException(status_code=400, detail="Destination account not found")
        if transfer.from_account_id == transfer.to_account_id:
            raise HTTPException(status_code=400, detail="Cannot transfer to same account")

        # Create transfer event
        event_id = db.create_event(
            event_type=EventType.TRANSFER.value,
            amount=transfer.amount,
            description=transfer.description or f"Transfer: {from_acc['name']} → {to_acc['name']}",
            from_account_id=transfer.from_account_id,
            to_account_id=transfer.to_account_id,
            event_date=transfer.event_date or date.today(),
        )

        # Update account balances
        db.update_account_balance(transfer.from_account_id, -transfer.amount)
        db.update_account_balance(transfer.to_account_id, transfer.amount)

        return EventResponse(
            id=event_id,
            type=EventType.TRANSFER.value,
            amount=transfer.amount,
            category=None,
            description=transfer.description,
            friend_id=None,
            account_id=None,
            from_account_id=transfer.from_account_id,
            to_account_id=transfer.to_account_id,
            event_date=transfer.event_date or date.today(),
        )
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
