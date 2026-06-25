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

## v0.1.5 — Reported 2026-06-22

| # | Issue | Severity | Status |
|---|-------|----------|--------|
| 1 | History screen has no filtering — need This Week, This Month, Custom Date Range filter chips | Medium | Open |
| 2 | Friend dropdowns (add/edit event) have no inline "Add new friend" option — forces navigation to Friends screen | Medium | Open |
| 3 | No split transaction support — can't split a transaction with a friend and auto-create a RECEIVABLE | High | Open |
| 4 | No local notifications for upcoming credit card statement due dates | High | Open |

### Details

**#1 — History Screen Filter Chips**
History screen (`mobile/lib/screens/history_screen.dart`) currently dumps all transactions with no date filtering. Add filter chips at the top of the screen:
- "This Week" — transactions from the current calendar week
- "This Month" — transactions from the current calendar month
- "Custom Date Range" — opens a date range picker; shows selected range as chip label
Default view (no chip selected) remains "All". Only one chip active at a time.

**#2 — Inline Friend Creation in Event Dropdowns**
Any screen with a friend selection dropdown (`mobile/lib/screens/add_event_screen.dart`, `mobile/lib/screens/edit_event_screen.dart`) should include an "Add new friend" entry at the bottom of the friend list. Tapping it opens a quick-add dialog (name only, no full navigation away). On save, the new friend is created and auto-selected in the dropdown. Eliminates the current friction of leaving the add/edit flow to create a friend first.

**#3 — Split Transaction Support**
Add split functionality to the add transaction flow (`mobile/lib/screens/add_event_screen.dart`). Design requirements:
- Optional "Split with friend(s)" toggle — off by default to keep the primary flow fast
- When toggled on: friend multi-select, default equal split (auto-calculated from total), manual per-friend amount override also supported
- Budget logic: full transaction amount always debits the budget (user pays upfront)
- For each friend included in the split: auto-create a RECEIVABLE event for that friend's share (owes-me)
- The RECEIVABLE events should use the same date, description, and category as the parent transaction
- Note: "Split expenses between friends" also exists in the Web (v0.2) backlog in TODO.md — this is the mobile implementation

**#4 — Credit Card Due Date Notifications**
Add local Android push notifications for approaching credit card statement due dates. Implementation notes:
- Use `flutter_local_notifications` package
- Trigger: on app launch and via a scheduled daily background check
- Notify when a due date is within a configurable window (e.g., 3 days out)
- Notification should show card name and due date
- Requires a new notification service (e.g., `mobile/lib/services/notification_service.dart`)
- Entry point: `mobile/lib/screens/credit_cards_screen.dart`

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
