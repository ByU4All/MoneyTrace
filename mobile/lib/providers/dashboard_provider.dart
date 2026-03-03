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

  // Build friend name map
  final friends = await friendDao.getFriends();
  final friendNames = <String, String>{
    for (final f in friends) f.id: f.name,
  };

  // Recent events for quick list
  final recentEvents = events.take(10).toList();

  return DashboardData(
    baseBudget: baseBudget,
    available: available,
    spent: spent,
    liabilities: liabilities,
    receivables: receivables,
    categorySpend: categorySpend,
    recentEvents: recentEvents,
    currentMonth: month,
    currentYear: year,
    friendBalances: friendBalances,
    friendNames: friendNames,
  );
});
