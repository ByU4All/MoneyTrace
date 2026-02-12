# MoneyTrace v0.1.0

Personal finance tracking - conservative budgeting, event-driven ledger.

## Structure

```
moneytrace/
├── __init__.py          # Package init
├── server.py            # Uvicorn entry point
├── engine.py            # Core accounting logic (unchanged from v0.0.1)
├── events.py            # Event type definitions
├── models.py            # Pydantic models
├── friends.py           # Friend model
├── db.py                # SQLite database functions
├── cli.py               # CLI (debug tool)
├── api/                 # FastAPI backend
│   ├── __init__.py
│   ├── main.py          # FastAPI app
│   ├── schemas.py       # API request/response schemas
│   ├── deps.py          # Dependencies (DB, config)
│   └── routes/
│       ├── events.py    # /events endpoints
│       ├── friends.py   # /friends endpoints
│       └── views.py     # /summary, /categories endpoints
├── tests/               # API tests
│   ├── conftest.py      # pytest fixtures
│   ├── test_events.py   # Event endpoint tests
│   ├── test_friends.py  # Friend endpoint tests
│   ├── test_views.py    # View endpoint tests
│   └── test_health.py   # Health check tests
└── static/pwa/          # PWA frontend
    ├── index.html       # App shell
    ├── manifest.json    # PWA manifest
    ├── sw.js            # Service worker
    ├── css/app.css      # Styles
    └── js/
        ├── api.js       # API client
        ├── screens.js   # Screen renderers
        └── app.js       # Main app logic
```

## Running

```bash
cd python
python run.py
```

Open http://127.0.0.1:8000 in your browser.

## Testing

Run all tests:
```bash
cd python
pytest
```

Run specific test file:
```bash
pytest moneytrace/tests/test_events.py
```

Run with verbose output:
```bash
pytest -v
```

The tests are smoke tests - they verify endpoints work and return expected structure, 
not deep business logic validation.

## Development Order (from planning_v0.1.md)

1. ✅ FastAPI scaffolding
2. ✅ API endpoints wired to engine
3. ✅ PWA static shell
4. ✅ Event creation UI (See STEP4_COMPLETION.md)
5. ⬜ Dashboard summary
6. ⬜ Friend views
7. ⬜ Category views
8. ⬜ PWA installability (manifest + service worker)

## Core Principles (Non-Negotiable)

1. Single-user, personal-first
2. Conservative accounting (if money is owed, it's already gone)
3. Event-driven, append-only ledger
4. Budget impact happens exactly once
5. Integer minor units only (no floats)
6. Engine is source of truth, UI is dumb
7. Explanation > automation
