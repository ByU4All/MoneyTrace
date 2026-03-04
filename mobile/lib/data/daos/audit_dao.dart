import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database.dart';

class AuditDao {
  final AppDatabase _db;
  const AuditDao(this._db);

  static const _uuid = Uuid();

  Future<String> createAuditLog({
    required String action,
    required String entityType,
    required String entityId,
    String? entityName,
    String? oldValues,
    String? newValues,
    String? description,
    bool isMoneyRelated = false,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now().toIso8601String().split('T')[0];

    await _db.into(_db.auditLog).insert(AuditLogCompanion.insert(
      id: id,
      action: action,
      entityType: entityType,
      entityId: entityId,
      auditEntityName: Value(entityName),
      oldValues: Value(oldValues),
      newValues: Value(newValues),
      description: Value(description),
      isMoneyRelated: Value(isMoneyRelated ? 1 : 0),
      createdAt: now,
    ));

    return id;
  }
}
