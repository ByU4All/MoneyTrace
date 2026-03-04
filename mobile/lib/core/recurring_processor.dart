import '../data/daos/event_dao.dart';
import '../data/daos/account_dao.dart';
import '../data/daos/recurring_dao.dart';
import 'engine.dart';

/// Processes autopay recurring transactions on app startup.
class RecurringProcessor {
  final EventDao _eventDao;
  final AccountDao _accountDao;
  final RecurringDao _recurringDao;

  const RecurringProcessor(this._eventDao, this._accountDao, this._recurringDao);

  /// Process all overdue autopay recurring transactions.
  /// Creates events and updates balances for each missed cycle.
  Future<int> processAutopay() async {
    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    int processed = 0;

    final recurring = await _recurringDao.getRecurring();

    for (final rec in recurring) {
      if (rec.isAutopay != 1) continue;

      var nextDue = rec.nextDueDate != null ? DateTime.tryParse(rec.nextDueDate!) : null;
      if (nextDue == null) continue;

      // Process all missed cycles
      while (!nextDue!.isAfter(now)) {
        final dueDateStr = '${nextDue.year}-${nextDue.month.toString().padLeft(2, '0')}-${nextDue.day.toString().padLeft(2, '0')}';

        // Create event
        await _eventDao.createEvent(
          type: rec.type,
          amount: rec.amount,
          category: rec.category,
          description: '${rec.name} (autopay)',
          accountId: rec.accountId,
          recurringId: rec.id,
          eventDate: dueDateStr,
        );

        // Update account balance
        if (rec.accountId != null) {
          final impact = balanceImpact(rec.type, rec.amount);
          if (impact != 0) {
            await _accountDao.updateBalance(rec.accountId!, impact);
          }
        }

        // Advance next due date
        nextDue = _advanceDueDate(nextDue, rec.frequency, rec.dayOfMonth);
        processed++;
      }

      // Update recurring with new next due date and last applied
      await _recurringDao.updateRecurring(
        rec.id,
        lastAppliedDate: todayStr,
        nextDueDate: '${nextDue.year}-${nextDue.month.toString().padLeft(2, '0')}-${nextDue.day.toString().padLeft(2, '0')}',
      );
    }

    return processed;
  }

  DateTime _advanceDueDate(DateTime current, String frequency, int? dayOfMonth) {
    switch (frequency) {
      case 'daily':
        return current.add(const Duration(days: 1));
      case 'weekly':
        return current.add(const Duration(days: 7));
      case 'monthly':
        final nextMonth = current.month == 12
            ? DateTime(current.year + 1, 1, dayOfMonth ?? current.day)
            : DateTime(current.year, current.month + 1, dayOfMonth ?? current.day);
        return nextMonth;
      case 'yearly':
        return DateTime(current.year + 1, current.month, dayOfMonth ?? current.day);
      default:
        return current.add(const Duration(days: 30));
    }
  }
}
