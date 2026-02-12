# api/routes/views.py
"""
View/Summary endpoints.

GET /summary - Monthly summary
GET /categories - Category-wise spending
GET /friends/{friend_id}/balance - Friend balance

All calculations delegated to engine.py (pure functions).
"""

from fastapi import APIRouter, HTTPException, Query
from ..schemas import SummaryResponse, CategorySpendResponse, FriendBalanceResponse
from ..deps import get_db_connection, BASE_BUDGET_MINOR
from ...db import get_events_for_engine
from ...engine import (
    compute_available_budget,
    compute_monthly_spend,
    compute_outstanding_liabilities,
    compute_outstanding_receivables,
    compute_category_spend,
    compute_friend_balances,
)

router = APIRouter()


@router.get("/summary", response_model=SummaryResponse)
def get_summary(
    month: int = Query(..., ge=1, le=12, description="Month (1-12)"),
    year: int = Query(..., ge=2000, le=2100, description="Year"),
):
    """
    Get monthly summary.
    
    Returns:
    - Monthly spend (cash that left wallet)
    - Budget remaining
    - Outstanding liabilities (what you owe)
    - Outstanding receivables (what's owed to you)

    All calculations delegated to engine.py
    """
    try:
        with get_db_connection() as conn:
            # Get all events for engine
            events = get_events_for_engine(conn)

            # Use engine functions to compute everything
            budget_remaining = compute_available_budget(BASE_BUDGET_MINOR, events)
            monthly_spend = compute_monthly_spend(events, month, year)
            liabilities = compute_outstanding_liabilities(events)
            receivables = compute_outstanding_receivables(events)

            return SummaryResponse(
                month=month,
                year=year,
                monthly_spend=monthly_spend,
                budget_remaining=budget_remaining,
                outstanding_liabilities=liabilities,
                outstanding_receivables=receivables,
            )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/categories", response_model=list[CategorySpendResponse])
def get_categories(
    month: int = Query(..., ge=1, le=12, description="Month (1-12)"),
    year: int = Query(..., ge=2000, le=2100, description="Year"),
):
    """
    Get category-wise spending for a month.
    
    Only EXPENSE events count toward category spend.
    """
    try:
        with get_db_connection() as conn:
            # Get all events for engine
            events = get_events_for_engine(conn)

            # Use engine function to compute category spending
            category_totals = compute_category_spend(events, month, year)

            # Convert to response format
            return [
                CategorySpendResponse(
                    category=category,
                    amount=amount,
                )
                for category, amount in category_totals.items()
            ]
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/friends/balances", response_model=list[FriendBalanceResponse])
def get_friend_balances():
    """
    Get balance summary for all friends.

    Positive -> friend owes you
    Negative -> you owe friend
    """
    try:
        with get_db_connection() as conn:
            # Get all events for engine
            events = get_events_for_engine(conn)

            # Compute friend balances using engine
            balances = compute_friend_balances(events)

            # Convert to response format
            return [
                FriendBalanceResponse(
                    friend_id=friend_id,
                    balance=balance,
                )
                for friend_id, balance in balances.items()
            ]
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
