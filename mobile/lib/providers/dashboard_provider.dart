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

  // Compute unpaid recurring commitments for this month
  final activeRecurring = await recurringDao.getRecurring();
  final unpaidRecurring = <Map<String, dynamic>>[];
  for (final rec in activeRecurring) {
    if (rec.type != 'expense' && rec.type != 'emi_payment') continue;

    // Determine if this recurring is relevant for the current budget period
    bool relevantThisMonth = false;
    if (rec.frequency == 'monthly' || rec.frequency == 'daily' || rec.frequency == 'weekly') {
      // Always relevant — check if already paid this month
      relevantThisMonth = true;
    } else if (rec.frequency == 'yearly') {
      // Only relevant if nextDueDate falls in this month
      final nextDue = rec.nextDueDate != null ? DateTime.tryParse(rec.nextDueDate!) : null;
      if (nextDue != null && nextDue.month == month && nextDue.year == year) {
        relevantThisMonth = true;
      }
    }

    if (relevantThisMonth) {
      // Check if an event matching this recurring's description already exists this month
      final hasEvent = events.any((e) =>
          e['recurring_id'] == rec.id ||
          (e['description'] == rec.name && e['type'] == rec.type));
      if (!hasEvent) {
        unpaidRecurring.add({'type': rec.type, 'amount': rec.amount, 'name': rec.name});
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
    categorySpend: categorySpend,
    recentEvents: recentEvents,
    currentMonth: month,
    currentYear: year,
    friendBalances: friendBalances,
    friendNames: friendNames,
  );
});
