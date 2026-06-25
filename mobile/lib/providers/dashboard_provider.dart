import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/engine.dart';
import '../core/budget.dart';
import 'database_provider.dart';

/// Dashboard data model.
class DashboardData {
  final int baseBudget;
  final int available;
  final int spent;
  final int liabilities;
  final int receivables;
  final int unpaidCommitments;
  final List<Map<String, dynamic>> unpaidRecurringItems;
  final List<Map<String, dynamic>> onHoldItems;
  final Map<String, int> categorySpend;
  final List<Map<String, dynamic>> recentEvents;
  final int currentMonth;
  final int currentYear;
  final Map<String, int> friendBalances;
  final Map<String, String> friendNames;

  const DashboardData({
    required this.baseBudget,
    required this.available,
    required this.spent,
    required this.liabilities,
    required this.receivables,
    this.unpaidCommitments = 0,
    this.unpaidRecurringItems = const [],
    this.onHoldItems = const [],
    required this.categorySpend,
    required this.recentEvents,
    required this.currentMonth,
    required this.currentYear,
    required this.friendBalances,
    required this.friendNames,
  });
}

/// Provides computed dashboard data from the database.
final dashboardProvider = FutureProvider.autoDispose<DashboardData>((ref) async {
  final eventDao = ref.watch(eventDaoProvider);
  final settingsDao = ref.watch(settingsDaoProvider);
  final friendDao = ref.watch(friendDaoProvider);
  final recurringDao = ref.watch(recurringDaoProvider);

  final now = DateTime.now();
  final resetDay = await settingsDao.getBudgetResetDay();
  final (year, month) = getBudgetPeriod(now, resetDay);

  final baseBudget = await settingsDao.getBaseBudget();
  final events = await eventDao.getEventsAsMaps(month: month, year: year);
  final allEvents = await eventDao.getEventsAsMaps();

  final available = computeAvailableBudget(baseBudget, events);
  final spent = computeMonthlySpend(events, month, year);
  final liabilities = computeOutstandingLiabilities(allEvents);
  final receivables = computeOutstandingReceivables(allEvents);
  final categorySpend = computeCategorySpend(events, month: month, year: year);
  final friendBalances = computeFriendBalances(allEvents);

  // Compute unpaid recurring commitments for this month.
  // The set of "expected this month" is anything whose nextDueDate falls inside
  // the budget period, plus monthly/weekly/daily items that always fall in.
  // Match-against-events uses recurring_id as the truth — the legacy
  // description-fallback was fragile and double-counted on rename.
  final activeRecurring = await recurringDao.getRecurring();
  final unpaidRecurring = <Map<String, dynamic>>[];
  final onHoldItems = <Map<String, dynamic>>[];

  // Compute the start/end of the current budget period so we can window dates.
  final periodStart = DateTime(year, month, resetDay);
  final periodEnd = DateTime(year, month + 1, resetDay)
      .subtract(const Duration(days: 1));

  for (final rec in activeRecurring) {
    if (rec.type != 'expense' && rec.type != 'emi_payment') continue;

    final nextDue = rec.nextDueDate != null
        ? DateTime.tryParse(rec.nextDueDate!)
        : null;

    bool relevantThisMonth;
    if (rec.frequency == 'monthly' ||
        rec.frequency == 'daily' ||
        rec.frequency == 'weekly') {
      relevantThisMonth = true;
    } else {
      relevantThisMonth = nextDue != null &&
          !nextDue.isBefore(periodStart) &&
          !nextDue.isAfter(periodEnd);
    }

    if (!relevantThisMonth) continue;

    final hasEvent = events.any((e) => e['recurring_id'] == rec.id);
    final item = {
      'id': rec.id,
      'type': rec.type,
      'amount': rec.amount,
      'name': rec.name,
      'is_autopay': rec.isAutopay,
      'next_due_date': rec.nextDueDate,
      'account_id': rec.accountId,
    };

    if (!hasEvent) {
      unpaidRecurring.add(item);
      if (rec.isAutopay == 1) {
        onHoldItems.add({
          ...item,
          'reason': rec.dayOfMonth != null
              ? 'Auto-pay on day ${rec.dayOfMonth}'
              : 'Auto-pay scheduled',
        });
      }
    }
  }
  final unpaidCommitments = computeUnpaidCommitments(unpaidRecurring);

  // Build friend name map
  final friends = await friendDao.getFriends();
  final friendNames = <String, String>{
    for (final f in friends) f.id: f.name,
  };

  // Recent events for quick list
  final recentEvents = events.take(5).toList();

  return DashboardData(
    baseBudget: baseBudget,
    available: available - unpaidCommitments,
    spent: spent,
    liabilities: liabilities,
    receivables: receivables,
    unpaidCommitments: unpaidCommitments,
    unpaidRecurringItems: unpaidRecurring,
    onHoldItems: onHoldItems,
    categorySpend: categorySpend,
    recentEvents: recentEvents,
    currentMonth: month,
    currentYear: year,
    friendBalances: friendBalances,
    friendNames: friendNames,
  );
});
