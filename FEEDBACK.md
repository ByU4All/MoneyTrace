# MoneyTrace — Feedback (Flutter Mobile v0.1.3)

> Version-specific feedback from real usage. Confirmed items get moved to [TODO.md](./TODO.md).
> Once all items for a version are addressed, archive this section and start fresh for next version.

---

## v0.1.3 — Reported 2026-03-04 (All resolved in v0.1.4)

### Confirmed -> Moved to TODO -> Completed

| # | Issue | Severity | Status |
|---|-------|----------|--------|
| 1 | Transactions are permanent — no way to edit after adding | High | Done in v0.1.4 |
| 2 | Account selection is optional even when money was paid — should be mandatory for cash-flow events | Medium | Done in v0.1.4 |
| 3 | Adding recurring expense has no category picker — defeats purpose of expense tracking | Medium | Done in v0.1.4 |
| 4 | Recurring transactions not reflected in budget at all | High | Done in v0.1.4 |
| 5 | No distinction between autopay and manual recurring — autopay should auto-deduct, manual should stay pending with option to complete from add expense | High | Done in v0.1.4 |
| 6 | Recent activity on dashboard shows too many items — should be 4–5 max to avoid scrolling | Low | Done in v0.1.4 |
| 7 | Dashboard tap targets too precise on "You Owe"/"Owed to You"; tapping budget box should open visual summary with category donut chart, owe/owed breakdown | Medium | Done in v0.1.4 |
| 8 | No custom icons — activity types (expense, income, transfer, etc.) and account types (bank, card, cash) should use provided PNG icons from `assets/icons/`; remove Wallet option, replace with Cash | Medium | Done in v0.1.4 |
| 9 | App uses default Flutter launcher icon — replace with MoneyTrace logo (`moneytrace_logo_1024.png` / `moneytrace_logo_512.png`) | Low | Done in v0.1.4 |

---

## v0.1.4 Hotfix — Reported 2026-03-04 (Device Testing)

| # | Issue | Severity | Status |
|---|-------|----------|--------|
| 1 | Cash inflow/outflow amounts all same color — sign-based logic fails since amounts stored as positive paise | Medium | Done in v0.1.4 hotfix |
| 2 | No way to set initial balance when adding an account | Medium | Done in v0.1.4 hotfix |
| 3 | "Complete a Recurring?" shows "No available" — type filter too restrictive, button missing from Income tab | Medium | Done in v0.1.4 hotfix |
| 4 | Autopay/EMI never deducted from budget — nextDueDate never set on creation, budget logic solely depends on it | High | Done in v0.1.4 hotfix |
| 5 | Changes not instantly reflected across screens — IndexedStack keeps stale data | Medium | Done in v0.1.4 hotfix |

---

## v0.1.4 Post-Release — Reported 2026-03-05

| # | Issue | Severity | Status |
|---|-------|----------|--------|
| 1 | Loan card and detail view show "Completed EMIs" — should show "Remaining EMIs" instead | Medium | Open |
| 2 | [Mobile] Export/backup uses share sheet — no way to save to a local folder; needs dedicated app backup directory | High | Open |

### Details

**#1 — Show Remaining EMIs on Loan Card and Detail View**
Users care about how many EMIs are left, not how many they've already paid. Replace the "Completed EMIs" display on both the loan list card and the loan detail screen with "Remaining EMIs" (i.e., `totalEmis - completedEmis`). If remaining reaches 0, show a "Fully paid" or equivalent indicator.

**#2 — Dedicated App Backup Directory for Export/Import**
Currently export/backup uses a share mechanism (e.g., share_plus) that opens the Android share sheet — users can send to Drive, WhatsApp, etc. but cannot save directly to a local folder they can browse. Required changes:
- Create a dedicated app backup directory (e.g., `Android/data/com.moneytrace.app/files/backups/` or equivalent accessible path) where all exports are saved automatically
- When triggering export, write the backup file to this directory first, then optionally offer the share sheet as a secondary action
- When importing, default the file picker to this backup directory; user can still navigate elsewhere if needed
- Directory should be persistent and survive app updates (not cache)

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
