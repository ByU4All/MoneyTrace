# MoneyTrace v0.2.0

**Personal finance tracking for Android** — conservative budgeting, event-driven ledger.

## Features

- 📱 **Mobile-first PWA** — Installable on Android home screen
- 🐍 **Python backend** — All logic in Python (FastAPI + SQLite)
- 📴 **Fully offline** — Works without internet after setup
- 💾 **Data export** — Backup your data as JSON

## Quick Start

### On Desktop (Development)

```bash
cd v0.2

# Install dependencies
pip install -r requirements.txt

# Start server
python -m moneytrace.server

# Open http://127.0.0.1:8000
```

### On Android (Termux)

See [android/README.md](android/README.md) for detailed setup instructions.

```bash
# One-time setup
bash android/setup.sh

# Start server
python -m moneytrace.server

# Open http://127.0.0.1:8000 in Chrome
# Add to home screen for app-like experience
```

## Project Structure

```
v0.2/
├── moneytrace/
│   ├── core/           # Pure business logic (no I/O)
│   │   ├── engine.py   # Financial calculations
│   │   └── events.py   # Event type definitions
│   ├── storage/        # Data persistence
│   │   ├── db.py       # SQLite database
│   │   └── settings.py # App settings
│   ├── api/            # FastAPI REST API
│   │   ├── main.py     # App entry point
│   │   ├── deps.py     # Dependencies
│   │   ├── schemas.py  # Pydantic models
│   │   └── routes/     # API endpoints
│   ├── static/         # PWA frontend
│   │   ├── index.html
│   │   ├── css/app.css
│   │   ├── js/         # Minimal JS
│   │   └── icons/
│   └── server.py       # Server entry point
├── android/            # Termux setup files
├── pyproject.toml
└── requirements.txt
```

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/health` | Health check |
| GET | `/api/summary` | Monthly financial summary |
| GET | `/api/dashboard` | Detailed dashboard (friends, categories) |
| GET | `/api/categories` | Category spending |
| GET | `/api/categories/list` | Available categories |
| POST | `/api/events` | Create event |
| GET | `/api/events` | List events |
| POST | `/api/friends` | Create friend |
| GET | `/api/friends` | List friends with balances |
| GET | `/api/friends/{id}` | Friend details with transactions |
| GET | `/api/settings` | Get settings |
| PUT | `/api/settings` | Update settings |
| GET | `/api/export` | Export all data |
| POST | `/api/import` | Import data backup |

## Financial Model

From [idea.md](../idea.md):

| Event | Budget Impact | Cash Impact |
|-------|---------------|-------------|
| Expense | −ve | −ve |
| Liability | −ve | 0 |
| Receivable | 0 | 0 |
| Settlement (you pay) | 0 | −ve |
| Settlement (you receive) | +ve | +ve |

**Key Rules:**
- All amounts in paise (₹1 = 100 paise)
- Budget impact happens exactly once
- Conservative: If money is owed, it's already gone from budget

## Data Location

- Desktop: `~/.moneytrace/moneytrace.db`
- Android (Termux): `~/.moneytrace/moneytrace.db`

## License

MIT

