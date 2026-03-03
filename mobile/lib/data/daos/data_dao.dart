import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database.dart';
import 'settings_dao.dart';

/// Export/import/clear operations.
/// Produces JSON identical to the web app for cross-platform compatibility.
class DataDao {
  final AppDatabase _db;
  final SettingsDao _settings;
  const DataDao(this._db, this._settings);

  /// Export all data as a map matching the web app JSON format.
  Future<Map<String, dynamic>> exportAll() async {
    final categories = await _db.select(_db.categories).get();
    final friends = await _db.select(_db.friends).get();
    final accounts = await (_db.select(_db.accounts)).get();
    final events = await (_db.select(_db.events)
          ..orderBy([(e) => OrderingTerm.desc(e.eventDate)]))
        .get();
    final monthRecords = await (_db.select(_db.monthRecords)
          ..orderBy([(m) => OrderingTerm.desc(m.year), (m) => OrderingTerm.desc(m.month)]))
        .get();
    final recurring = await _db.select(_db.recurringTransactions).get();
    final loans = await _db.select(_db.loans).get();
    final ccStatements = await _db.select(_db.creditCardStatements).get();
    final emiSchedules = await (_db.select(_db.loanEmiSchedule)
          ..orderBy([(s) => OrderingTerm.asc(s.loanId), (s) => OrderingTerm.asc(s.monthNumber)]))
        .get();

    return {
      'version': '0.4.0',
      'exported_at': DateTime.now().toIso8601String().split('T')[0],
      'settings': await _settings.getAllSettings(),
      'categories': categories.map((c) => {
        'id': c.id,
        'name': c.name,
        'is_default': c.isDefault,
      }).toList(),
      'friends': friends.map((f) => {
        'id': f.id,
        'name': f.name,
        'phone': f.phone,
        'created_at': f.createdAt,
      }).toList(),
      'accounts': accounts.map((a) => {
        'id': a.id,
        'name': a.name,
        'type': a.type,
        'institution': a.institution,
        'last_4_digits': a.last4Digits,
        'color': a.color,
        'icon': a.icon,
        'tracked_balance': a.trackedBalance,
        'current_balance': a.currentBalance,
        'is_credit': a.isCredit,
        'credit_limit': a.creditLimit,
        'billing_day': a.billingDay,
        'due_day': a.dueDay,
        'is_active': a.isActive,
        'is_default': a.isDefault,
        'created_at': a.createdAt,
      }).toList(),
      'events': events.map((e) => {
        'id': e.id,
        'type': e.type,
        'amount': e.amount,
        'category': e.category,
        'description': e.description,
        'friend_id': e.friendId,
        'account_id': e.accountId,
        'from_account_id': e.fromAccountId,
        'to_account_id': e.toAccountId,
        'recurring_id': e.recurringId,
        'loan_id': e.loanId,
        'event_date': e.eventDate,
        'created_at': e.createdAt,
      }).toList(),
      'month_records': monthRecords.map((m) => {
        'id': m.id,
        'year': m.year,
        'month': m.month,
        'base_budget': m.baseBudget,
        'carry_over_amount': m.carryOverAmount,
        'total_budget': m.totalBudget,
        'total_spent': m.totalSpent,
        'ending_balance': m.endingBalance,
        'created_at': m.createdAt,
      }).toList(),
      'recurring_transactions': recurring.map((r) => {
        'id': r.id,
        'name': r.name,
        'type': r.type,
        'amount': r.amount,
        'category': r.category,
        'account_id': r.accountId,
        'frequency': r.frequency,
        'day_of_month': r.dayOfMonth,
        'day_of_week': r.dayOfWeek,
        'start_date': r.startDate,
        'end_date': r.endDate,
        'requires_verification': r.requiresVerification,
        'auto_apply': r.autoApply,
        'is_autopay': r.isAutopay,
        'is_active': r.isActive,
        'last_applied_date': r.lastAppliedDate,
        'next_due_date': r.nextDueDate,
        'linked_loan_id': r.linkedLoanId,
        'created_at': r.createdAt,
      }).toList(),
      'loans': loans.map((l) => {
        'id': l.id,
        'name': l.name,
        'type': l.type,
        'principal': l.principal,
        'interest_rate': l.interestRate,
        'tenure_months': l.tenureMonths,
        'emi_amount': l.emiAmount,
        'start_date': l.startDate,
        'emi_day': l.emiDay,
        'payments_made': l.paymentsMade,
        'payment_account_id': l.paymentAccountId,
        'payment_type': l.paymentType,
        'credit_card_id': l.creditCardId,
        'lender': l.lender,
        'purpose': l.purpose,
        'is_active': l.isActive,
        'foreclosure_amount': l.foreclosureAmount,
        'created_at': l.createdAt,
      }).toList(),
      'credit_card_statements': ccStatements.map((s) => {
        'id': s.id,
        'card_account_id': s.cardAccountId,
        'statement_date': s.statementDate,
        'due_date': s.dueDate,
        'statement_amount': s.statementAmount,
        'minimum_due': s.minimumDue,
        'paid_amount': s.paidAmount,
        'paid_date': s.paidDate,
        'is_fully_paid': s.isFullyPaid,
        'created_at': s.createdAt,
      }).toList(),
      'loan_emi_schedules': emiSchedules.map((s) => {
        'id': s.id,
        'loan_id': s.loanId,
        'month_number': s.monthNumber,
        'emi_amount': s.emiAmount,
        'created_at': s.createdAt,
      }).toList(),
    };
  }

