"""
FastAPI application entry point.

Mobile-first API for MoneyTrace running on Termux.
"""

from contextlib import asynccontextmanager
from datetime import date
from pathlib import Path

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

from .deps import get_db, get_db_path, close_db
from ..core.budget import should_reset_budget, calculate_carry_over, calculate_month_spend


def check_and_apply_budget_reset(db) -> bool:
    """
    Check if budget should be reset and apply if needed.

    Returns True if reset was applied.
    """
    today = date.today()
    reset_day = db.get_budget_reset_day()
    last_reset = db.get_last_reset_date()
    reset_enabled = db.get_budget_reset_enabled()

    if not should_reset_budget(today, reset_day, last_reset, reset_enabled):
        return False

    # Calculate carry over from previous month if enabled
    carry_over_amount = 0
    if db.get_carry_over_enabled():
        # Get previous month record or calculate from events
        if today.month == 1:
            prev_year, prev_month = today.year - 1, 12
        else:
            prev_year, prev_month = today.year, today.month - 1

        prev_record = db.get_month_record(prev_year, prev_month)
        if prev_record:
            ending_balance = prev_record["ending_balance"]
        else:
            # Calculate from events if no record exists
            base_budget = db.get_base_budget()
            events = db.get_events_for_engine()
            spent = calculate_month_spend(events, prev_year, prev_month)
            ending_balance = base_budget - spent

        carry_over_amount = calculate_carry_over(
            ending_balance,
            db.get_carry_over_enabled(),
            db.get_carry_over_cap(),
            db.get_carry_over_negative(),
        )

    # Create month record for the new period
    base_budget = db.get_base_budget()
    db.create_month_record(
        year=today.year,
        month=today.month,
        base_budget=base_budget,
        carry_over_amount=carry_over_amount,
    )

    # Update last reset date
    db.set_last_reset_date(today)

    print(f"✓ Budget reset applied for {today.strftime('%B %Y')}")
    if carry_over_amount != 0:
        print(f"  Carry over: ₹{carry_over_amount / 100:,.0f}")

    return True


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application lifespan - startup and shutdown."""
    # Startup
    db = get_db()
    print(f"✓ Database initialized at {get_db_path()}")

    # Check for budget reset
    check_and_apply_budget_reset(db)

    yield
    # Shutdown
    close_db()


def create_app() -> FastAPI:
    """Create and configure the FastAPI application."""

    # Import routes here to avoid circular imports
    from .routes import events, friends, summary, settings, categories

    application = FastAPI(
        title="MoneyTrace",
        description="Personal finance tracking - conservative budgeting, event-driven ledger",
        version="0.3.0",
        lifespan=lifespan,
    )

    # CORS - permissive for local-only use
    application.add_middleware(
        CORSMiddleware,
        allow_origins=["*"],
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    # Health check
    @application.get("/api/health")
    def health_check():
        return {"status": "ok", "version": "0.3.0"}

    # Include API routers
    application.include_router(events.router, prefix="/api")
    application.include_router(friends.router, prefix="/api")
    application.include_router(summary.router, prefix="/api")
    application.include_router(settings.router, prefix="/api")
    application.include_router(categories.router, prefix="/api")

    # Serve static PWA files
    static_dir = Path(__file__).parent.parent / "static"
    if static_dir.exists():
        application.mount("/", StaticFiles(directory=str(static_dir), html=True), name="static")
        print(f"✓ Static files mounted from {static_dir}")

    return application


# Create app instance
app = create_app()


