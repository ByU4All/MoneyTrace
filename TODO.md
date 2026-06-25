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

## Mobile App (Flutter) — v0.1.5 (2026-06-24)

### 1. Fresh Install Onboarding
- [x] 5-page onboarding flow (Welcome, Budget, Account, Categories, Done) shown on first launch (2026-06-24)
- [x] First-run detected via `onboarding_complete` settings key; returning users go straight to dashboard (2026-06-24)
- [x] Budget set during onboarding saved via SettingsDao (2026-06-24)
- [x] Optional bank/UPI account creation on page 3 (2026-06-24)
- [x] Page 4 shows the 11 seeded categories; user can add custom ones inline (2026-06-24)
- [x] Skip-all available on pages 1–3; completion writes flag and transitions to MainShell (2026-06-24)

### 2. Default Seeding on Fresh Install
- [x] 11 default categories seeded on `onCreate`: Food & Dining, Transport, Shopping, Entertainment, Bills & Utilities, Health, Travel, Salary, EMI, Investment, Other (2026-06-24)
- [x] Default Cash account seeded on `onCreate` (matches web v0.2 behaviour) (2026-06-24)
- [x] Seeding is idempotent (guarded by row-count check; won't duplicate) (2026-06-24)

### 3. Split Amount Calculation Fix
- [x] Split bill now divides total by (friends + you), not just friends (2026-06-24)
- [x] Example: ₹100 split with 1 friend → ₹50 each (was ₹100 to the friend) (2026-06-24)

### 4. Empty Picker States
- [x] Accounts tab: blank "no accounts yet" text replaced with icon + description + Add Account button (2026-06-24)
- [x] Shared `EmptyPickerRow` widget (`widgets/empty_picker_row.dart`) — amber-bordered tappable row that opens an AlertDialog with OK button (2026-06-24)
- [x] Applied to all category and account dropdowns across: Add Event, Edit Event, Recurring (add + edit) screens (2026-06-24)
- [x] Dialogs explain what is missing and the exact navigation path to create it (2026-06-24)

---

## Mobile App (Flutter) — Future Backlog

### 1. Bill Photo Attachments
- [x] Add optional photo attachment to any transaction (mobile only) — single photo via `bill_photo_path` column (2026-06-24 verified)
- [x] Use `image_picker` package for camera capture or gallery selection (2026-06-24 verified)
- [x] Show photo preview in add/edit screens; thumbnail shown in history detail (2026-06-24 verified)
- [x] Store as file path (not blob) in the local DB; files in app documents directory (2026-06-24 verified)

### 2. Neumorphism UI Redesign
- [x] Background changed from AMOLED black to dark-gray base (`#1C1C2C`) (2026-06-24 verified)
- [x] Dual BoxShadow (light top-left `shadowLight`, dark bottom-right `shadowDark`) applied via `AppTheme.darkTheme()` to Card, BottomSheet, Chip, BottomNav (2026-06-24 verified)
- [x] `NeuCard` widget available for explicit neumorphic containers (2026-06-24 verified)
- [x] All screens reference `AppColors.*` — theme swap was done by editing only `colors.dart` + `app_theme.dart` (2026-06-24 verified)

### 3. Upload Debug Symbols with Play Store Releases
- [x] `build_release.sh` script builds AAB + APK + debug symbols zip in one command (2026-06-24)
- [x] Uses `--split-debug-info` + `--obfuscate` flags automatically (2026-06-24)
- [x] Outputs named with version from pubspec.yaml; prints exact Play Console upload steps (2026-06-24)
- [ ] After each release: upload `debug-symbols-<version>.zip` to Play Console → App bundle → ⋮ → Upload deobfuscation file

### 4. Multi-Photo Support (Bill Photos upgrade)
- [x] Migrate `bill_photo_path` column to a separate `bill_photos` table: `(id, event_id, file_path, created_at)` — schema v4 with migration (2026-06-24)
- [x] Update add/edit screens to support attaching multiple photos — horizontal `BillPhotoStrip` widget (2026-06-24)
- [x] Export/import and delete correctly handle `bill_photos` table (2026-06-24)
- [ ] Show all photo thumbnails when tapping a history entry (detail view)

### 5. UX Audit Fixes (`mobile/` — identified 2026-06-24)

**Critical — fixed (2026-06-24):**
- [x] Category delete had no confirmation dialog (`settings_screen.dart`)
- [x] Account delete had no confirmation dialog (`accounts_screen.dart`)
- [x] Recurring delete had no confirmation dialog (`recurring_screen.dart`)

**Broken / missing features:**
- [x] History silently capped at 200 events — removed limit, added "Load 50 more" pagination button (2026-06-24)
- [x] Receipt icon in history didn't appear for new multi-photo transactions — now checks `bill_photos` table via `getEventIdsWithPhotos()` (2026-06-24)
- [x] Account type locked after creation — edit sheet now has enabled dropdown with all 6 types (2026-06-24)
- [x] "This Month" filter used calendar month — renamed to "Budget Period", now uses `budget_reset_day` setting (2026-06-24)
- [ ] Category text field loses typed input on any state change — controller recreated inside build (`settings_screen.dart`)
- [ ] Recurring "upcoming" items show no edit/delete menu — action hidden when `dim = true` (`recurring_screen.dart`)

**Minor / confusing:**
- [ ] Loans screen has no empty state — blank with tiny muted text, no pointer to the + button

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
