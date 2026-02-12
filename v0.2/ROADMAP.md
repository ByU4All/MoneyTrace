# MoneyTrace Roadmap & Future Features

> **Version**: Planning Document for v0.3.x and beyond  
> **Created**: February 12, 2026  
> **Status**: Draft for Discussion

---

## Overview

This document outlines planned features for MoneyTrace, organized by priority and complexity. Each feature includes specifications, implementation considerations, and open questions for discussion.

---

## Table of Contents

1. [Data Management](#1-data-management)
2. [Budget Reset & Scheduling](#2-budget-reset--scheduling)
3. [Recurring Transactions](#3-recurring-transactions)
4. [Carry Over Feature](#4-carry-over-feature)
5. [Category Management](#5-category-management)
6. [Multiple Accounts](#6-multiple-accounts)
7. [Credit Card Tracking](#7-credit-card-tracking)
8. [EMI & Loan Tracking](#8-emi--loan-tracking)

---

## 1. Data Management

### 1.1 Clear Past Data

**Description**: Allow user to wipe all transaction history while keeping settings.

**Specification**:
- Clear all events from database
- Optionally clear friends list
- Keep categories and settings
- Require confirmation (type "DELETE" to confirm)

**API Endpoint**:
```
POST /api/data/clear
Body: { "confirm": "DELETE", "keep_friends": true }
```

**UI**:
- Settings → Data Management → "Clear All Data"
- Show warning modal with confirmation input

---

### 1.2 Create Data Backup

**Description**: Export all data to a JSON file for backup.

**Current Status**: ✅ Already implemented via `GET /api/export`

**Enhancements Needed**:
- Add timestamp to filename
- Include app version for compatibility checking
- Option to encrypt backup with password (future)

---

### 1.3 Restore Data from Backup

**Description**: Import data from a previously exported JSON backup.

**Current Status**: ✅ Already implemented via `POST /api/import`

**Enhancements Needed**:
- Validate backup file version compatibility
- Show preview of what will be imported
- Option to merge vs replace existing data
- Progress indicator for large imports

**Open Questions**:
- Should restore completely replace data or merge?
- How to handle conflicts (same event ID exists)?

---

## 2. Budget Reset & Scheduling

### 2.1 Monthly Reset Schedule

**Description**: Automatically reset available budget on a specific day each month.

**Specification**:

| Setting | Options | Default |
|---------|---------|---------|
| Reset Day | 1-28 (avoid month-end edge cases) | 1 |
| Reset Type | Full reset / Carry over | Full reset |
| Auto-archive | Archive previous month's data | Yes |

**Data Model Addition**:
```python
# settings table
budget_reset_day: int = 1  # Day of month (1-28)
budget_reset_enabled: bool = True
last_reset_date: date = None  # Track when last reset happened
```

**Logic**:
```
On app open:
  if today >= reset_day AND last_reset_month < current_month:
    - Archive previous month (optional)
    - Reset budget to base_budget
    - Update last_reset_date
```

**Open Questions**:
- What happens to outstanding liabilities/receivables on reset?
  - Option A: Carry forward (recommended)
  - Option B: Clear (dangerous)
- Should we show a notification on reset day?

---

### 2.2 Custom Reset Period

**Description**: Support non-monthly reset cycles (weekly, bi-weekly, custom).

**Specification**:

| Cycle | Use Case |
|-------|----------|
| Weekly | Weekly allowance tracking |
| Bi-weekly | Paycheck cycle |
| Monthly | Standard (default) |
| Custom | User-defined period in days |

**Complexity**: Medium - requires rethinking how "monthly" spend is calculated

**Defer to**: v0.4.x (after monthly reset is stable)

---

## 3. Recurring Transactions

### 3.1 Core Concept

**Description**: Set up transactions that repeat on a schedule (EMI, subscriptions, salary).

**Transaction Types**:

| Type | Direction | Example |
|------|-----------|---------|
| Recurring Expense | Outflow | Netflix subscription, Rent |
| Recurring Income | Inflow | Salary, Rental income |
| EMI Payment | Outflow | Loan EMI, Credit card EMI |
| SIP/Investment | Outflow | Mutual fund SIP |

---

### 3.2 Data Model

```python
class RecurringTransaction:
    id: str
    name: str                    # "Netflix", "Salary", "Home Loan EMI"
    type: str                    # expense, income, emi, investment
    amount: int                  # Amount in paise
    category: str               
    account_id: str              # Which account (see section 6)
    
    # Schedule
    frequency: str               # daily, weekly, monthly, yearly
    day_of_month: int           # 1-28 for monthly
    day_of_week: int            # 0-6 for weekly
    start_date: date
    end_date: date | None       # None = indefinite
    
    # Verification
    requires_verification: bool  # Must confirm each occurrence
    auto_apply: bool            # Apply automatically if not verified
    
    # Status
    is_active: bool
    last_applied_date: date | None
    next_due_date: date
```

---

### 3.3 Verification Flow

**Why Verification?**  
Not all scheduled transactions happen (bank holiday, insufficient funds, etc.)

**Flow**:
```
1. On due date, show pending transactions in dashboard
2. User can:
   - ✅ Confirm (transaction recorded)
   - ❌ Skip this occurrence (not recorded)
   - ⏰ Remind later (snooze)
3. If auto_apply=true and no action by end of day:
   - Auto-record the transaction
4. If auto_apply=false and no action:
   - Show as "missed" in next session
```

**UI**:
- Dashboard banner: "3 pending transactions need confirmation"
- Swipe to confirm/skip on mobile
- Bulk confirm option

---

### 3.4 Examples

**Salary Deposit (Income)**:
```json
{
  "name": "Monthly Salary",
  "type": "income",
  "amount": 5000000,
  "category": "Salary",
  "account_id": "hdfc_savings",
  "frequency": "monthly",
  "day_of_month": 1,
  "requires_verification": true,
  "auto_apply": false
}
```

**Netflix Subscription (Expense)**:
```json
{
  "name": "Netflix",
  "type": "expense", 
  "amount": 64900,
  "category": "Entertainment",
  "account_id": "icici_credit",
  "frequency": "monthly",
  "day_of_month": 15,
  "requires_verification": false,
  "auto_apply": true
}
```

---

## 4. Carry Over Feature

### 4.1 Description

**What**: Unused budget from current month carries to next month.

**Example**:
- Base budget: ₹10,000
- Month 1 spent: ₹8,000 → ₹2,000 unused
- Month 2 budget: ₹10,000 + ₹2,000 = ₹12,000

### 4.2 Settings

| Setting | Options | Default |
|---------|---------|---------|
| Enable Carry Over | On/Off | Off |
| Carry Over Cap | Unlimited / Fixed amount / Percentage | Unlimited |
| Carry Over Direction | Positive only / Include negative | Positive only |

**"Include negative"** means: If you overspent ₹2,000, next month starts with ₹8,000.

### 4.3 Data Model

```python
# settings table
carry_over_enabled: bool = False
carry_over_cap: int | None = None  # None = unlimited, else paise
carry_over_negative: bool = False  # Carry over deficits too

# New table: month_records
class MonthRecord:
    year: int
    month: int
    base_budget: int
    carry_over_amount: int  # From previous month
    total_budget: int       # base + carry_over
    total_spent: int
    ending_balance: int     # Calculated at month end
```

### 4.4 Open Questions

- Should carry over apply to liabilities/receivables?
- What's a reasonable default cap? (50% of budget? Unlimited?)
- How to display this in UI? Show "bonus" separately?

---

## 5. Category Management

### 5.1 Current State

- 8 default categories (Food & Dining, Transport, etc.)
- Categories stored in `categories` table
- No UI to add/remove categories

### 5.2 Required Features

| Feature | Priority |
|---------|----------|
| View all categories | High |
| Add custom category | High |
| Rename category | Medium |
| Delete category | Medium (requires migration) |
| Reorder categories | Low |
| Category icons/colors | Low |

### 5.3 Delete Behavior

**Problem**: What happens to events using a deleted category?

**Options**:
1. **Prevent deletion** if category is in use
2. **Reassign** events to "Uncategorized" or selected category
3. **Soft delete** - hide but keep in database

**Recommendation**: Option 2 with user choice

### 5.4 API Endpoints

```
GET    /api/categories          # List all (existing)
POST   /api/categories          # Add new
PUT    /api/categories/{id}     # Rename
DELETE /api/categories/{id}     # Delete (with reassignment)
```

### 5.5 UI

- Settings → Categories → List with add/edit/delete
- Swipe to delete on mobile
- Color picker for visual distinction (future)

---

## 6. Multiple Accounts

### 6.1 Core Concept

Track money across different accounts/wallets.

**Account Types**:

| Type | Behavior |
|------|----------|
| Bank Account (Savings) | Normal debit/credit |
| Bank Account (Current) | Normal debit/credit |
| Cash/Wallet | Physical cash tracking |
| Debit Card | Linked to bank account |
| Credit Card | Special (see section 7) |
| UPI/Digital Wallet | PayTM, GPay balance |

### 6.2 Data Model

```python
class Account:
    id: str
    name: str                    # "HDFC Savings", "Cash Wallet"
    type: str                    # savings, current, cash, credit_card, upi
    institution: str | None      # "HDFC", "ICICI", "PayTM"
    
    # For display
    last_4_digits: str | None   # "1234" for cards
    color: str | None           # For UI distinction
    icon: str | None
    
    # Balance (optional - for reconciliation)
    tracked_balance: bool        # Whether we track running balance
    current_balance: int | None  # Manual or calculated
    
    # Credit card specific (see section 7)
    is_credit: bool
    credit_limit: int | None
    billing_day: int | None
    due_day: int | None
    
    # Status
    is_active: bool
    created_at: date
```

### 6.3 Event Changes

Add account reference to events:

```python
class Event:
    # ...existing fields...
    account_id: str | None  # Which account was used
```

### 6.4 Transfer Between Accounts

**New Event Type**: `transfer`

```python
{
    "type": "transfer",
    "amount": 500000,
    "from_account_id": "hdfc_savings",
    "to_account_id": "cash_wallet",
    "description": "ATM withdrawal"
}
```

**Budget Impact**: Zero (money moved, not spent)

### 6.5 UI Considerations

- Dashboard: Show total across all accounts OR selected account
- Account switcher in header
- Filter transactions by account
- Account management in settings

### 6.6 Open Questions

- Should we track actual balances or just transactions?
  - **Track balances**: More accurate, requires reconciliation
  - **Transactions only**: Simpler, user manages actual balances
- How to handle the default "no account" for existing events?

---

## 7. Credit Card Tracking

### 7.1 How Credit Cards Differ

| Aspect | Debit/Cash | Credit Card |
|--------|------------|-------------|
| When counted | Immediately | On use (conservative approach) |
| Budget impact | Immediate | Immediate (money is committed) |
| Payment | N/A | Must track due date |

### 7.2 Credit Card Workflow

```
1. PURCHASE (Day 5)
   - Record expense with credit card
   - Amount: ₹5,000
   - Budget impact: -₹5,000 (immediately - conservative)
   - Card balance: +₹5,000 (outstanding)

2. BILLING CYCLE CLOSES (Day 20)
   - Statement generated
   - Statement amount: ₹5,000
   - Due date: Day 10 of next month

3. PAYMENT WINDOW (Day 20 → Day 10)
   - Show countdown timer
   - Remind user to pay

4. PAYMENT (Day 8)
   - Record payment from savings account
   - Amount: ₹5,000
   - Budget impact: ₹0 (already counted at purchase)
   - Card balance: ₹0 (cleared)
   
5. PARTIAL PAYMENT
   - If only ₹3,000 paid
   - Remaining ₹2,000 shows as outstanding
   - Interest warning displayed
```

### 7.3 Data Model

```python
class CreditCardStatement:
    id: str
    card_account_id: str
    statement_date: date
    due_date: date
    statement_amount: int
    minimum_due: int
    
    # Payment tracking
    paid_amount: int = 0
    paid_date: date | None
    is_fully_paid: bool
    
    # Events included in this statement
    event_ids: list[str]
```

### 7.4 Key Calculations

**Outstanding on Card**:
```python
def card_outstanding(card_id):
    expenses = sum(events where account=card and type=expense)
    payments = sum(events where type=credit_card_payment and card=card)
    return expenses - payments
```

**Due This Month**:
```python
def amount_due(card_id):
    statement = get_current_statement(card_id)
    return statement.statement_amount - statement.paid_amount
```

### 7.5 UI Elements

- **Card Widget**: Show each credit card with:
  - Current outstanding
  - Statement amount (if in payment window)
  - Days until due date
  - "Pay Now" button

- **Payment Timer**: Visual countdown when in payment window

- **Alerts**:
  - 7 days before due: "₹5,000 due in 7 days"
  - 3 days before due: "⚠️ ₹5,000 due soon!"
  - Past due: "❌ Payment overdue!"

### 7.6 Complexity Assessment

**High complexity feature** - Requires:
- New account type logic
- Statement cycle tracking
- Payment linking
- Timer/notification system

**Recommendation**: Implement in v0.4.x after accounts are stable

---

## 8. EMI & Loan Tracking

### 8.1 Core Concept

Track ongoing EMIs and loans with:
- Total principal
- Interest rate
- EMI amount
- Remaining payments
- Associated payment method

### 8.2 Data Model

```python
class Loan:
    id: str
    name: str                    # "Home Loan", "iPhone EMI"
    type: str                    # home_loan, car_loan, personal_loan, 
                                 # credit_card_emi, bnpl (buy now pay later)
    
    # Loan details
    principal: int               # Original amount in paise
    interest_rate: float         # Annual % (e.g., 12.5)
    tenure_months: int           # Total EMIs
    emi_amount: int              # Monthly EMI in paise
    
    # Payment tracking
    start_date: date
    emi_day: int                 # Day of month EMI is due
    payments_made: int           # Count of EMIs paid
    payments_remaining: int      # Calculated
    
    # Payment method
    payment_account_id: str      # Deducted from this account
    payment_type: str            # auto_debit, manual, credit_card
    
    # For credit card EMI
    credit_card_id: str | None   # If paid via CC EMI
    
    # Status
    is_active: bool
    foreclosure_amount: int | None  # To close early
    
    # Metadata
    lender: str                  # "HDFC", "Bajaj Finance"
    purpose: str                 # "Home", "iPhone 15", "Education"
    created_at: date
```

### 8.3 Loan Types

| Type | Example | Payment Method |
|------|---------|----------------|
| Home Loan | ₹50L over 20 years | Bank auto-debit |
| Car Loan | ₹8L over 5 years | Bank auto-debit |
| Personal Loan | ₹2L over 2 years | Bank auto-debit |
| Credit Card EMI | ₹60K over 12 months | Added to CC bill |
| BNPL | ₹10K over 3 months | Auto-charge |

### 8.4 EMI as Recurring Transaction

Each loan auto-creates a recurring transaction:

```python
def create_emi_recurring(loan):
    return RecurringTransaction(
        name=f"{loan.name} EMI",
        type="emi",
        amount=loan.emi_amount,
        category="EMI",
        account_id=loan.payment_account_id,
        frequency="monthly",
        day_of_month=loan.emi_day,
        start_date=loan.start_date,
        end_date=loan.start_date + months(loan.tenure_months),
        requires_verification=True,
        linked_loan_id=loan.id
    )
```

### 8.5 Dashboard Widget

**EMI Overview Card**:
```
┌─────────────────────────────────────┐
│ 📋 Active EMIs (3)                  │
├─────────────────────────────────────┤
│ Home Loan        ₹45,000/mo   180▸  │
│ Car Loan         ₹15,000/mo    36▸  │
│ iPhone EMI       ₹5,500/mo      8▸  │
├─────────────────────────────────────┤
│ Total Monthly:   ₹65,500            │
│ This Month Paid: ₹45,000 ✓          │
│ Pending:         ₹20,500            │
└─────────────────────────────────────┘
```

### 8.6 Detailed EMI View

Tap on a loan to see:
- Principal vs Interest breakdown
- Amortization schedule
- Payment history
- Foreclosure calculator
- Remaining balance

### 8.7 Integration with Budget

**EMI Budget Impact Options**:

1. **Count full EMI as expense** (simple)
   - EMI = ₹10,000 → Budget -₹10,000

2. **Separate principal vs interest** (advanced)
   - Principal (₹8,000) = Savings/Asset building
   - Interest (₹2,000) = Expense
   
**Recommendation**: Option 1 for v0.3, Option 2 as future enhancement

---

## Implementation Priority

### Phase 1: v0.3.0 (Foundation)
| Feature | Effort | Priority |
|---------|--------|----------|
| Category Management (add/remove) | Low | High |
| Data Clear with Confirmation | Low | High |
| Monthly Reset (fixed day) | Medium | High |
| Carry Over (basic toggle) | Medium | Medium |

### Phase 2: v0.3.x (Accounts)
| Feature | Effort | Priority |
|---------|--------|----------|
| Multiple Accounts (basic) | High | High |
| Account-wise filtering | Medium | High |
| Transfer between accounts | Medium | Medium |

### Phase 3: v0.4.0 (Recurring)
| Feature | Effort | Priority |
|---------|--------|----------|
| Recurring Transactions | High | High |
| Verification Flow | Medium | High |
| Pending Transactions UI | Medium | High |

### Phase 4: v0.4.x (Credit & Loans)
| Feature | Effort | Priority |
|---------|--------|----------|
| Credit Card Tracking | Very High | Medium |
| EMI/Loan Tracking | High | Medium |
| Payment Reminders | Medium | Medium |

---

## Open Discussion Points

### 1. Data Sync
- Should we support cloud backup/sync?
- Privacy: All local vs optional cloud?

### 2. Multi-Currency
- Support for USD, EUR, etc.?
- Conversion rates: Manual or API?

### 3. Reports & Analytics
- Monthly spending report
- Year-over-year comparison
- Export to PDF/Excel

### 4. Notifications
- How to handle on Termux (no push notifications)?
- In-app reminders only?
- Daily summary at set time?

### 5. Budgets per Category
- Set limits: "Max ₹5,000 on Food"
- Alerts when approaching limit

### 6. Goals
- "Save ₹50,000 for vacation"
- Track progress toward goal

---

## Technical Considerations

### Database Migrations
- Each feature may require schema changes
- Need migration system for SQLite
- Backup before migration

### Backward Compatibility
- Old backups should still import
- Version checking in import/export

### Performance
- As data grows, queries may slow
- Consider indexing strategy
- Pagination for large lists

---

## Next Steps

1. **Review this document** and add comments/questions
2. **Prioritize** features for v0.3.0
3. **Design database schema** for approved features
4. **Create implementation plan** with milestones

---

*Last Updated: February 12, 2026*

