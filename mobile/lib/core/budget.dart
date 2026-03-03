/// Budget reset and carry over logic.
///
/// Handles monthly budget cycling with optional carry over calculations.

import 'events.dart';

/// Check if budget should be reset.
bool shouldResetBudget({
  required DateTime today,
  required int resetDay,
  DateTime? lastResetDate,
  bool resetEnabled = true,
}) {
  if (!resetEnabled) return false;

  if (lastResetDate == null) {
    return today.day >= resetDay;
  }

  late final DateTime expectedReset;

  if (today.day >= resetDay) {
    expectedReset = DateTime(today.year, today.month, resetDay);
  } else {
    if (today.month == 1) {
      expectedReset = DateTime(today.year - 1, 12, resetDay);
    } else {
      expectedReset = DateTime(today.year, today.month - 1, resetDay);
    }
  }

  return lastResetDate.isBefore(expectedReset);
}

/// Calculate carry over amount from previous month.
int calculateCarryOver({
  required int endingBalance,
  required bool carryOverEnabled,
  int? carryOverCap,
  bool carryOverNegative = false,
}) {
  if (!carryOverEnabled) return 0;

  if (endingBalance < 0) {
    return carryOverNegative ? endingBalance : 0;
  }

  if (carryOverCap != null && endingBalance > carryOverCap) {
    return carryOverCap;
  }

  return endingBalance;
}

/// Calculate total spending for a specific month.
int calculateMonthSpend(List<Map<String, dynamic>> events, int year, int month) {
  int total = 0;
  for (final e in events) {
    final eventDate = DateTime.parse(e['event_date'] as String);
    if (eventDate.year == year && eventDate.month == month) {
      final etype = e['type'] as String;
      if (etype == EventType.expense.value ||
          etype == EventType.settlementPaid.value) {
        total += e['amount'] as int;
      }
    }
  }
  return total;
}

/// Get the budget period (year, month) for a given date.
(int year, int month) getBudgetPeriod(DateTime today, int resetDay) {
  if (today.day >= resetDay) {
    return (today.year, today.month);
  } else {
    if (today.month == 1) {
      return (today.year - 1, 12);
    } else {
      return (today.year, today.month - 1);
    }
  }
}
