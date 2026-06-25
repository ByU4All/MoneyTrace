import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database.dart';

class RecurringDao {
  final AppDatabase _db;
  const RecurringDao(this._db);

  static const _uuid = Uuid();

  Future<String> createRecurring({
    required String name,
    required String type,
    required int amount,
    String? category,
    String? accountId,
    required String frequency,
    int? dayOfMonth,
    int? dayOfWeek,
    required String startDate,
    String? endDate,
    bool requiresVerification = true,
    bool autoApply = false,
    bool isAutopay = false,
    String? linkedLoanId,
    String? nextDueDate,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now().toIso8601String().split('T')[0];

    await _db.into(_db.recurringTransactions).insert(
      RecurringTransactionsCompanion.insert(
        id: id,
        name: name,
        type: type,
        amount: amount,
        category: Value(category),
        accountId: Value(accountId),
        frequency: frequency,
        dayOfMonth: Value(dayOfMonth),
        dayOfWeek: Value(dayOfWeek),
        startDate: startDate,
        endDate: Value(endDate),
        nextDueDate: Value(nextDueDate),
        requiresVerification: Value(requiresVerification ? 1 : 0),
        autoApply: Value(autoApply ? 1 : 0),
        isAutopay: Value(isAutopay ? 1 : 0),
        linkedLoanId: Value(linkedLoanId),
        createdAt: now,
      ),
    );

    return id;
  }

  Future<List<RecurringTransaction>> getRecurring({bool activeOnly = true}) async {
    final query = _db.select(_db.recurringTransactions);
    if (activeOnly) {
      query.where((r) => r.isActive.equals(1));
    }
    query.orderBy([(r) => OrderingTerm.asc(r.nextDueDate)]);
    return query.get();
  }

  Future<RecurringTransaction?> getRecurringById(String id) async {
    return (_db.select(_db.recurringTransactions)
          ..where((r) => r.id.equals(id)))
        .getSingleOrNull();
  }

  Future<bool> updateRecurring(String id, {
    String? name,
    int? amount,
    String? category,
    String? accountId,
    int? dayOfMonth,
    String? endDate,
    bool? isActive,
    bool? isAutopay,
    String? lastAppliedDate,
    String? nextDueDate,
  }) async {
    final companion = RecurringTransactionsCompanion(
      name: name != null ? Value(name) : const Value.absent(),
      amount: amount != null ? Value(amount) : const Value.absent(),
      category: category != null ? Value(category) : const Value.absent(),
      accountId: accountId != null ? Value(accountId) : const Value.absent(),
      dayOfMonth: dayOfMonth != null ? Value(dayOfMonth) : const Value.absent(),
      endDate: endDate != null ? Value(endDate) : const Value.absent(),
      isActive: isActive != null ? Value(isActive ? 1 : 0) : const Value.absent(),
      isAutopay: isAutopay != null ? Value(isAutopay ? 1 : 0) : const Value.absent(),
      lastAppliedDate: lastAppliedDate != null ? Value(lastAppliedDate) : const Value.absent(),
      nextDueDate: nextDueDate != null ? Value(nextDueDate) : const Value.absent(),
    );

    final count = await (_db.update(_db.recurringTransactions)
          ..where((r) => r.id.equals(id)))
        .write(companion);
    return count > 0;
  }

  Future<bool> deleteRecurring(String id) async {
    final count = await (_db.delete(_db.recurringTransactions)
          ..where((r) => r.id.equals(id)))
        .go();
    return count > 0;
  }

  // Pending transactions

  Future<List<PendingTransaction>> getPendingTransactions() async {
    return (_db.select(_db.pendingTransactions)
          ..where((p) => p.status.equals('pending'))
          ..orderBy([(p) => OrderingTerm.asc(p.dueDate)]))
        .get();
  }

  Future<String> createPending({
    required String recurringId,
    required String dueDate,
    required int amount,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now().toIso8601String().split('T')[0];

    await _db.into(_db.pendingTransactions).insert(
      PendingTransactionsCompanion.insert(
        id: id,
        recurringId: recurringId,
        dueDate: dueDate,
        amount: amount,
        createdAt: now,
      ),
    );

    return id;
  }

  Future<void> updatePendingStatus(String id, String status) async {
    final now = DateTime.now().toIso8601String().split('T')[0];
    await (_db.update(_db.pendingTransactions)
          ..where((p) => p.id.equals(id)))
        .write(PendingTransactionsCompanion(
      status: Value(status),
      actionDate: Value(now),
    ));
  }
}
