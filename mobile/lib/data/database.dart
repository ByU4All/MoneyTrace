/// Drift database definition for MoneyTrace.
///
/// Table and column names match the Python SQLite schema exactly
/// to ensure export/import compatibility.

import 'package:drift/drift.dart';

import 'connection/connection.dart' as connection;

part 'database.g.dart';

// ---------------------------------------------------------------------------
// Table Definitions (matching Python db.py schema exactly)
// ---------------------------------------------------------------------------

class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

class Friends extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get phone => text().nullable()();
  TextColumn get createdAt => text().named('created_at')();

  @override
  Set<Column> get primaryKey => {id};
}

class Accounts extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get type => text()();
  TextColumn get institution => text().nullable()();
  TextColumn get last4Digits => text().nullable().named('last_4_digits')();
  TextColumn get color => text().nullable()();
  TextColumn get icon => text().nullable()();
  IntColumn get trackedBalance => integer().withDefault(const Constant(0)).named('tracked_balance')();
  IntColumn get currentBalance => integer().withDefault(const Constant(0)).named('current_balance')();
  IntColumn get isCredit => integer().withDefault(const Constant(0)).named('is_credit')();
  IntColumn get creditLimit => integer().nullable().named('credit_limit')();
  IntColumn get billingDay => integer().nullable().named('billing_day')();
  IntColumn get dueDay => integer().nullable().named('due_day')();
  IntColumn get isActive => integer().withDefault(const Constant(1)).named('is_active')();
  IntColumn get isDefault => integer().withDefault(const Constant(0)).named('is_default')();
  TextColumn get createdAt => text().named('created_at')();

  @override
  Set<Column> get primaryKey => {id};
}

class Events extends Table {
  TextColumn get id => text()();
  TextColumn get type => text()();
  IntColumn get amount => integer()();
  TextColumn get category => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get friendId => text().nullable().named('friend_id')();
  TextColumn get accountId => text().nullable().named('account_id')();
  TextColumn get fromAccountId => text().nullable().named('from_account_id')();
  TextColumn get toAccountId => text().nullable().named('to_account_id')();
  TextColumn get recurringId => text().nullable().named('recurring_id')();
  TextColumn get loanId => text().nullable().named('loan_id')();
  TextColumn get eventDate => text().named('event_date')();
  TextColumn get createdAt => text().named('created_at')();

  @override
  Set<Column> get primaryKey => {id};
}

class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get isDefault => integer().withDefault(const Constant(0)).named('is_default')();

  @override
  Set<Column> get primaryKey => {id};
}

class MonthRecords extends Table {
  TextColumn get id => text()();
  IntColumn get year => integer()();
  IntColumn get month => integer()();
  IntColumn get baseBudget => integer().named('base_budget')();
  IntColumn get carryOverAmount => integer().withDefault(const Constant(0)).named('carry_over_amount')();
  IntColumn get totalBudget => integer().named('total_budget')();
  IntColumn get totalSpent => integer().withDefault(const Constant(0)).named('total_spent')();
  IntColumn get endingBalance => integer().withDefault(const Constant(0)).named('ending_balance')();
  TextColumn get createdAt => text().named('created_at')();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [{year, month}];
}

class RecurringTransactions extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get type => text()();
  IntColumn get amount => integer()();
  TextColumn get category => text().nullable()();
  TextColumn get accountId => text().nullable().named('account_id')();
  TextColumn get frequency => text()();
  IntColumn get dayOfMonth => integer().nullable().named('day_of_month')();
  IntColumn get dayOfWeek => integer().nullable().named('day_of_week')();
  TextColumn get startDate => text().named('start_date')();
  TextColumn get endDate => text().nullable().named('end_date')();
  IntColumn get requiresVerification => integer().withDefault(const Constant(1)).named('requires_verification')();
  IntColumn get autoApply => integer().withDefault(const Constant(0)).named('auto_apply')();
  IntColumn get isAutopay => integer().withDefault(const Constant(0)).named('is_autopay')();
  IntColumn get isActive => integer().withDefault(const Constant(1)).named('is_active')();
  TextColumn get lastAppliedDate => text().nullable().named('last_applied_date')();
  TextColumn get nextDueDate => text().nullable().named('next_due_date')();
  TextColumn get linkedLoanId => text().nullable().named('linked_loan_id')();
  TextColumn get createdAt => text().named('created_at')();

  @override
  Set<Column> get primaryKey => {id};
}

