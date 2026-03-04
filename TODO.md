# MoneyTrace — TODO

> Global task list. Items move from FEEDBACK.md to here once confirmed as work to do.
> Mark items `[x]` when done. Add date of completion.

---

## Mobile App (Flutter) — v0.1.4 (Completed 2026-03-04)

### 1. Edit Transactions
- [x] Tap on a transaction in history to open edit modal (2026-03-04)
- [x] Allow editing: amount, description, category, account, date (2026-03-04)
- [x] Reversals — old transaction's impact on account balance/budget must be undone before applying edited values (2026-03-04)
- [x] Log edit in audit trail (old values -> new values) (2026-03-04)
- [x] Confirmation before saving edits (2026-03-04)

### 2. Mandatory Account Selection for Paid Transactions
- [x] If money was actually paid/received (expense, income, settlement_paid, settlement_received, transfer, credit_card_payment, emi_payment), account field is **required** (2026-03-04)
- [x] Only optional for non-cash-flow types (liability, receivable) where no money moved yet (2026-03-04)
- [x] Show validation error if account not selected for paid transactions (2026-03-04)
- [x] Pre-select default account if only one exists (2026-03-04)

### 3. Category Selection for Recurring Expenses
- [x] When adding a recurring of type EXPENSE, show category picker (2026-03-04)
- [x] Category gets saved with the recurring record (2026-03-04)
- [x] When recurring generates a transaction (auto or manual), category carries over to the created event (2026-03-04)
- [x] Existing recurring expenses should allow editing to add category (2026-03-04)

### 4. Recurring Reflected in Budget
- [x] Unpaid recurring for the current period must reduce available budget (2026-03-04)
- [x] Budget formula: `Available = Base + Adjustments + Settlements - Expenses - Liabilities - EMI - Unpaid Recurring` (2026-03-04)
- [x] Budget breakdown screen should show a "Reserved for Upcoming" line item (2026-03-04)
- [x] Once a recurring is paid/confirmed, it moves from "reserved" to "expense" in the breakdown (2026-03-04)

### 5. Recurring: Autopay vs Manual
- [x] `is_autopay` flag already exists in recurring model — no migration needed (2026-03-04)
- [x] UI toggle when creating/editing recurring: "Autopay" or "Manual" (2026-03-04)
- [x] **Autopay behavior**: auto-creates events on app startup for overdue items, deducts from linked account, handles multiple missed cycles (2026-03-04)
- [x] **Manual behavior**: "Complete a Recurring?" link in Add Expense screen, pre-fills from pending manual recurring (2026-03-04)

### 6. Limit Recent Activity on Dashboard
- [x] Show only 5 most recent transactions on the dashboard (2026-03-04)
- [x] Add "View All" link/button that navigates to full history screen (2026-03-04)

### 7. Dashboard Tap Targets & Budget Summary Screen
- [x] **Loose tap targets** — "You Owe" and "Owed to You" wrapped in InkWell with padding (2026-03-04)
- [x] **Budget box tap → Visual Summary screen** with category donut chart, budget overview grid, friend owe/owed breakdowns (2026-03-04)

### 8. Custom Icons for Activities & Accounts
- [x] PNG icons mapped via centralized `AppIcons` widget (2026-03-04)
- [x] Used in: dashboard, history, accounts, recurring screens (2026-03-04)
- [x] Account type icons: bank, card, cash (2026-03-04)

### 9. Replace App Launcher Icon with MoneyTrace Logo
- [x] Generated adaptive launcher icons using `flutter_launcher_icons` (2026-03-04)
- [x] Uses `moneytrace_logo_1024.png` with black adaptive background (2026-03-04)

---

## Mobile App (Flutter) — v0.1.4 Hotfix (Completed 2026-03-04)

### 1. Amount Coloring by Event Type
- [x] Add `colorForEventType()` — outflows red, inflows green, neutral default (2026-03-04)
- [x] Replace sign-based `colorize: true` with event-type-based color in dashboard + history (2026-03-04)

### 2. Initial Balance for New Accounts
- [x] Add "Initial Balance" TextField in add account sheet (2026-03-04)
- [x] Parse to paise and pass `trackedBalance` to `createAccount()` (2026-03-04)

### 3. Fix "Complete a Recurring" Filter
- [x] Add Income tab to "Complete a Recurring?" button condition (2026-03-04)
- [x] Remove type filter — show all non-autopay recurring, pre-fill handles values (2026-03-04)

### 4. Fix Budget Recurring (nextDueDate + Logic)
- [x] Set `nextDueDate` when creating recurring (computed from frequency + dayOfMonth) (2026-03-04)
- [x] Set `nextDueDate` for linked EMI when creating loan (2026-03-04)
- [x] Fix dashboard budget: monthly/daily/weekly always relevant, yearly checks nextDueDate month (2026-03-04)
- [x] Match by description+type fallback when recurring_id not set (2026-03-04)

### 5. Cross-Screen Provider Invalidation
- [x] Create event → invalidate history + accounts (2026-03-04)
- [x] Edit event → invalidate history + accounts (2026-03-04)
- [x] Delete event → invalidate dashboard + accounts (2026-03-04)
- [x] Account CRUD → invalidate dashboard (2026-03-04)
- [x] Recurring CRUD → invalidate dashboard (2026-03-04)
- [x] Loan create/close → invalidate dashboard + recurring (2026-03-04)

---

## Web App (v0.2) — Backlog

> Items from original upgrade_ideas.md that are still relevant or not yet ported to mobile.

### Already Done (web)
- [x] Clear past data / backup / restore
- [x] Monthly reset schedule
- [x] Recurring transactions with verification
- [x] Carry over feature
- [x] Category management
- [x] Multiple accounts
- [x] Credit card tracking
- [x] EMI & loan tracking
- [x] Full CRUD
- [x] Timeline & audit trail
- [x] Budget includes unpaid recurring

### Not Yet Done
- [ ] Split expenses between friends at time of adding expense
- [ ] Analytics & reports (monthly trends, category breakdown, budget vs actual)
- [ ] Notifications (EMI due, budget threshold, pending verification)
- [ ] Multi-currency support
- [ ] Investment tracking (SIP, portfolio)
- [ ] Shared group expenses

---

## Notes

- All amounts in paise (integer). Never use floats.
- Currency is INR.
- Changes should be made in Flutter mobile app first (primary target), web app second.
