"""
FastAPI application entry point.

Mobile-first API for MoneyTrace running on Termux.
"""

from contextlib import asynccontextmanager
from pathlib import Path

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

from .deps import get_db, get_db_path, close_db


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application lifespan - startup and shutdown."""
    # Startup
    db = get_db()
    print(f"✓ Database initialized at {get_db_path()}")
    yield
    # Shutdown
    close_db()


def create_app() -> FastAPI:
    """Create and configure the FastAPI application."""

    # Import routes here to avoid circular imports
    from .routes import events, friends, summary, settings

    application = FastAPI(
        title="MoneyTrace",
        description="Personal finance tracking - conservative budgeting, event-driven ledger",
        version="0.2.0",
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
        return {"status": "ok", "version": "0.2.0"}

    # Include API routers
    application.include_router(events.router, prefix="/api")
    application.include_router(friends.router, prefix="/api")
    application.include_router(summary.router, prefix="/api")
    application.include_router(settings.router, prefix="/api")

    # Serve static PWA files
    static_dir = Path(__file__).parent.parent / "static"
    if static_dir.exists():
        application.mount("/", StaticFiles(directory=str(static_dir), html=True), name="static")
        print(f"✓ Static files mounted from {static_dir}")

    return application


# Create app instance
app = create_app()


