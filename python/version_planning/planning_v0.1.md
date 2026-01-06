# MoneyTrace — planning_v0.1.md

Version: 0.1.0  
Status: Planned  
Base Version: v0.0.1 (Python core, CLI + Tkinter test UI)

---

## 1. Purpose of v0.1.0

Version 0.1.0 transitions MoneyTrace from a **logic validation prototype** to a **daily-usable mobile-first application** using a **Progressive Web App (PWA)** backed by the **existing Python engine**.

This version does NOT change accounting logic.
It only changes how users interact with it.

v0.0.x proved correctness  
v0.1.x proves usability

---

## 2. What v0.1.0 Is NOT

Explicitly out of scope:

- Cloud sync
- Multi-device sync
- User accounts / authentication
- Social sharing
- Currency conversion
- Income tracking
- AI / automation
- Advanced charts
- Notifications

If a feature requires any of the above, it does not belong in v0.1.0.

---

## 3. Core Principles (Inherited, Non-Negotiable)

These principles are locked from v0.0.1 and MUST NOT change:

1. Single-user, personal-first
2. Conservative accounting  
   If money is owed, it is already gone
3. Event-driven, append-only ledger
4. Budget impact happens exactly once
5. Integer minor units only (no floats)
6. Engine is source of truth, UI is dumb
7. Explanation > automation

---

## 4. Financial Model (Canonical)

All money movement is modeled as events.

### Financial Event Impact Matrix

| Event                 | Budget Impact | Cash Impact | Purpose           |
|----------------------|---------------|-------------|-------------------|
| Expense              | −ve           | −ve         | Money spent       |
| Liability created    | −ve           | 0           | Money reserved    |
| Receivable created   | 0             | 0           | Money expected    |
| Payback (you pay)    | 0             | −ve         | Reconciliation    |
| Payback (you receive)| +ve           | +ve         | Budget relief     |

Rules:
- Budget impact happens exactly once
- Settlements never affect category spend
- Category spend tracks consumption, not money movement

---

## 5. High-Level Architecture

PWA frontend with a local Python backend.

Architecture overview:

PWA (UI)
  |
  | HTTP (local)
  v
FastAPI Backend
  |
  v
Python Core (v0.0.1)
  |
  v
SQLite

---

## 6. Why This Architecture

### Why PWA
- Installable on Android and iOS
- No app store dependency
- Full-screen, app-like UX
- Same codebase for desktop + mobile
- Sufficient for personal finance tracking

### Why FastAPI
- Python-native
- Minimal boilerplate
- Keeps accounting engine untouched
- Clear separation between UI and logic

### Why Local-Only Backend
- No auth complexity
- No privacy risk
- No infra cost
- Matches single-user philosophy

---

## 7. Backend Responsibilities (FastAPI)

The backend must remain thin.

### Backend DOES:
- Expose REST APIs
- Validate request payloads
- Persist events and friends
- Fetch data for views
- Delegate all calculations to engine.py

### Backend MUST NOT:
- Implement business logic
- Compute balances manually
- Cache derived state
- Modify engine outputs

---

## 8. API Design (Draft)

### Events

POST /events  
GET /events  

Event payload example:

{
  "type": "expense",
  "amount": 400000,
  "category": "Eating Out",
  "friend_id": null,
  "description": "Dinner",
  "event_date": "2026-01-05"
}

---

### Friends

POST /friends  
GET /friends  

Friend payload:

{
  "name": "Sugam",
  "phone": "91XXXXXXXXXX"
}

Friends are local identities only.
No accounts, no invites.

---

### Views

GET /summary?month=1&year=2026  
GET /friends/{id}/ledger  
GET /categories?month=1&year=2026  

All responses are derived using the engine.

---

## 9. Frontend Responsibilities (PWA)

### Core Screens (v0.1.0)

1. Add Event
   - Expense
   - Liability
   - Payback (paid / received)
   - Budget adjustment

2. Dashboard
   - Monthly spend
   - Budget remaining
   - Outstanding liabilities
   - Outstanding receivables

3. Friends
   - Friend list
   - Net balance per friend
   - Settlement history

4. Categories
   - Category-wise consumption (expenses only)

---

## 10. UI Rules

- UI never performs calculations
- UI never adjusts numbers
- UI only displays engine output
- No optimistic assumptions
- No silent corrections

If numbers look wrong, engine is wrong — not UI.

---

## 11. Offline Strategy

### v0.1.0
- Backend runs locally
- PWA talks to localhost
- SQLite is the single source of truth

### Later (not v0.1.0)
- IndexedDB caching
- Background sync
- Export / import

Correctness > convenience.

---

## 12. Migration from v0.0.1

### Carried Forward
- engine.py unchanged
- event definitions
- friend model
- SQLite schema
- accounting semantics

### Replaced
- Tkinter UI
- CLI as primary interface

CLI remains as a debug tool.

---

## 13. Development Order (Strict)

1. FastAPI scaffolding
2. API endpoints wired to engine
3. PWA static shell
4. Event creation UI
5. Dashboard summary
6. Friend views
7. Category views
8. PWA installability (manifest + service worker)

Skipping steps is not allowed.

---

## 14. Success Criteria for v0.1.0

v0.1.0 is successful if:

- Core logic is unchanged
- App is usable daily on mobile
- Month rollover works correctly
- Liabilities prevent overspending
- Settlements are traceable via description
- User can stop using Splitwise + Monefy

---

## 15. Versioning Meaning

0.0.x → correctness & validation  
0.1.x → usability & adoption  
0.2.x → polish & safety  
1.0.0 → real-world proven stability

---

## 16. Design Guardrails

Before adding any feature, answer:

1. What event does this create?
2. How does it affect the impact matrix?
3. Does it preserve conservative budgeting?
4. Can it be explained in one sentence?

If not, it does not ship.

---

