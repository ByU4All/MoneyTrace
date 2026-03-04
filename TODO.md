# MoneyTrace — TODO

> Global task list. Items move from FEEDBACK.md to here once confirmed as work to do.
> Mark items `[x]` when done. Add date of completion.

---

## Mobile App (Flutter) — v0.1.3+

### 1. Edit Transactions
- [ ] Tap on a transaction in history to open edit modal
- [ ] Allow editing: amount, description, category, account, date
- [ ] Reversals — old transaction's impact on account balance/budget must be undone before applying edited values
- [ ] Log edit in audit trail (old values -> new values)
- [ ] Confirmation before saving edits

### 2. Mandatory Account Selection for Paid Transactions
- [ ] If money was actually paid/received (expense, income, settlement_paid, settlement_received, transfer, credit_card_payment, emi_payment), account field is **required**
- [ ] Only optional for non-cash-flow types (liability, receivable) where no money moved yet
- [ ] Show validation error if account not selected for paid transactions
- [ ] Pre-select default account if only one exists

### 3. Category Selection for Recurring Expenses
- [ ] When adding a recurring of type EXPENSE, show category picker
- [ ] Category gets saved with the recurring record
- [ ] When recurring generates a transaction (auto or manual), category carries over to the created event
- [ ] Existing recurring expenses should allow editing to add category

### 4. Recurring Reflected in Budget
- [ ] Unpaid recurring for the current period must reduce available budget
- [ ] Budget formula: `Available = Base + Adjustments + Settlements - Expenses - Liabilities - EMI - Unpaid Recurring`
- [ ] Budget breakdown screen should show a "Reserved for Upcoming" line item
- [ ] Once a recurring is paid/confirmed, it moves from "reserved" to "expense" in the breakdown

### 6. Limit Recent Activity on Dashboard
- [ ] Show only 4–5 most recent transactions on the dashboard
- [ ] Add "View All" link/button that navigates to full history screen
- [ ] Prevents excessive scrolling on the main dashboard

### 7. Dashboard Tap Targets & Budget Summary Screen
- [ ] **Loose tap targets** — "You Owe" and "Owed to You" sections should have generous tap areas (not pixel-precise)
- [ ] **Budget box tap → Visual Summary screen** with:
  - Category-wise circular/donut chart showing spending breakdown
  - Remaining budget shown in the center or as a segment
  - "You Owe" total and breakdown by friend
  - "Owed to You" total and breakdown by friend
  - Total spent this period
- [ ] Summary should pull live data from current budget period

### 8. Custom Icons for Activities & Accounts
- [ ] **Activity type icons** (from `assets/icons/`):
  - `expense.png` — Expense
  - `income.png` — Income
  - `transfer.png` — Transfer
  - `i_owe.png` — I Owe
  - `owes_me.png` — Owes Me
  - `settle.png` — Settle
- [ ] Use these icons in: Add Transaction type selector, transaction history list items
- [ ] **Account type icons** (from `assets/icons/`):
  - `bank.png` — Bank / Savings / Current
  - `card.png` — Credit Card / Debit Card
  - `cash.png` — Cash
- [ ] **Remove "Wallet" account type**, replace with "Cash" using `cash.png`
- [ ] Use account icons in: account selector dropdowns, account list screen, dashboard account cards

### 9. Replace App Launcher Icon with MoneyTrace Logo
- [ ] Use `assets/icons/moneytrace_logo_1024.png` as the Android launcher icon (replace default Flutter icon)
- [ ] Use `assets/icons/moneytrace_logo_512.png` for smaller density variants
- [ ] Generate all required Android icon sizes (mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi) from these source images
- [ ] Update `android/app/src/main/AndroidManifest.xml` icon reference
- [ ] Consider using `flutter_launcher_icons` package for automated generation

### 5. Recurring: Autopay vs Manual
- [ ] Add `is_autopay` flag to recurring model (DB migration)
- [ ] UI toggle when creating/editing recurring: "Autopay" or "Manual"
- [ ] **Autopay behavior**:
  - On due date, automatically create the transaction event
  - Deduct from the linked account
  - Show in history as auto-generated transaction
  - Still allow user to verify/adjust after auto-creation
- [ ] **Manual behavior**:
  - Shows as pending on due date
  - User must explicitly confirm/complete it
  - Option in "Add Expense" screen to "Complete Recurring" — pick from pending manual recurring items
  - Stays as budget reservation until completed or skipped

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
