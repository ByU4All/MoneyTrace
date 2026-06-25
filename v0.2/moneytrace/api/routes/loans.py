"""
Loan and EMI management endpoints.

GET    /loans                    - List all loans
POST   /loans                    - Create loan
GET    /loans/{id}               - Get loan details
DELETE /loans/{id}               - Close loan
POST   /loans/{id}/pay           - Record manual EMI payment
GET    /loans/{id}/schedule      - Get amortization schedule
GET    /loans/{id}/emi-schedule  - Get variable EMI schedule
PUT    /loans/{id}/emi-schedule  - Set variable EMI schedule
DELETE /loans/{id}/emi-schedule  - Revert to fixed EMI
"""

from datetime import date
from fastapi import APIRouter, HTTPException, Query

from ..schemas import (
    LoanCreate, LoanUpdate, LoanResponse, EventResponse,
    EmiScheduleCreate, EmiScheduleResponse, EmiScheduleEntry,
)
from ..deps import get_db
from ...core.events import EventType, LoanType

router = APIRouter(prefix="/loans", tags=["loans"])

VALID_LOAN_TYPES = {e.value for e in LoanType}


@router.post("", response_model=LoanResponse, status_code=201)
def create_loan(loan: LoanCreate):
    """Create a new loan with auto-generated recurring EMI."""
    if loan.type not in VALID_LOAN_TYPES:
        raise HTTPException(
            status_code=400,
            detail=f"Invalid loan type. Must be one of: {', '.join(VALID_LOAN_TYPES)}"
        )

    try:
        db = get_db()

        loan_id = db.create_loan(
            name=loan.name,
            loan_type=loan.type,
            principal=loan.principal,
            interest_rate=loan.interest_rate,
            tenure_months=loan.tenure_months,
            emi_amount=loan.emi_amount,
            start_date=loan.start_date,
            emi_day=loan.emi_day,
            payment_account_id=loan.payment_account_id,
            payment_type=loan.payment_type,
            credit_card_id=loan.credit_card_id,
            lender=loan.lender,
            purpose=loan.purpose,
        )

        # If variable EMI schedule provided, store it
        if loan.emi_schedule:
            schedule = [
                {"month_number": e["month_number"], "emi_amount": e["emi_amount"]}
                for e in loan.emi_schedule
            ]
            db.set_loan_emi_schedule(loan_id, schedule)

        loan_data = db.get_loan(loan_id)
        return _format_loan(db, loan_data)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("", response_model=list[LoanResponse])