class PendingTransactions extends Table {
  TextColumn get id => text()();
  TextColumn get recurringId => text().named('recurring_id')();
  TextColumn get dueDate => text().named('due_date')();
  IntColumn get amount => integer()();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  TextColumn get actionDate => text().nullable().named('action_date')();
  TextColumn get createdAt => text().named('created_at')();

  @override
  Set<Column> get primaryKey => {id};
}

class Loans extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get type => text()();
  IntColumn get principal => integer()();
  RealColumn get interestRate => real().named('interest_rate')();
  IntColumn get tenureMonths => integer().named('tenure_months')();
  IntColumn get emiAmount => integer().named('emi_amount')();
  TextColumn get startDate => text().named('start_date')();
  IntColumn get emiDay => integer().named('emi_day')();
  IntColumn get paymentsMade => integer().withDefault(const Constant(0)).named('payments_made')();
  TextColumn get paymentAccountId => text().nullable().named('payment_account_id')();
  TextColumn get paymentType => text().withDefault(const Constant('manual')).named('payment_type')();
  TextColumn get creditCardId => text().nullable().named('credit_card_id')();
  TextColumn get lender => text().nullable()();
  TextColumn get purpose => text().nullable()();
  IntColumn get isActive => integer().withDefault(const Constant(1)).named('is_active')();
  IntColumn get foreclosureAmount => integer().nullable().named('foreclosure_amount')();
  TextColumn get createdAt => text().named('created_at')();

  @override
  Set<Column> get primaryKey => {id};
}

class LoanEmiSchedule extends Table {
  TextColumn get id => text()();
  TextColumn get loanId => text().named('loan_id')();
  IntColumn get monthNumber => integer().named('month_number')();
  IntColumn get emiAmount => integer().named('emi_amount')();
  TextColumn get createdAt => text().named('created_at')();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [{loanId, monthNumber}];

  @override
  String get tableName => 'loan_emi_schedule';
}

class CreditCardStatements extends Table {
  TextColumn get id => text()();
  TextColumn get cardAccountId => text().named('card_account_id')();
  TextColumn get statementDate => text().named('statement_date')();
  TextColumn get dueDate => text().named('due_date')();
  IntColumn get statementAmount => integer().named('statement_amount')();
  IntColumn get minimumDue => integer().named('minimum_due')();
  IntColumn get paidAmount => integer().withDefault(const Constant(0)).named('paid_amount')();
  TextColumn get paidDate => text().nullable().named('paid_date')();
  IntColumn get isFullyPaid => integer().withDefault(const Constant(0)).named('is_fully_paid')();
  TextColumn get createdAt => text().named('created_at')();

  @override
  Set<Column> get primaryKey => {id};
}

class AuditLog extends Table {
  TextColumn get id => text()();
  TextColumn get action => text()();
  TextColumn get entityType => text().named('entity_type')();
  TextColumn get entityId => text().named('entity_id')();
  TextColumn get auditEntityName => text().nullable().named('entity_name')();
  TextColumn get oldValues => text().nullable().named('old_values')();
  TextColumn get newValues => text().nullable().named('new_values')();
  TextColumn get description => text().nullable()();
  IntColumn get isMoneyRelated => integer().withDefault(const Constant(0)).named('is_money_related')();
  TextColumn get createdAt => text().named('created_at')();

  @override
  Set<Column> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// Database Class
// ---------------------------------------------------------------------------

@DriftDatabase(tables: [
  Settings,
  Friends,
  Accounts,
  Events,
  Categories,
  MonthRecords,
  RecurringTransactions,
  PendingTransactions,
  Loans,
  LoanEmiSchedule,
  CreditCardStatements,
  AuditLog,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(connection.connect());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;
}
