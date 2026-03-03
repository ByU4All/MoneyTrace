/// Ledger engine — source of truth for all financial calculations.
///
/// RULES:
/// - All amounts are integers in paise (minor units)
/// - Budget impact happens exactly once
/// - Engine is pure: no DB, no IO, no formatting
/// - Settlements never double-count budget
/// - Receivables excluded from budget by default

import 'events.dart';

/// Compute remaining available budget.
///
/// Formula:
///   Available = Base + Adjustments + Settlements Received
///             - Expenses - Liabilities - EMI Payments
int computeAvailableBudget(int baseBudget, Iterable<Map<String, dynamic>> events) {
  int budget = baseBudget;

  for (final e in events) {
    final etype = e['type'] as String;
    final amount = e['amount'] as int;

    if (etype == EventType.expense.value) {
      budget -= amount;
    } else if (etype == EventType.liability.value) {
      budget -= amount;
    } else if (etype == EventType.settlementReceived.value) {
      budget += amount;
    } else if (etype == EventType.budgetAdjustment.value) {
      budget += amount;
    } else if (etype == EventType.emiPayment.value) {
      budget -= amount;
    }
    // RECEIVABLE, SETTLEMENT_PAID, INCOME, TRANSFER -> no budget impact
  }

  return budget;
}

/// Compute total amount reserved for unpaid recurring transactions.
int computeUnpaidCommitments(Iterable<Map<String, dynamic>> unpaidRecurring) {
  int total = 0;

  for (final rec in unpaidRecurring) {
    final recType = rec['type'] as String? ?? '';
    final amount = rec['amount'] as int? ?? 0;

    if (recType == 'expense' || recType == 'emi_payment') {
      total += amount;
    }
  }

  return total;
}

/// Cash that actually left your wallet in a month.
int computeMonthlySpend(
  Iterable<Map<String, dynamic>> events,
  int month,
  int year,
) {
  int spend = 0;

  for (final e in events) {
    final d = DateTime.parse(e['event_date'] as String);
    if (d.month != month || d.year != year) continue;

    final etype = e['type'] as String;
    if (etype == EventType.expense.value ||
        etype == EventType.settlementPaid.value) {
      spend += e['amount'] as int;
    }
  }

  return spend;
}

/// Total amount you owe to others.
int computeOutstandingLiabilities(Iterable<Map<String, dynamic>> events) {
  int total = 0;

  for (final e in events) {
    final etype = e['type'] as String;
    if (etype == EventType.liability.value) {
      total += e['amount'] as int;
    } else if (etype == EventType.settlementPaid.value) {
      total -= e['amount'] as int;
    }
  }

  return total < 0 ? 0 : total;
}

/// Total amount others owe you.
int computeOutstandingReceivables(Iterable<Map<String, dynamic>> events) {
  int total = 0;

  for (final e in events) {
    final etype = e['type'] as String;
    if (etype == EventType.receivable.value) {
      total += e['amount'] as int;
    } else if (etype == EventType.settlementReceived.value) {
      total -= e['amount'] as int;
    }
  }

  return total < 0 ? 0 : total;
}

/// Net balance per friend. Positive = friend owes you, Negative = you owe friend.
Map<String, int> computeFriendBalances(Iterable<Map<String, dynamic>> events) {
  final balances = <String, int>{};

  for (final e in events) {
    final friendId = e['friend_id'] as String?;
    if (friendId == null) continue;

    final amount = e['amount'] as int;
    final etype = e['type'] as String;

    balances[friendId] = (balances[friendId] ?? 0);

    if (etype == EventType.receivable.value) {
      balances[friendId] = balances[friendId]! + amount;
    } else if (etype == EventType.liability.value) {
      balances[friendId] = balances[friendId]! - amount;
    } else if (etype == EventType.settlementReceived.value) {
      balances[friendId] = balances[friendId]! - amount;
    } else if (etype == EventType.settlementPaid.value) {
      balances[friendId] = balances[friendId]! + amount;
    }
  }

  return balances;
}

/// Category-wise spending. Only EXPENSE events count.
Map<String, int> computeCategorySpend(
  Iterable<Map<String, dynamic>> events, {
  int? month,
  int? year,
}) {
  final totals = <String, int>{};

  for (final e in events) {
    if (e['type'] != EventType.expense.value) continue;

    if (month != null && year != null) {
      final d = DateTime.parse(e['event_date'] as String);
      if (d.month != month || d.year != year) continue;
    }

    final category = (e['category'] as String?) ?? 'Uncategorized';
    totals[category] = (totals[category] ?? 0) + (e['amount'] as int);
  }

  return totals;
}
