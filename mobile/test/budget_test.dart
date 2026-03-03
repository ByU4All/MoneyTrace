import 'package:flutter_test/flutter_test.dart';
import 'package:moneytrace/core/budget.dart';

void main() {
  group('shouldResetBudget', () {
    test('returns false when disabled', () {
      expect(
        shouldResetBudget(
          today: DateTime(2026, 3, 15),
          resetDay: 1,
          resetEnabled: false,
        ),
        false,
      );
    });

    test('returns true when never reset and past reset day', () {
      expect(
        shouldResetBudget(
          today: DateTime(2026, 3, 15),
          resetDay: 1,
        ),
        true,
      );
    });

    test('returns false when already reset this period', () {
      expect(
        shouldResetBudget(
          today: DateTime(2026, 3, 15),
          resetDay: 1,
          lastResetDate: DateTime(2026, 3, 1),
        ),
        false,
      );
    });
  });

  group('calculateCarryOver', () {
    test('returns 0 when disabled', () {
      expect(
        calculateCarryOver(endingBalance: 50000, carryOverEnabled: false),
        0,
      );
    });

    test('returns full balance when no cap', () {
      expect(
        calculateCarryOver(endingBalance: 50000, carryOverEnabled: true),
        50000,
      );
    });

    test('caps at max', () {
      expect(
        calculateCarryOver(
          endingBalance: 50000,
          carryOverEnabled: true,
          carryOverCap: 30000,
        ),
        30000,
      );
    });

    test('does not carry negative by default', () {
      expect(
        calculateCarryOver(endingBalance: -10000, carryOverEnabled: true),
        0,
      );
    });

    test('carries negative when enabled', () {
      expect(
        calculateCarryOver(
          endingBalance: -10000,
          carryOverEnabled: true,
          carryOverNegative: true,
        ),
        -10000,
      );
    });
  });

  group('getBudgetPeriod', () {
    test('returns current month when past reset day', () {
      expect(getBudgetPeriod(DateTime(2026, 3, 15), 1), (2026, 3));
    });

    test('returns previous month when before reset day', () {
      expect(getBudgetPeriod(DateTime(2026, 3, 5), 15), (2026, 2));
    });

    test('handles January rollover', () {
      expect(getBudgetPeriod(DateTime(2026, 1, 5), 15), (2025, 12));
    });
  });
}
