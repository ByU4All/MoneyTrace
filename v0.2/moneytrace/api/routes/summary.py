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
from ...core.engine import (
    compute_available_budget,
    compute_monthly_spend,
    compute_outstanding_liabilities,
    compute_outstanding_receivables,
    compute_category_spend,
    compute_friend_balances,
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

        return {
            "month": month,
            "year": year,
            "base_budget": base_budget,
            "budget_remaining": compute_available_budget(base_budget, events),
            "monthly_spend": compute_monthly_spend(events, month, year),
            "outstanding_liabilities": compute_outstanding_liabilities(events),
            "outstanding_receivables": compute_outstanding_receivables(events),
            "friends_owe_me": friends_owe_me,
            "friends_i_owe": friends_i_owe,
            "categories": categories,
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/categories", response_model=list[CategorySpend])
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


@router.get("/categories/list")
def get_available_categories():
    """Get list of available categories."""
    try:
        db = get_db()
        return db.get_categories()
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


