"""
Summary endpoints.

GET /summary     - Monthly financial summary
GET /dashboard   - Detailed dashboard with friends & categories
GET /categories  - Category-wise spending
"""

from datetime import date
from fastapi import APIRouter, HTTPException, Query

from ..schemas import SummaryResponse, CategorySpend
from ..deps import get_db
from ...core.events import EventType
from ...core.engine import (
    compute_available_budget,
    compute_monthly_spend,
    compute_outstanding_liabilities,
    compute_outstanding_receivables,
    compute_category_spend,
    compute_friend_balances,
    compute_unpaid_commitments,
)

router = APIRouter(tags=["summary"])


@router.get("/summary", response_model=SummaryResponse)
def get_summary(
    month: int = Query(None, ge=1, le=12, description="Month (1-12), defaults to current"),
    year: int = Query(None, ge=2000, le=2100, description="Year, defaults to current"),
):
    """
    Get monthly financial summary.

    Returns budget remaining, monthly spend, and outstanding balances.
    """
    # Default to current month/year
    today = date.today()
    month = month or today.month
    year = year or today.year

    try:
        db = get_db()
        events = db.get_events_for_engine()
        base_budget = db.get_base_budget()

        return SummaryResponse(
            month=month,
            year=year,
            base_budget=base_budget,
            budget_remaining=compute_available_budget(base_budget, events),
            monthly_spend=compute_monthly_spend(events, month, year),
            outstanding_liabilities=compute_outstanding_liabilities(events),
            outstanding_receivables=compute_outstanding_receivables(events),
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/dashboard")
def get_dashboard(
    month: int = Query(None, ge=1, le=12, description="Month (1-12), defaults to current"),
    year: int = Query(None, ge=2000, le=2100, description="Year, defaults to current"),
):
    """
    Get detailed dashboard data including:
    - Budget summary
    - Friends who owe you (with amounts)
    - Friends you owe (with amounts)
    - Category spending breakdown
    """
    today = date.today()
    month = month or today.month
    year = year or today.year

    try:
        db = get_db()
        events = db.get_events_for_engine()
        base_budget = db.get_base_budget()
        friends = db.get_friends()

        # Compute friend balances
        friend_balances = compute_friend_balances(events)

        # Create friend lookup
        friend_lookup = {f["id"]: f["name"] for f in friends}

        # Separate into "owes me" and "I owe"
        friends_owe_me = []
        friends_i_owe = []

        for friend_id, balance in friend_balances.items():
            friend_name = friend_lookup.get(friend_id, "Unknown")
            if balance > 0:
                # Positive = friend owes me
                friends_owe_me.append({
                    "id": friend_id,
                    "name": friend_name,
                    "amount": balance,
                })
            elif balance < 0:
                # Negative = I owe friend
                friends_i_owe.append({
                    "id": friend_id,
                    "name": friend_name,
                    "amount": abs(balance),
                })

        # Sort by amount descending
        friends_owe_me.sort(key=lambda x: x["amount"], reverse=True)
        friends_i_owe.sort(key=lambda x: x["amount"], reverse=True)

        # Category spending
        category_totals = compute_category_spend(events, month, year)
        total_spend = sum(category_totals.values()) if category_totals else 0
        categories = [
            {
                "category": cat,
                "amount": amt,
                "percentage": round((amt / total_spend) * 100, 1) if total_spend > 0 else 0
            }
            for cat, amt in sorted(category_totals.items(), key=lambda x: x[1], reverse=True)
        ]

        # Get unpaid recurring for current month (reduces available budget)
        unpaid_recurring = db.get_unpaid_recurring_for_month(year, month)
        unpaid_commitments = compute_unpaid_commitments(unpaid_recurring)

        # Get upcoming bills (next 14 days for dashboard display)
        upcoming_bills = db.get_upcoming_bills(days_ahead=14)
        # Filter to only show unpaid ones
        upcoming_bills_display = [
            {
                "id": b["id"],
                "name": b["name"],
                "amount": b["amount"],
                "due_date": b["due_date_formatted"],
                "days_until_due": b["days_until_due"],
                "is_overdue": b["is_overdue"],
                "is_autopay": bool(b.get("is_autopay", 0)),
                "is_paid": b["is_paid_this_cycle"],
            }
            for b in upcoming_bills[:5]  # Limit to 5 for dashboard
        ]

        # Calculate budget remaining (base budget - events - unpaid recurring)
        base_budget_remaining = compute_available_budget(base_budget, events)
        actual_budget_remaining = base_budget_remaining - unpaid_commitments

        return {
            "month": month,
            "year": year,
            "base_budget": base_budget,
            "budget_remaining": actual_budget_remaining,
            "budget_before_commitments": base_budget_remaining,
            "unpaid_recurring": unpaid_commitments,
            "monthly_spend": compute_monthly_spend(events, month, year),
            "outstanding_liabilities": compute_outstanding_liabilities(events),
            "outstanding_receivables": compute_outstanding_receivables(events),
            "friends_owe_me": friends_owe_me,
            "friends_i_owe": friends_i_owe,
            "categories": categories,
            "upcoming_bills": upcoming_bills_display,
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/spending/categories", response_model=list[CategorySpend])
def get_category_spending(
    month: int = Query(None, ge=1, le=12, description="Month (1-12), defaults to current"),
    year: int = Query(None, ge=2000, le=2100, description="Year, defaults to current"),
):
    """Get category-wise spending for a month."""
    # Default to current month/year
    today = date.today()
    month = month or today.month
    year = year or today.year

    try:
        db = get_db()
        events = db.get_events_for_engine()
        category_totals = compute_category_spend(events, month, year)

        # Sort by amount descending
        sorted_categories = sorted(
            category_totals.items(),
            key=lambda x: x[1],
            reverse=True
        )

        return [
            CategorySpend(category=cat, amount=amt)
            for cat, amt in sorted_categories
        ]
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/budget/breakdown")
def get_budget_breakdown(
    month: int = Query(None, ge=1, le=12, description="Month (1-12), defaults to current"),
    year: int = Query(None, ge=2000, le=2100, description="Year, defaults to current"),
):
    """
    Get detailed budget breakdown explaining how budget remaining is calculated.

    Returns:
    - base_budget: Starting monthly budget
    - carry_over: Amount carried from previous month (if enabled)
    - expenses: Total expenses this month
    - liabilities: Outstanding amount owed to others
    - settlements_received: Money received from friends
    - adjustments: Budget adjustments made
    - remaining: Final calculated remaining budget
    """
    today = date.today()
    month = month or today.month
    year = year or today.year

    try:
        db = get_db()
        events = db.get_events_for_engine()
        base_budget = db.get_base_budget()

        # Get carry over settings
        carry_over_enabled = db.get_carry_over_enabled()
        carry_over_amount = 0

        if carry_over_enabled:
            # Check previous month record
            prev_record = db.get_previous_month_record(year, month)
            if prev_record:
                carry_over_amount = max(0, prev_record.get("ending_balance", 0))
                # Apply cap if set
                cap = db.get_carry_over_cap()
                if cap and carry_over_amount > cap:
                    carry_over_amount = cap

        # Calculate individual components
        total_expenses = 0
        total_liabilities = 0
        total_settlements_received = 0
        total_settlements_paid = 0
        total_adjustments = 0
        total_income = 0
        total_emi_payments = 0

        for e in events:
            etype = e["type"]
            amount = e["amount"]
            event_date = e.get("event_date")

            # Check if event is in current month for monthly totals
            is_current_month = event_date and event_date.month == month and event_date.year == year

            if etype == EventType.EXPENSE:
                total_expenses += amount
            elif etype == EventType.LIABILITY:
                total_liabilities += amount
            elif etype == EventType.SETTLEMENT_RECEIVED:
                total_settlements_received += amount
            elif etype == EventType.SETTLEMENT_PAID:
                total_settlements_paid += amount
            elif etype == EventType.BUDGET_ADJUSTMENT:
                total_adjustments += amount
            elif etype == EventType.INCOME:
                if is_current_month:
                    total_income += amount
            elif etype == EventType.EMI_PAYMENT:
                total_emi_payments += amount

        # Get unpaid recurring for current month
        unpaid_recurring = db.get_unpaid_recurring_for_month(year, month)
        unpaid_commitments = compute_unpaid_commitments(unpaid_recurring)

        # Format unpaid recurring for display
        unpaid_recurring_items = [
            {
                "id": r["id"],
                "name": r["name"],
                "amount": r["amount"],
                "type": r["type"],
                "due_date": r["next_due_date"],
                "days_until_due": r["days_until_due"],
                "is_autopay": bool(r.get("is_autopay", 0)),
                "is_overdue": r["is_overdue"],
            }
            for r in unpaid_recurring
        ]

        # Calculate remaining (same formula as compute_available_budget, plus unpaid commitments)
        remaining_before_commitments = base_budget + carry_over_amount + total_settlements_received + total_adjustments - total_expenses - total_liabilities - total_emi_payments
        remaining = remaining_before_commitments - unpaid_commitments

        # Net liabilities (what you still owe after settlements paid)
        net_liabilities = max(0, total_liabilities - total_settlements_paid)

        return {
            "month": month,
            "year": year,
            "breakdown": {
                "base_budget": base_budget,
                "carry_over": carry_over_amount,
                "income": total_income,
                "adjustments": total_adjustments,
                "expenses": total_expenses,
                "emi_payments": total_emi_payments,
                "liabilities_created": total_liabilities,
                "settlements_paid": total_settlements_paid,
                "settlements_received": total_settlements_received,
                "net_liabilities": net_liabilities,
                "unpaid_recurring": unpaid_commitments,
            },
            "calculation": {
                "starting": base_budget,
                "plus_carry_over": carry_over_amount,
                "plus_adjustments": total_adjustments,
                "plus_settlements_received": total_settlements_received,
                "minus_expenses": total_expenses,
                "minus_emi_payments": total_emi_payments,
                "minus_liabilities": total_liabilities,
                "minus_unpaid_recurring": unpaid_commitments,
                "equals_remaining": remaining,
            },
            "unpaid_recurring_items": unpaid_recurring_items,
            "budget_remaining": remaining,
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