  /// Import data from a backup map. Replaces all existing data.
  Future<void> importAll(Map<String, dynamic> data) async {
    await _db.transaction(() async {
      // Clear all data
      await _db.delete(_db.events).go();
      await _db.delete(_db.friends).go();
      await _db.delete(_db.categories).go();
      await _db.delete(_db.monthRecords).go();
      await _db.delete(_db.loanEmiSchedule).go();
      await _db.delete(_db.accounts).go();
      await _db.delete(_db.recurringTransactions).go();
      await _db.delete(_db.pendingTransactions).go();
      await _db.delete(_db.loans).go();
      await _db.delete(_db.creditCardStatements).go();

      // Import settings
      if (data['settings'] != null) {
        final s = data['settings'] as Map<String, dynamic>;
        if (s['base_budget'] != null) await _settings.setBaseBudget(s['base_budget'] as int);
        if (s['budget_reset_day'] != null) await _settings.setBudgetResetDay(s['budget_reset_day'] as int);
        if (s['budget_reset_enabled'] != null) await _settings.setBudgetResetEnabled(s['budget_reset_enabled'] as bool);
        if (s['carry_over_enabled'] != null) await _settings.setCarryOverEnabled(s['carry_over_enabled'] as bool);
        if (s['carry_over_cap'] != null) await _settings.setCarryOverCap(s['carry_over_cap'] as int);
        if (s['carry_over_negative'] != null) await _settings.setCarryOverNegative(s['carry_over_negative'] as bool);
      }

      // Import categories
      for (final cat in (data['categories'] as List? ?? [])) {
        await _db.into(_db.categories).insert(CategoriesCompanion.insert(
          id: cat['id'] as String,
          name: cat['name'] as String,
          isDefault: Value((cat['is_default'] as int?) ?? 0),
        ));
      }

      // Import friends
      for (final f in (data['friends'] as List? ?? [])) {
        await _db.into(_db.friends).insert(FriendsCompanion.insert(
          id: f['id'] as String,
          name: f['name'] as String,
          phone: Value(f['phone'] as String?),
          createdAt: f['created_at'] as String,
        ));
      }

      // Import accounts
      for (final a in (data['accounts'] as List? ?? [])) {
        await _db.into(_db.accounts).insert(AccountsCompanion.insert(
          id: a['id'] as String,
          name: a['name'] as String,
          type: a['type'] as String,
          institution: Value(a['institution'] as String?),
          last4Digits: Value(a['last_4_digits'] as String?),
          color: Value(a['color'] as String?),
          icon: Value(a['icon'] as String?),
          trackedBalance: Value((a['tracked_balance'] as int?) ?? 0),
          currentBalance: Value((a['current_balance'] as int?) ?? 0),
          isCredit: Value((a['is_credit'] as int?) ?? 0),
          creditLimit: Value(a['credit_limit'] as int?),
          billingDay: Value(a['billing_day'] as int?),
          dueDay: Value(a['due_day'] as int?),
          isActive: Value((a['is_active'] as int?) ?? 1),
          isDefault: Value((a['is_default'] as int?) ?? 0),
          createdAt: a['created_at'] as String,
        ));
      }

      // Import loans
      for (final l in (data['loans'] as List? ?? [])) {
        await _db.into(_db.loans).insert(LoansCompanion.insert(
          id: l['id'] as String,
          name: l['name'] as String,
          type: l['type'] as String,
          principal: l['principal'] as int,
          interestRate: (l['interest_rate'] as num).toDouble(),
          tenureMonths: l['tenure_months'] as int,
          emiAmount: l['emi_amount'] as int,
          startDate: l['start_date'] as String,
          emiDay: l['emi_day'] as int,
          paymentsMade: Value((l['payments_made'] as int?) ?? 0),
          paymentAccountId: Value(l['payment_account_id'] as String?),
          paymentType: Value((l['payment_type'] as String?) ?? 'manual'),
          creditCardId: Value(l['credit_card_id'] as String?),
          lender: Value(l['lender'] as String?),
          purpose: Value(l['purpose'] as String?),
          isActive: Value((l['is_active'] as int?) ?? 1),
          foreclosureAmount: Value(l['foreclosure_amount'] as int?),
          createdAt: l['created_at'] as String,
        ));
      }

      // Import recurring transactions
      for (final r in (data['recurring_transactions'] as List? ?? [])) {
        await _db.into(_db.recurringTransactions).insert(
          RecurringTransactionsCompanion.insert(
            id: r['id'] as String,
            name: r['name'] as String,
            type: r['type'] as String,
            amount: r['amount'] as int,
            category: Value(r['category'] as String?),
            accountId: Value(r['account_id'] as String?),
            frequency: r['frequency'] as String,
            dayOfMonth: Value(r['day_of_month'] as int?),
            dayOfWeek: Value(r['day_of_week'] as int?),
            startDate: r['start_date'] as String,
            endDate: Value(r['end_date'] as String?),
            requiresVerification: Value((r['requires_verification'] as int?) ?? 1),
            autoApply: Value((r['auto_apply'] as int?) ?? 0),
            isAutopay: Value((r['is_autopay'] as int?) ?? 0),
            isActive: Value((r['is_active'] as int?) ?? 1),
            lastAppliedDate: Value(r['last_applied_date'] as String?),
            nextDueDate: Value(r['next_due_date'] as String?),
            linkedLoanId: Value(r['linked_loan_id'] as String?),
            createdAt: r['created_at'] as String,
          ),
        );
      }

      // Import credit card statements
      for (final s in (data['credit_card_statements'] as List? ?? [])) {
        await _db.into(_db.creditCardStatements).insert(
          CreditCardStatementsCompanion.insert(
            id: s['id'] as String,
            cardAccountId: s['card_account_id'] as String,
            statementDate: s['statement_date'] as String,
            dueDate: s['due_date'] as String,
            statementAmount: s['statement_amount'] as int,
            minimumDue: s['minimum_due'] as int,
            paidAmount: Value((s['paid_amount'] as int?) ?? 0),
            paidDate: Value(s['paid_date'] as String?),
            isFullyPaid: Value((s['is_fully_paid'] as int?) ?? 0),
            createdAt: s['created_at'] as String,
          ),
        );
      }

      // Import loan EMI schedules
      for (final sched in (data['loan_emi_schedules'] as List? ?? [])) {
        await _db.into(_db.loanEmiSchedule).insert(
          LoanEmiScheduleCompanion.insert(
            id: sched['id'] as String,
            loanId: sched['loan_id'] as String,
            monthNumber: sched['month_number'] as int,
            emiAmount: sched['emi_amount'] as int,
            createdAt: sched['created_at'] as String,
          ),
        );
      }

      // Import events
      for (final e in (data['events'] as List? ?? [])) {
        await _db.into(_db.events).insert(EventsCompanion.insert(
          id: e['id'] as String,
          type: e['type'] as String,
          amount: e['amount'] as int,
          category: Value(e['category'] as String?),
          description: Value(e['description'] as String?),
          friendId: Value(e['friend_id'] as String?),
          accountId: Value(e['account_id'] as String?),
          fromAccountId: Value(e['from_account_id'] as String?),
          toAccountId: Value(e['to_account_id'] as String?),
          recurringId: Value(e['recurring_id'] as String?),
          loanId: Value(e['loan_id'] as String?),
          eventDate: e['event_date'] as String,
          createdAt: e['created_at'] as String,
        ));
      }

      // Import month records
      for (final m in (data['month_records'] as List? ?? [])) {
        await _db.into(_db.monthRecords).insert(MonthRecordsCompanion.insert(
          id: m['id'] as String,
          year: m['year'] as int,
          month: m['month'] as int,
          baseBudget: m['base_budget'] as int,
          carryOverAmount: Value((m['carry_over_amount'] as int?) ?? 0),
          totalBudget: m['total_budget'] as int,
          totalSpent: Value((m['total_spent'] as int?) ?? 0),
          endingBalance: Value((m['ending_balance'] as int?) ?? 0),
          createdAt: m['created_at'] as String,
        ));
      }
    });
  }

  /// Clear all transaction data.
  Future<void> clearAllData({bool keepFriends = true}) async {
    await _db.transaction(() async {
      await _db.delete(_db.events).go();
      await _db.delete(_db.monthRecords).go();
      await _db.delete(_db.pendingTransactions).go();

      if (!keepFriends) {
        await _db.delete(_db.friends).go();
      }
    });
  }
}
