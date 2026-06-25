# MoneyTrace Roadmap & Future Features

> **Version**: Planning Document for v0.4.x and beyond  
> **Updated**: February 13, 2026  
> **Status**: Active Development

---

## Overview

This document outlines planned features for MoneyTrace, organized by priority and complexity. Each feature includes specifications, implementation considerations, and status.

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
9. [Full CRUD Operations](#9-full-crud-operations)
10. [Timeline & Audit Trail](#10-timeline--audit-trail)
11. [UI Enhancements](#11-ui-enhancements)
12. [Budget Includes Unpaid Recurring](#12-budget-includes-unpaid-recurring)

---

## Recently Implemented (v0.4.2)

### ✅ Budget Includes Unpaid Recurring

**Core Concept**: Budget remaining now reflects "true disposable amount" by reserving funds for recurring transactions that are due this month but haven't been paid yet.

**Formula**:
```
Budget Remaining = Base Budget + Adjustments + Settlements Received 
                 - Expenses - Liabilities - EMI Payments 
                 - Unpaid Recurring (this month)
```

#### Features
- **Autopay Flag**: Mark recurring as autopay (bank auto-deducts)
- **Upcoming Bills Section**: Dashboard shows upcoming bills with countdown
- **Pay Early**: Pay a recurring transaction before due date
- **Budget Breakdown**: Shows reserved amounts for unpaid bills

#### Autopay vs Manual
- `is_autopay = true`: Bank handles payment, still reserves budget
- `is_autopay = false`: Requires manual confirmation when due
- Both types reserve budget until paid/skipped

#### Upcoming Bills Display
- 🔴 Overdue (past due date, not confirmed)
- 🟡 Due soon (within 3 days)  
- 📅 Upcoming (further ahead)
- 🔄 Auto badge for autopay items

#### API Endpoints
- `GET /recurring/upcoming?days=30` - Get upcoming bills
- `POST /recurring/{id}/pay-early` - Pay before due date

---

## Recently Implemented (v0.4.1)

### ✅ UI Enhancements

#### Budget Breakdown Modal
- Click on budget card on dashboard to see breakdown
- Shows: Base budget, carry over, income, settlements, expenses, liabilities
- Clear calculation formula: Starting + CarryOver + SettlementsReceived - Expenses - Liabilities = Remaining

#### Income & Deposit Feature
- "Income" transaction type added to Add Event screen
- Deposits money into selected account
- Category tracking for income sources

#### Transfer Funds Feature  
- Transfer between accounts from Add Event screen
- Select from/to accounts
- Updates both account balances atomically

#### Enhanced Add Event Screen
- Row 1: Expense, Income, Transfer
- Row 2: I Owe, Owes Me, Settle
- Settlement toggle: "I'm Paying" / "I'm Receiving"
- Clear account/friend field labeling based on type

#### Friends CRUD in UI
- Click on friend in dashboard or friends list to view details
- Edit name/phone in modal
- Delete friend (only if settled)
- View transaction history with friend

#### Accounts View/Edit in UI
- Click on account to view details
- Edit name, institution, balance
- View recent transactions for account
- Delete account (non-default only)

#### History Timeline Filter
- Toggle between "Money Only" and "Full Activity"
- Money Only: Transactions only (expenses, income, etc.)
- Full Activity: All CRUD operations (edits, deletes, etc.)

---

### ✅ Previous (v0.4.0)

### ✅ Account Selection for All Transactions
- Every transaction (expense, income, settlement, etc.) can be linked to an account
- Account balance automatically updated based on transaction type
- Closed system where money is tracked properly (no generation/loss, only transfer)

### ✅ View/Edit Modals for Recurring & Loans
- Click on any recurring transaction or loan to view details
- Edit form for modifying name, amount, account, schedule, etc.
- Option to delete/close with proper data preservation

### ✅ Settlement Tracking with Account Selection
- Settlements properly track which account money came from/went to
- Separate settlement_paid and settlement_received event types
- Description field for settlement purpose

### ✅ Full CRUD for All Entities
- **Friends**: Create, Read, Update, Delete (only if settled)
- **Accounts**: Create, Read, Update, Delete (soft/permanent)
- **Events**: Create, Read, Delete (with balance reversal)
- **Loans**: Create, Read, Update, Close/Delete
- **Recurring**: Create, Read, Update, Deactivate/Delete

### ✅ Timeline with Audit Trail
- `GET /api/events/timeline?detailed=false` - Money transactions only
- `GET /api/events/timeline?detailed=true` - All activity including CRUD operations
- Every edit/delete logged with old/new values

### ✅ Soft Delete vs Permanent Delete
- Soft delete: Record kept, marked inactive, past transactions preserved
- Permanent delete: Record removed, transactions unlinked but preserved
- Friends with outstanding balance cannot be deleted

---

## 1. Data Management

### 1.1 Clear Past Data ✅ Implemented

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

---

### 1.2 Create Data Backup ✅ Implemented

**API Endpoint**: `GET /api/export`

**Features**:
- Exports all data to JSON
- Includes version for compatibility
- Contains: settings, categories, friends, events, accounts, recurring, loans

---

### 1.3 Restore Data from Backup ✅ Implemented

**API Endpoint**: `POST /api/import`

---

## 2. Budget Reset & Scheduling

### 2.1 Monthly Reset Schedule ✅ Implemented

**Settings**:
- Reset Day (1-28)
- Reset Enabled (on/off)
- Carry Over options

---

## 3. Recurring Transactions ✅ Implemented

### Features:
- Create recurring expenses, income, EMI payments
- Daily, weekly, monthly, yearly frequency
- Verification flow for pending transactions
- Auto-link to loans for EMI tracking

---

## 4. Carry Over Feature ✅ Implemented

---

## 5. Category Management ✅ Implemented

---

## 6. Multiple Accounts ✅ Implemented

### Features:
- Multiple account types: Savings, Current, Cash, Credit Card, UPI/Wallet
- Track balance per account
- Transfer between accounts
- Account-specific transaction history

---

## 7. Credit Card Tracking ✅ Implemented

### Features:
- Credit card as account type
- Track credit limit, billing day, due day
- Record credit card payments
- Track outstanding balance

---

## 8. EMI & Loan Tracking ✅ Implemented

### Features:
- Create loans with principal, interest rate, tenure, EMI
- Auto-generate recurring EMI reminders
- Track payments made vs remaining
- Close vs Delete loans (keep history)
- Amortization schedule

---

## 9. Full CRUD Operations ✅ Implemented

### 9.1 Friends CRUD

| Operation | Endpoint | Notes |
|-----------|----------|-------|
| Create | POST /friends | - |
| Read | GET /friends | With balance |
| Update | PUT /friends/{id} | Name, phone |
| Delete | DELETE /friends/{id} | Only if settled |

**Delete Rules**:
- Friends with outstanding balance cannot be deleted
- Past transactions preserved with friend_id reference

---

### 9.2 Accounts CRUD

| Operation | Endpoint | Notes |
|-----------|----------|-------|
| Create | POST /accounts | - |
| Read | GET /accounts | - |
| Update | PUT /accounts/{id} | - |
| Deactivate | DELETE /accounts/{id} | Soft delete |
| Permanent Delete | DELETE /accounts/{id}?permanent=true | Unlinks transactions |

**Delete Rules**:
- Default account cannot be deleted
- Non-zero balance allowed (user's choice)
- Transactions preserved, account_id kept for reference

---

### 9.3 Events CRUD

| Operation | Endpoint | Notes |
|-----------|----------|-------|
| Create | POST /events | With account selection |
| Read | GET /events | Filter by account |
| Delete | DELETE /events/{id} | Reverses balance |

**Delete Rules**:
- Account balance impact is reversed
- Event is permanently removed
- Deletion logged in audit trail

---

### 9.4 Loans CRUD

| Operation | Endpoint | Notes |
|-----------|----------|-------|
| Create | POST /loans | Auto-creates recurring |
| Read | GET /loans | - |
| Update | PUT /loans/{id} | Name, EMI, account |
| Close | DELETE /loans/{id} | Soft delete |
| Delete | DELETE /loans/{id}?permanent=true | Removes record |

---

### 9.5 Recurring CRUD

| Operation | Endpoint | Notes |
|-----------|----------|-------|
| Create | POST /recurring | - |
| Read | GET /recurring | - |
| Update | PUT /recurring/{id} | - |
| Deactivate | DELETE /recurring/{id} | Soft delete |

---

## 10. Timeline & Audit Trail ✅ Implemented

### 10.1 Timeline API

```
GET /api/events/timeline
Query Parameters:
  - limit: int (default 100)
  - detailed: bool (default false)
```

**detailed=false** (Money-only):
- Shows only financial transactions
- Expense, income, transfer, settlement, etc.

**detailed=true** (All Activity):
- Includes all CRUD operations
- Friend added/edited/deleted
- Account changes
- Loan modifications
- Every edit with old/new values

### 10.2 Audit Log Schema

```python
class AuditLog:
    id: str
    action: str        # create, update, delete, close
    entity_type: str   # event, friend, account, loan, recurring
    entity_id: str
    entity_name: str
    old_values: dict   # Previous state
    new_values: dict   # New state
    description: str   # Human-readable
    is_money_related: bool
    created_at: str
```

---

## 11. UI Enhancements ✅ Implemented

### 11.1 Budget Breakdown Modal

**Trigger**: Click on budget card in dashboard

**Shows**:
- Starting Budget
- + Carry Over
- + Settlements Received
- − Expenses
- − EMI/Loan Payments
- − Outstanding Liabilities
- = Remaining Budget

**Budget Calculation includes**:
- EMI payments (from loans/recurring) reduce available budget
- Recurring expenses tracked via pending verification flow

### 11.2 Add Event Enhancements

**Transaction Types (2 rows)**:
- Row 1: Expense | Income | Transfer
- Row 2: I Owe | Owes Me | Settle

**Smart Form Fields**:
- Account label changes based on type (Paid From / Deposit To / etc.)
- Category shown/hidden based on type
- Friend selector for friend-related transactions
- Transfer shows From/To account selectors

### 11.3 Entity Detail Modals

**Friends**:
- View balance and transaction history
- Edit name/phone
- Delete (only if settled)

**Accounts**:
- View balance and recent transactions
- Edit name/institution/balance
- Delete (non-default, preserves transactions)

**Loans**:
- View progress (payments made / total)
- Edit EMI amount, day, lender
- Close loan (soft delete)

**Recurring**:
- View schedule details
- Edit amount, frequency, account
- Deactivate or delete

### 11.4 History Timeline Filter

**Two Modes**:
- 💰 Money Only: Financial transactions only
- 📋 Full Activity: All CRUD operations with audit trail

---

## Recently Implemented: Native Mobile App (March 2026)

### Flutter Android App
- **Framework**: Flutter 3.27.4 + Dart, Drift (SQLite), Riverpod
- **Theme**: Nothing OS design language — AMOLED black, red accent (`#D72638`), pill buttons, border cards, Space Grotesk font
- **Build**: AGP 8.7.0, Kotlin 2.0.21, Gradle 8.12, Java 17/21, NDK 27.0.12077973
- **Status**: Built (25.5MB APK) and deployed to Nothing Phone 3a (Android 16)
- **Distribution**: Direct APK sharing; Play Store requires signing key + developer account

See [MOBILE_APP.md](../MOBILE_APP.md) for full documentation.

---

## Future Enhancements (v0.5.x+)

### Analytics & Reports
- Monthly spending trends
- Category-wise breakdown charts
- Budget vs actual comparison
- Year-over-year analysis

### Notifications
- EMI due reminders
- Budget threshold alerts
- Pending verification reminders

### Multi-Currency Support
- Track expenses in multiple currencies
- Exchange rate conversion

### Investment Tracking
- SIP tracking
- Portfolio value
- Returns calculation

### Shared Expenses
- Group expenses (trips, roommates)
- Split calculation
- Settlement tracking across groups

---

## API Reference Summary

### Events
- `POST /api/events` - Create event with account
- `GET /api/events` - List events
- `DELETE /api/events/{id}` - Delete event
- `GET /api/events/timeline` - Activity timeline

### Friends
- `POST /api/friends` - Create friend
- `GET /api/friends` - List with balances
- `GET /api/friends/{id}` - Details with events
- `PUT /api/friends/{id}` - Update friend
- `DELETE /api/friends/{id}` - Delete friend

### Accounts
- `POST /api/accounts` - Create account
- `GET /api/accounts` - List accounts
- `GET /api/accounts/{id}` - Account details
- `PUT /api/accounts/{id}` - Update account
- `DELETE /api/accounts/{id}` - Delete/deactivate
- `GET /api/accounts/{id}/events` - Account transactions
- `POST /api/accounts/transfer` - Transfer funds

### Loans
- `POST /api/loans` - Create loan
- `GET /api/loans` - List loans
- `GET /api/loans/{id}` - Loan details
- `PUT /api/loans/{id}` - Update loan
- `DELETE /api/loans/{id}` - Close/delete loan
- `POST /api/loans/{id}/pay` - Record payment
- `GET /api/loans/{id}/schedule` - Amortization

### Recurring
- `POST /api/recurring` - Create recurring
- `GET /api/recurring` - List recurring
- `GET /api/recurring/{id}` - Details
- `PUT /api/recurring/{id}` - Update
- `DELETE /api/recurring/{id}` - Deactivate
- `GET /api/recurring/pending` - Pending items
- `POST /api/recurring/pending/{id}/confirm` - Confirm
- `POST /api/recurring/pending/{id}/skip` - Skip
