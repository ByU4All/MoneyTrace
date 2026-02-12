# api/main.py
"""
FastAPI application entry point.
"""

from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi import Request
from starlette.middleware.base import BaseHTTPMiddleware
from pathlib import Path

from .routes import events, friends, views
from .deps import init_database


class NoCacheMiddleware(BaseHTTPMiddleware):
    """Disable caching for development."""
    async def dispatch(self, request: Request, call_next):
        response = await call_next(request)
        # Disable caching for JavaScript files during development
        if request.url.path.endswith('.js') or request.url.path.endswith('.css'):
            response.headers['Cache-Control'] = 'no-cache, no-store, must-revalidate'
            response.headers['Pragma'] = 'no-cache'
            response.headers['Expires'] = '0'
        return response


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application lifespan - runs on startup and shutdown."""
    # Startup
    init_database()
    print("✓ Database initialized")
    yield
    # Shutdown (nothing to do yet)


app = FastAPI(
    title="MoneyTrace API",
    description="Personal finance tracking API - conservative budgeting, event-driven ledger",
    version="0.1.0",
    lifespan=lifespan,
)

# CORS for local PWA development
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Local-only, so permissive is fine
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Disable caching for development (prevents stale JS/CSS)
app.add_middleware(NoCacheMiddleware)

# Health check endpoint (before routers and static files)
@app.get("/api/health")
def health_check():
    """Health check endpoint."""
    return {"status": "ok", "version": "0.1.0"}


# Include API routers (must come before static files)
app.include_router(events.router, prefix="/api")
app.include_router(friends.router, prefix="/api")
app.include_router(views.router, prefix="/api")

# Serve static PWA files (must be LAST - catches all remaining routes)
# Get the directory of this file, then navigate to static/pwa
static_dir = Path(__file__).parent.parent / "static" / "pwa"
static_dir = static_dir.resolve()  # Resolve to absolute path

print(f"Static directory: {static_dir}")
print(f"Static directory exists: {static_dir.exists()}")

if static_dir.exists():
    app.mount("/", StaticFiles(directory=str(static_dir), html=True), name="static")
    print(f"✓ Static files mounted from {static_dir}")
else:
    print(f"✗ Static directory not found: {static_dir}")