def list_loans(active_only: bool = True):
    """Get all loans."""
    try:
        db = get_db()
        loans = db.get_loans(active_only=active_only)
        return [_format_loan(db, loan) for loan in loans]
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/{loan_id}", response_model=LoanResponse)
def get_loan(loan_id: str):
    """Get loan details."""
    try:
        db = get_db()
        loan = db.get_loan(loan_id)
        if not loan:
            raise HTTPException(status_code=404, detail="Loan not found")
        return _format_loan(db, loan)
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.put("/{loan_id}", response_model=LoanResponse)
def update_loan(loan_id: str, updates: LoanUpdate):
    """Update a loan."""
    try:
        db = get_db()
        loan = db.get_loan(loan_id)
        if not loan:
            raise HTTPException(status_code=404, detail="Loan not found")

        # Build update dict from provided fields
        update_data = {}
        if updates.name is not None:
            update_data["name"] = updates.name
        if updates.emi_amount is not None:
            update_data["emi_amount"] = updates.emi_amount
        if updates.emi_day is not None:
            update_data["emi_day"] = updates.emi_day
        if updates.payment_account_id is not None:
            update_data["payment_account_id"] = updates.payment_account_id
        if updates.payment_type is not None:
            update_data["payment_type"] = updates.payment_type
        if updates.credit_card_id is not None:
            update_data["credit_card_id"] = updates.credit_card_id
        if updates.lender is not None:
            update_data["lender"] = updates.lender
        if updates.purpose is not None:
            update_data["purpose"] = updates.purpose
        if updates.is_active is not None:
            update_data["is_active"] = updates.is_active

        if update_data:
            db.update_loan(loan_id, **update_data)

        loan = db.get_loan(loan_id)
        return _format_loan(db, loan)
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.delete("/{loan_id}")
def close_loan(
    loan_id: str,
    permanent: bool = Query(False, description="Permanently delete the loan record")
):
    """
    Close or delete a loan.
    - permanent=False (default): Close loan (mark inactive, keep record)
    - permanent=True: Delete loan and unlink all transactions
    """
    try:
        db = get_db()
        if not db.get_loan(loan_id):
            raise HTTPException(status_code=404, detail="Loan not found")

        deleted = db.delete_loan(loan_id, permanent=permanent)

        if permanent:
            return {
                "status": "ok",
                "message": f"Loan '{deleted['name']}' permanently deleted",
                "transactions_unlinked": True
            }
        else:
            return {
                "status": "ok",
                "message": f"Loan '{deleted['name']}' closed",
                "record_preserved": True
            }
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/{loan_id}/pay", response_model=EventResponse)
def record_emi_payment(loan_id: str, amount: int = None, account_id: str = None):
    """Record a manual EMI payment."""
    try:
        db = get_db()
        loan = db.get_loan(loan_id)
        if not loan:
            raise HTTPException(status_code=404, detail="Loan not found")

        if not loan["is_active"]:
            raise HTTPException(status_code=400, detail="Loan is already closed")

        # Use schedule amount for next month if variable schedule exists
        next_month = loan["payments_made"] + 1
        default_amount = db.get_emi_for_month(loan_id, next_month)
        payment_amount = amount or default_amount
        payment_account = account_id or loan["payment_account_id"]

        # Create EMI payment event
        event_id = db.create_event(
            event_type=EventType.EMI_PAYMENT.value,
            amount=payment_amount,
            category="EMI",
            description=f"EMI: {loan['name']}",
            account_id=payment_account,
            loan_id=loan_id,
            event_date=date.today(),
        )

        # Update loan payment count
        db.update_loan_payment(loan_id)

        # Update account balance if tracked
        if payment_account:
            db.update_account_balance(payment_account, -payment_amount)

        return EventResponse(
            id=event_id,
            type=EventType.EMI_PAYMENT.value,
            amount=payment_amount,
            category="EMI",
            description=f"EMI: {loan['name']}",
            friend_id=None,
            account_id=payment_account,
            from_account_id=None,
            to_account_id=None,
            event_date=date.today(),
        )
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/{loan_id}/schedule")
def get_amortization_schedule(loan_id: str):
    """Get amortization schedule for a loan."""
    try:
        db = get_db()
        loan = db.get_loan(loan_id)
        if not loan:
            raise HTTPException(status_code=404, detail="Loan not found")

        # Amortization calculation with variable EMI support
        principal = loan["principal"]
        rate = loan["interest_rate"]
        tenure = loan["tenure_months"]
        default_emi = loan["emi_amount"]
        payments_made = loan["payments_made"]

        # Build EMI lookup from schedule if one exists
        custom_schedule = db.get_loan_emi_schedule(loan_id)
        emi_lookup = {e["month_number"]: e["emi_amount"] for e in custom_schedule}

        monthly_rate = rate / 12 / 100
        schedule = []
        balance = principal

        for i in range(tenure):
            month_num = i + 1
            emi = emi_lookup.get(month_num, default_emi)
            interest = int(balance * monthly_rate)
            principal_part = emi - interest
            balance = max(0, balance - principal_part)

            schedule.append({
                "month": month_num,
                "emi": emi,
                "principal": principal_part,
                "interest": interest,
                "balance": balance,
                "paid": i < payments_made,
            })

        return {
            "loan_id": loan_id,
            "loan_name": loan["name"],
            "total_emi": tenure,
            "paid": payments_made,
            "remaining": tenure - payments_made,
            "has_custom_schedule": len(custom_schedule) > 0,
            "schedule": schedule,
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/{loan_id}/emi-schedule", response_model=EmiScheduleResponse)
def get_emi_schedule(loan_id: str):
    """Get the variable EMI schedule for a loan."""
    try:
        db = get_db()
        loan = db.get_loan(loan_id)
        if not loan:
            raise HTTPException(status_code=404, detail="Loan not found")

        schedule = db.get_loan_emi_schedule(loan_id)
        entries = [
            EmiScheduleEntry(month_number=e["month_number"], emi_amount=e["emi_amount"])
            for e in schedule
        ]
        return EmiScheduleResponse(
            loan_id=loan_id,
            has_custom_schedule=len(entries) > 0,
            schedule=entries,
        )
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.put("/{loan_id}/emi-schedule", response_model=EmiScheduleResponse)
def set_emi_schedule(loan_id: str, data: EmiScheduleCreate):
    """Set or replace the variable EMI schedule for a loan."""
    try:
        db = get_db()
        loan = db.get_loan(loan_id)
        if not loan:
            raise HTTPException(status_code=404, detail="Loan not found")

        schedule = [
            {"month_number": e.month_number, "emi_amount": e.emi_amount}
            for e in data.schedule
        ]
        db.set_loan_emi_schedule(loan_id, schedule)

        return EmiScheduleResponse(
            loan_id=loan_id,
            has_custom_schedule=True,
            schedule=data.schedule,
        )
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.delete("/{loan_id}/emi-schedule")
def delete_emi_schedule(loan_id: str):
    """Delete the variable EMI schedule (revert to fixed EMI)."""
    try:
        db = get_db()
        loan = db.get_loan(loan_id)
        if not loan:
            raise HTTPException(status_code=404, detail="Loan not found")

        db.delete_loan_emi_schedule(loan_id)
        return {"status": "ok", "message": "Reverted to fixed EMI"}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


def _format_loan(db, loan: dict) -> LoanResponse:
    """Format loan for response, using variable schedule if available."""
    schedule = db.get_loan_emi_schedule(loan["id"])
    has_custom = len(schedule) > 0

    if has_custom:
        emi_lookup = {e["month_number"]: e["emi_amount"] for e in schedule}
        total_paid = sum(
            emi_lookup.get(m, loan["emi_amount"])
            for m in range(1, loan["payments_made"] + 1)
        )
        outstanding = sum(
            emi_lookup.get(m, loan["emi_amount"])
            for m in range(loan["payments_made"] + 1, loan["tenure_months"] + 1)
        )
    else:
        total_paid = loan["payments_made"] * loan["emi_amount"]
        outstanding = (loan["tenure_months"] - loan["payments_made"]) * loan["emi_amount"]

    payments_remaining = loan["tenure_months"] - loan["payments_made"]

    return LoanResponse(
        id=loan["id"],
        name=loan["name"],
        type=loan["type"],
        principal=loan["principal"],
        interest_rate=loan["interest_rate"],
        tenure_months=loan["tenure_months"],
        emi_amount=loan["emi_amount"],
        start_date=loan["start_date"],
        emi_day=loan["emi_day"],
        payments_made=loan["payments_made"],
        payments_remaining=payments_remaining,
        payment_account_id=loan["payment_account_id"],
        payment_type=loan["payment_type"],
        credit_card_id=loan["credit_card_id"],
        lender=loan["lender"],
        purpose=loan["purpose"],
        is_active=bool(loan["is_active"]),
        total_paid=total_paid,
        outstanding=outstanding,
        has_custom_schedule=has_custom,
    )

