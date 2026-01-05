# MoneyTrace

Personal-first expense tracking with split awareness and conservative budgeting.

> If money is owed, it is already gone.

---

## Version: 0.0.1 (Prototype / Foundation)

### Status
**Usable prototype**  
Core accounting logic is stable and validated with real scenarios.

This version exists to **prove correctness**, not to look good.

---

## 1. Problem Statement

Most expense apps fail in one of these ways:
- Splitwise: social-first, poor personal budgeting, optimistic accounting
- Budget apps: ignore liabilities and future obligations
- Finance apps: overcomplicated, rigid, or dishonest about cash reality

**MoneyTrace** is built to:
- track personal expenses honestly
- include split expenses without social friction
- prevent overspending by accounting for liabilities immediately

---

## 2. Core Philosophy (Non-Negotiable)

- Single user, local-first
- No sharing, no sync, no accounts
- Conservative accounting:
  > liabilities reduce budget immediately
- Events are append-only
- Explanation > automation

If a future feature violates these, it does not belong.

---

## 3. Financial Model (Canonical)

All money is tracked via **events**.

### Financial Event Impact Matrix

| Event                 | Budget Impact | Cash Impact | Purpose           |
| --------------------- | ------------- | ----------- | ----------------- |
| Expense               | −ve           | −ve         | Money spent       |
| Liability created     | −ve           | 0           | Money reserved    |
| Receivable created    | 0             | 0           | Money expected    |
| Payback (you pay)     | 0             | −ve         | Reconciliation    |
| Payback (you receive) | +ve           | +ve         | Budget relief     |

**Budget impact happens exactly once.**

---

## 4. What Exists in v0.0.1

### 4.1 Event Types
- Expense
- Liability created
- Receivable created
- Payback paid
- Payback received
- Budget adjustment

### 4.2 Budgeting
- Monthly base budget
- Budget resets every month
- Can go negative
- Liabilities carry across months
- Budget adjustments allow adding/removing spendable money

### 4.3 Friends
- Local-only identity
- Stored as:
  - name
  - optional phone number
- Events reference friends by `friend_id`
- Friends do **not** need the app
- Contact sync is **not** implemented yet

### 4.4 Categories
- Mandatory for expenses, liabilities, receivables
- Used only for **consumption analytics**
- Settlements are never categorized

### 4.5 Currency Handling
- All money stored as integer **minor units** (paise)
- Currency metadata is separate
- Engine is currency-agnostic
- No conversion in v0.0.1

### 4.6 Engine
- Pure Python
- No floats
- No DB assumptions
- Deterministic and testable
- Handles:
  - available budget
  - monthly spend
  - outstanding liabilities
  - outstanding receivables
  - per-friend balances
  - category spend

### 4.7 Storage
- SQLite
- Append-only `events` table
- `friends` table for identity normalization

### 4.8 Interfaces
- Minimal CLI
- Minimal Tkinter UI (test harness)
- No editing or deletion of events

---

## 5. What v0.0.1 Explicitly Does NOT Do

- No mobile app
- No cloud sync
- No user accounts
- No contact syncing
- No charts
- No bill OCR
- No automatic settlements
- No income tracking
- No multi-currency budgets

This is intentional.

---

## 6. Intended Usage (v0.0.1)

MoneyTrace v0.0.1 is meant to be:
- used by the developer daily
- stress-tested with real expenses
- validated for logical correctness

UI is disposable.  
Accounting logic is not.

---

# Roadmap

## Version: 0.1.0 (Usability Expansion)

> This version focuses on **making it practical**, not adding complexity.

Nothing here should break v0.0.1 semantics.

---

## Planned Additions in v0.1.0

### 1. Friend Management Improvements
- Friend list view
- Merge / rename friends
- Mark friend as contact
- Optional phone-based deduplication

### 2. Better Views
- Friend-wise ledger view
- Category-wise monthly breakdown
- Settlement history view
- Clear separation between:
  - spending
  - obligations
  - settlements

### 3. UX Improvements
- Dropdowns instead of free text
- Safer input validation
- Quick-add expense flow
- Current-month auto detection

### 4. Mobile Preparation
- Replace Tkinter with a mobile-capable UI (likely Kivy)
- Keep Python engine unchanged
- Local-only mobile app

### 5. Data Safety
- Manual export/import
- Simple backups
- Event replay from file

---

## Explicitly Still Out of Scope for 0.1.0

- Cloud sync
- Social features
- Real-time contact sync
- Currency conversion
- Income categorization
- Automation / AI

Those belong in later versions only if the core survives real usage.

---

## Design Rule Going Forward

> Any new feature must answer:
> 1. Which event type does this introduce?
> 2. How does it affect the impact matrix?
> 3. Does it preserve conservative budgeting?

If it can’t answer all three, it does not ship.

---

## Versioning Meaning

- **0.0.x** → correctness & model validation
- **0.1.x** → usability & daily adoption
- **1.0.0** → only when logic has survived real life

---
