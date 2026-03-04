# MoneyTrace — Feedback (Flutter Mobile v0.1.3)

> Version-specific feedback from real usage. Confirmed items get moved to [TODO.md](./TODO.md).
> Once all items for a version are addressed, archive this section and start fresh for next version.

---

## v0.1.3 — Reported 2026-03-04

### Confirmed -> Moved to TODO

| # | Issue | Severity | Status |
|---|-------|----------|--------|
| 1 | Transactions are permanent — no way to edit after adding | High | -> TODO #1 |
| 2 | Account selection is optional even when money was paid — should be mandatory for cash-flow events | Medium | -> TODO #2 |
| 3 | Adding recurring expense has no category picker — defeats purpose of expense tracking | Medium | -> TODO #3 |
| 4 | Recurring transactions not reflected in budget at all | High | -> TODO #4 |
| 5 | No distinction between autopay and manual recurring — autopay should auto-deduct, manual should stay pending with option to complete from add expense | High | -> TODO #5 |
| 6 | Recent activity on dashboard shows too many items — should be 4–5 max to avoid scrolling | Low | -> TODO #6 |
| 7 | Dashboard tap targets too precise on "You Owe"/"Owed to You"; tapping budget box should open visual summary with category donut chart, owe/owed breakdown | Medium | -> TODO #7 |
| 8 | No custom icons — activity types (expense, income, transfer, etc.) and account types (bank, card, cash) should use provided PNG icons from `assets/icons/`; remove Wallet option, replace with Cash | Medium | -> TODO #8 |
| 9 | App uses default Flutter launcher icon — replace with MoneyTrace logo (`moneytrace_logo_1024.png` / `moneytrace_logo_512.png`) | Low | -> TODO #9 |

### Details

**#1 — Edit Transactions**
Once a transaction is added, it cannot be modified. If you made a typo in amount or selected wrong category, the only option is to delete and re-add. Need tap-to-edit on transaction items in history.

**#2 — Mandatory Account for Paid Transactions**
When adding an expense where money was actually spent, the account field should not be optional. If I paid, the money came from somewhere — that account must be selected. Optional should only apply to liability (I owe someone) or receivable (someone owes me) where no cash moved yet.

**#3 — Category on Recurring Expenses**
When creating a recurring transaction of type "expense" (e.g., Netflix subscription, gym membership), there's no option to assign a category. Without this, these expenses can't be categorized in reports and the tracking loses meaning.

**#4 — Recurring Not in Budget**
Recurring transactions are not deducted from the budget at all. If I have a 500/month subscription, the budget should reflect that 500 is already committed. The budget should show "reserved for upcoming" recurring so the user sees true disposable income.

**#6 — Recent Activity Too Long**
Dashboard recent activity section shows all transactions, making the main screen too scrollable. Limit to 4–5 items with a "View All" link to the full history.

**#7 — Dashboard Tap Targets & Budget Visual Summary**
Two issues:
- Tapping "You Owe" and "Owed to You" requires very precise taps. Make the hit areas larger/looser.
- Tapping the budget box should open a full visual summary screen: category-wise donut/circular chart of spending (with remaining budget), plus "You Owe" and "Owed to You" breakdowns by friend.

**#8 — Custom Icons for Activities & Accounts**
Icons provided in `assets/icons/`:
- **Activities**: `expense.png`, `income.png`, `transfer.png`, `i_owe.png`, `owes_me.png`, `settle.png` — use in the Add Transaction type selector buttons and in history list items.
- **Accounts**: `bank.png`, `card.png`, `cash.png` — use in account selectors, account list, and dashboard cards.
- **Remove "Wallet"** account type entirely, replace with "Cash" using `cash.png`.

**#9 — App Launcher Icon**
App currently uses the default Flutter icon. Replace with the MoneyTrace logo from `assets/icons/moneytrace_logo_1024.png` (1024px) and `moneytrace_logo_512.png` (512px). Generate all Android density variants from these.

**#5 — Autopay vs Manual Recurring**
Two real-world patterns exist:
- **Autopay**: Bank/service auto-deducts (Netflix, EMI, SIP). App should auto-create the transaction on due date and deduct from linked account.
- **Manual**: User pays manually (rent, maid salary). App should show it as pending. In "Add Expense" screen, provide shortcut to "complete a recurring" — pick from pending manual items so user doesn't have to re-enter details.

---

## Template for Future Versions

<!--
## vX.Y.Z — Reported YYYY-MM-DD

| # | Issue | Severity | Status |
|---|-------|----------|--------|
| 1 | Description | High/Medium/Low | Open / -> TODO #N |

### Details
**#1 — Title**
Detailed description...
-->
