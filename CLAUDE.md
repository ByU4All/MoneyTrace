# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

MoneyTrace is a personal finance tracker with two frontends:
1. **Web (v0.2)**: Python FastAPI backend + vanilla JS PWA frontend, running locally with SQLite. Designed for Android via Termux.
2. **Mobile (Flutter)**: Native Android app with Drift (SQLite), Riverpod state management, Nothing OS theme. Deployed to Nothing Phone 3a.

Both are fully offline. Currency is INR.

## Commands

```bash
# === Web (v0.2) ===
cd v0.2 && pip install -r requirements.txt
python -m moneytrace.server --reload        # Dev server (auto-reload)
python -m moneytrace.server --host 0.0.0.0  # Production
# Access: http://127.0.0.1:8000
# API docs: http://127.0.0.1:8000/docs

# === Mobile (Flutter) ===
cd mobile
flutter pub get
dart run build_runner build --delete-conflicting-outputs  # Drift codegen
flutter run                    # Debug on connected device
flutter build apk --release    # Build release APK
flutter install                # Install APK to device

# Android/Termux setup (for web version)
bash android/setup.sh
```

No automated tests exist. No linter or formatter is configured.


## Key Documentation
- [ARCHITECTURE.md](./ARCHITECTURE.md) — Project-wide architecture overview (redirects to version-specific docs)
- [MOBILE_APP.md](./MOBILE_APP.md) — Flutter mobile app: architecture, theme, build, deploy, troubleshooting
- [mobile/INSTALLATION.md](./mobile/INSTALLATION.md) — Step-by-step setup for web and Android Flutter targets
- [TODO.md](./TODO.md) — Task tracking and backlog
- [THEORY.md](./THEORY.md) — Research hypotheses and methodology
- [CHANGELOG.md](./CHANGELOG.md) — Project-wide changelog overview (redirects to version-specific docs)
- [DONTS.md](./DONTS.md) — Forbidden actions and anti-patterns (ALWAYS check before acting)


## Architecture

All source lives under `v0.2/moneytrace/`. Layered architecture:

```
static/ (PWA frontend)  →  api/ (FastAPI routes)  →  core/ (pure logic)
                                                   →  storage/ (SQLite)
```

- **`core/events.py`** — Single source of truth for all enums: EventType, AccountType, LoanType, RecurringFrequency, AuditAction, EntityType
- **`core/engine.py`** — Pure functions for budget/balance calculations. No I/O, no DB access. All financial math lives here.
- **`core/budget.py`** — Budget reset and carry-over logic
- **`storage/db.py`** (~2300 lines) — SQLite wrapper, schema creation, all queries. Context manager pattern: `with Database(path) as db:`
- **`storage/settings.py`** — Typed settings access layer
- **`api/main.py`** — FastAPI app setup, lifespan, static file serving
- **`api/deps.py`** — DB dependency injection, resolves db path (`~/.moneytrace/moneytrace.db`)
- **`api/schemas.py`** — Pydantic request/response models
- **`api/routes/`** — One file per resource: events, summary, friends, accounts, recurring, loans, creditcards, categories, settings
- **`server.py`** — Entry point, wraps uvicorn

### Frontend (static/)

Single-page app with no build step:
- **`js/app.js`** — Navigation, form binding, screen switching
- **`js/screens.js`** — UI rendering for all screens
- **`js/api.js`** — HTTP client for REST calls
- **`sw.js`** — Service worker for offline caching

## Key Domain Rules

**All amounts are integers in paise** (₹1 = 100 paise). Never use floats for money.

**Event types and their budget/cash impact** (defined in `core/events.py`, enforced in `core/engine.py`):

| Event Type | Budget | Cash |
|---|---|---|
| EXPENSE | −ve | −ve |
| LIABILITY | −ve | 0 |
| RECEIVABLE | 0 | 0 |
| SETTLEMENT_PAID | 0 | −ve |
| SETTLEMENT_RECEIVED | +ve | +ve |
| BUDGET_ADJUSTMENT | +ve | 0 |
| TRANSFER | 0 | 0 |
| INCOME | +ve | +ve |
| CREDIT_CARD_PAYMENT | 0 | −ve |
| EMI_PAYMENT | −ve | −ve |

**Budget impact happens exactly once** — settlements never double-count. Receivables are excluded from budget.

**Budget formula:**
```
Available = Base + Adjustments + Settlements Received
          - Expenses - Liabilities - EMI Payments - Unpaid Recurring
```

## Conventions

- Python 3.11+, full type hints, snake_case functions, PascalCase classes
- IDs are UUID4 strings, dates are ISO strings (TEXT in SQLite)
- API errors use FastAPI `HTTPException`; responses are JSON with amounts in paise
- CORS enabled for all origins (local-only app)
- DB uses context manager pattern; schema auto-creates on first run
- Frontend uses no framework — plain HTML/CSS/JS with dark theme

### Mobile (Flutter) — `mobile/`

```
lib/
├── core/          →  Pure business logic (ported from Python engine)
├── data/          →  Drift database, tables, DAOs
├── providers/     →  Riverpod state management
├── screens/       →  All app screens
├── theme/         →  Centralized Nothing OS theme
│   ├── colors.dart    (AppColors — all field names stable)
│   └── app_theme.dart (ThemeData + Space Grotesk font)
└── widgets/       →  Shared components
```

- **Theme is centralized**: All screens reference `AppColors.*` by name. Changing colors/theme only requires editing `colors.dart` + `app_theme.dart`.
- **Android build**: AGP 8.7.0, Kotlin 2.0.21, Gradle 8.12, Java 17, NDK 27.0.12077973
- **Requires Java 17 or 21** — Java 25 is NOT compatible with Gradle
