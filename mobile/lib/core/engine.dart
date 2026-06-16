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

/// Days from `now` to the next occurrence of the EMI day-of-month.
/// Returns 0 if today *is* the EMI day. Clamps `emiDay` to a safe value
/// for short months (e.g. 31 in February becomes the last day of February).
int daysUntilNextEmi({required int emiDay, required DateTime now}) {
  final today = DateTime(now.year, now.month, now.day);
  final daysInThisMonth = DateTime(now.year, now.month + 1, 0).day;
  final clampedThisMonth = emiDay.clamp(1, daysInThisMonth);
  final dueThisMonth = DateTime(now.year, now.month, clampedThisMonth);

  if (!dueThisMonth.isBefore(today)) {
    return dueThisMonth.difference(today).inDays;
  }

  final nextMonth = DateTime(now.year, now.month + 1, 1);
  final daysInNextMonth = DateTime(nextMonth.year, nextMonth.month + 1, 0).day;
  final clampedNext = emiDay.clamp(1, daysInNextMonth);
  final dueNextMonth = DateTime(nextMonth.year, nextMonth.month, clampedNext);
  return dueNextMonth.difference(today).inDays;
}

/// Net balance per friend. Positive = friend owes you, Negative = you owe friend.
/// Reads only the legacy primary `friend_id` on events because that's the field
/// LIABILITY/RECEIVABLE/SETTLEMENT semantics depend on. Multi-friend tags from
/// the event_friends join table are *history* labels with no balance meaning.
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

/// Compute the balance impact of an event on an account.
/// Returns negative for outflows, positive for inflows, 0 for no impact.
int balanceImpact(String type, int amount) {
  switch (type) {
    case 'expense':
    case 'settlement_paid':
    case 'credit_card_payment':
    case 'emi_payment':
      return -amount;
    case 'income':
    case 'settlement_received':
      return amount;
    default:
      return 0;
  }
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
