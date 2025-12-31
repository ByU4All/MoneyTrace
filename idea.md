# Personal Expense + Split Tracking — V1 Canonical Specification

> This document is the **source of truth** for V1 behavior.  
> Any future feature must NOT violate these rules unless this document is updated first.

---
## Financial Event Impact Matrix (Canonical)

This table defines **exactly how each financial event affects budget and cash**.
Any future feature must conform to this matrix.

| Event                 | Budget Impact | Cash Impact | Purpose           |
| --------------------- | ------------- | ----------- | ----------------- |
| Expense               | −ve           | −ve         | Money spent       |
| Liability created     | −ve           | 0           | Money reserved    |
| Receivable created    | 0             | 0           | Money expected    |
| Payback (you pay)     | 0             | −ve         | Reconciliation    |
| Payback (you receive) | +ve           | +ve         | Budget relief     |

### Interpretation Rules
- **Budget impact happens exactly once**
- **Cash impact reflects real-world money movement**
- Settlements never double-count budget
- Receivables are informational until settled

This table is the single source of truth for all calculations.

---

## 1. Core Philosophy

- Single-user, personal-first finance tracking
- No social sharing, no permissions, no sync
- Conservative accounting:
  > If money is owed, it is already gone
- Goal is **spend control**, not social fairness or accounting perfection

---

## 2. Fundamental Concepts (Financial Primitives)

Exactly **four** primitives exist in V1.

### 2.1 Expense
Represents money that **actually left your wallet**.

- Cash impact: ❌
- Budget impact: ❌
- Categorized: ✅
- Examples:
  - Solo dinner
  - You paid the full bill (even if split)

---

### 2.2 Liability
Represents money you **owe but have not yet paid**.

- Cash impact: ⭕ (future)
- Budget impact: ❌ (immediate reduction)
- Categorized: ✅
- Examples:
  - Friend paid, you owe your share

---

### 2.3 Receivable
Represents money **others owe you**.

- Cash impact: ⭕ (future)
- Budget impact: ❌
- Categorized: ✅
- Examples:
  - You paid for others in a split

---

### 2.4 Settlement
Represents actual transfer of money that clears a Liability or Receivable.

- Cash impact: ✅
- Budget impact:
  - Payback (you pay): ❌ (already accounted)
  - Receive (they pay): ➕ (budget relief)
- Categorized: ❌
- Always linked to Liability or Receivable

---

## 3. Expense Recording Rules

### Case 1: You Paid for Group
- Record **Expense**: full amount (cash out)
- Record **Receivables**: per friend share
- Budget reduced by full amount

### Case 2: Someone Else Paid
- Record **Liability**: your share
- Budget reduced immediately
- No cash expense yet

### Case 3: Self Expense
- Record **Expense** only

---

## 4. Settlement Rules

### Paying Back (Clearing Liability)
- Record **Settlement**
- Clear Liability
- Cash out recorded
- Budget unchanged

### Receiving Payback (Clearing Receivable)
- Record **Settlement**
- Reduce Receivable
- Cash in recorded
- **Add to budget** via settlement

---

## 5. Budget System

### 5.1 Monthly Budget
- Fixed base amount per month
- Can go negative
- Always visible

### 5.2 Budget Adjustments
Used when extra money is available.

- Affects available budget only
- Does NOT affect spending stats
- Examples:
  - Cash gift
  - Refund
  - Late salary
  - Manual correction

---

### 5.3 Budget Calculation

```Available Budget = Base Monthly Budget + Sum(BudgetAdjustments) - Sum(Cash Expenses) - Sum(Outstanding Liabilities)```


Receivables are **excluded by default**.

---

## 6. Categories

- Mandatory for Expense, Liability, Receivable
- Fixed default set in V1
- Used for statistics
- Settlement has NO category

---

## 7. Friends

- Local-only entity
- Identified by name, optional phone number
- No accounts, no sync, no invitations

---

## 8. Required Fields (User Input)

### Expense
- Amount
- Date (default: today)
- Description
- Category
- Type: SELF / SPLIT

### Split-specific
- Friends
- Split shares (equal in V1)

### Liability
- Amount
- Category
- Friend
- Date

### Settlement
- Amount
- Linked Liability/Receivable
- Date

---

## 9. Monthly Stats (V1)

Must support:
- Total monthly spend (cash out)
- Budget remaining
- Outstanding liabilities
- Outstanding receivables (secondary view)

---

## 10. Explicitly Out of Scope (V1)

- User accounts
- Sync / cloud
- Multi-currency
- OCR / bill scanning
- Automatic settlements
- Notifications
- Income tracking

---

## 11. Non-Negotiable Principles

- Budget impact happens **once**
- No silent corrections
- All money movements are auditable
- Simplicity > completeness

---

## 12. Change Control

Any future change must:
1. State which rule it modifies
2. Explain why the old rule fails
3. Update this document

No exceptions.

