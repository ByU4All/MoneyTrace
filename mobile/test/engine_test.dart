import 'package:flutter_test/flutter_test.dart';
import 'package:moneytrace/core/engine.dart';

void main() {
  group('computeAvailableBudget', () {
    test('returns base budget with no events', () {
      expect(computeAvailableBudget(1000000, []), 1000000);
    });

    test('subtracts expenses', () {
      final events = [
        {'type': 'expense', 'amount': 50000},
        {'type': 'expense', 'amount': 30000},
      ];
      expect(computeAvailableBudget(1000000, events), 920000);
    });

    test('subtracts liabilities', () {
      final events = [
        {'type': 'liability', 'amount': 20000},
      ];
      expect(computeAvailableBudget(1000000, events), 980000);
    });

    test('adds settlements received', () {
      final events = [
        {'type': 'settlement_received', 'amount': 10000},
      ];
      expect(computeAvailableBudget(1000000, events), 1010000);
    });

    test('adds budget adjustments', () {
      final events = [
        {'type': 'budget_adjustment', 'amount': 50000},
      ];
      expect(computeAvailableBudget(1000000, events), 1050000);
    });

    test('subtracts EMI payments', () {
      final events = [
        {'type': 'emi_payment', 'amount': 100000},
      ];
      expect(computeAvailableBudget(1000000, events), 900000);
    });

    test('ignores transfers and income', () {
      final events = [
        {'type': 'transfer', 'amount': 50000},
        {'type': 'income', 'amount': 100000},
        {'type': 'receivable', 'amount': 30000},
        {'type': 'settlement_paid', 'amount': 20000},
      ];
      expect(computeAvailableBudget(1000000, events), 1000000);
    });
  });

  group('computeFriendBalances', () {
    test('tracks receivables and settlements', () {
      final events = [
        {'type': 'receivable', 'amount': 10000, 'friend_id': 'f1'},
        {'type': 'settlement_received', 'amount': 5000, 'friend_id': 'f1'},
      ];
      final balances = computeFriendBalances(events);
      expect(balances['f1'], 5000); // friend still owes 5000
    });

    test('tracks liabilities', () {
      final events = [
        {'type': 'liability', 'amount': 20000, 'friend_id': 'f2'},
      ];
      final balances = computeFriendBalances(events);
      expect(balances['f2'], -20000); // you owe 20000
    });
  });

  group('computeOutstandingLiabilities', () {
    test('returns 0 with no events', () {
      expect(computeOutstandingLiabilities([]), 0);
    });

    test('sums liabilities minus settlements', () {
      final events = [
        {'type': 'liability', 'amount': 50000},
        {'type': 'settlement_paid', 'amount': 20000},
      ];
      expect(computeOutstandingLiabilities(events), 30000);
    });

    test('never goes negative', () {
      final events = [
        {'type': 'settlement_paid', 'amount': 50000},
      ];
      expect(computeOutstandingLiabilities(events), 0);
    });
  });

  group('computeCategorySpend', () {
    test('groups expenses by category', () {
      final events = [
        {'type': 'expense', 'amount': 10000, 'category': 'Food', 'event_date': '2026-03-01'},
        {'type': 'expense', 'amount': 5000, 'category': 'Food', 'event_date': '2026-03-02'},
        {'type': 'expense', 'amount': 8000, 'category': 'Transport', 'event_date': '2026-03-01'},
      ];
      final spend = computeCategorySpend(events, month: 3, year: 2026);
      expect(spend['Food'], 15000);
      expect(spend['Transport'], 8000);
    });

    test('ignores non-expense types', () {
      final events = [
        {'type': 'income', 'amount': 100000, 'category': 'Salary', 'event_date': '2026-03-01'},
      ];
      final spend = computeCategorySpend(events, month: 3, year: 2026);
      expect(spend.isEmpty, true);
    });
  });
}
