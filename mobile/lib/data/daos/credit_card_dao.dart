import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database.dart';

class CreditCardDao {
  final AppDatabase _db;
  const CreditCardDao(this._db);

  static const _uuid = Uuid();

  Future<String> createStatement({
    required String cardAccountId,
    required String statementDate,
    required String dueDate,
    required int statementAmount,
    required int minimumDue,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now().toIso8601String().split('T')[0];

    await _db.into(_db.creditCardStatements).insert(
      CreditCardStatementsCompanion.insert(
        id: id,
        cardAccountId: cardAccountId,
        statementDate: statementDate,
        dueDate: dueDate,
        statementAmount: statementAmount,
        minimumDue: minimumDue,
        createdAt: now,
      ),
    );

    return id;
  }

  Future<List<CreditCardStatement>> getStatements({
    String? cardAccountId,
    bool unpaidOnly = false,
  }) async {
    final query = _db.select(_db.creditCardStatements);
    if (cardAccountId != null) {
      query.where((s) => s.cardAccountId.equals(cardAccountId));
    }
    if (unpaidOnly) {
      query.where((s) => s.isFullyPaid.equals(0));
    }
    query.orderBy([(s) => OrderingTerm.desc(s.dueDate)]);
    return query.get();
  }

  Future<CreditCardStatement?> getStatement(String id) async {
    return (_db.select(_db.creditCardStatements)
          ..where((s) => s.id.equals(id)))
        .getSingleOrNull();
  }

  Future<void> recordPayment(String statementId, int amount) async {
    final stmt = await getStatement(statementId);
    if (stmt == null) return;

    final newPaid = stmt.paidAmount + amount;
    final isFullyPaid = newPaid >= stmt.statementAmount;
    final now = DateTime.now().toIso8601String().split('T')[0];

    await (_db.update(_db.creditCardStatements)
          ..where((s) => s.id.equals(statementId)))
        .write(CreditCardStatementsCompanion(
      paidAmount: Value(newPaid),
      paidDate: Value(now),
      isFullyPaid: Value(isFullyPaid ? 1 : 0),
    ));
  }
}
