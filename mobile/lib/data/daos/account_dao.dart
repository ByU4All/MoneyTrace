import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database.dart';

class AccountDao {
  final AppDatabase _db;
  const AccountDao(this._db);

  static const _uuid = Uuid();

  Future<String> createAccount({
    required String name,
    required String type,
    String? institution,
    String? last4Digits,
    String? color,
    String? icon,
    int trackedBalance = 0,
    int currentBalance = 0,
    bool isCredit = false,
    int? creditLimit,
    int? billingDay,
    int? dueDay,
    bool isDefault = false,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now().toIso8601String().split('T')[0];

    await _db.into(_db.accounts).insert(AccountsCompanion.insert(
      id: id,
      name: name,
      type: type,
      institution: Value(institution),
      last4Digits: Value(last4Digits),
      color: Value(color),
      icon: Value(icon),
      trackedBalance: Value(trackedBalance),
      currentBalance: Value(currentBalance),
      isCredit: Value(isCredit ? 1 : 0),
      creditLimit: Value(creditLimit),
      billingDay: Value(billingDay),
      dueDay: Value(dueDay),
      isDefault: Value(isDefault ? 1 : 0),
      createdAt: now,
    ));

    return id;
  }

  Future<List<Account>> getAccounts({bool includeInactive = false}) async {
    final query = _db.select(_db.accounts);
    if (!includeInactive) {
      query.where((a) => a.isActive.equals(1));
    }
    query.orderBy([
      (a) => OrderingTerm.desc(a.isDefault),
      (a) => OrderingTerm.asc(a.name),
    ]);
    return query.get();
  }

  Future<Account?> getAccount(String id) async {
    return (_db.select(_db.accounts)..where((a) => a.id.equals(id)))
        .getSingleOrNull();
  }

  Future<bool> updateAccount(String id, {
    String? name,
    String? institution,
    String? last4Digits,
    String? color,
    bool? isActive,
    bool? isDefault,
    int? creditLimit,
    int? billingDay,
    int? dueDay,
    int? trackedBalance,
  }) async {
    final companion = AccountsCompanion(
      name: name != null ? Value(name) : const Value.absent(),
      institution: institution != null ? Value(institution) : const Value.absent(),
      last4Digits: last4Digits != null ? Value(last4Digits) : const Value.absent(),
      color: color != null ? Value(color) : const Value.absent(),
      isActive: isActive != null ? Value(isActive ? 1 : 0) : const Value.absent(),
      isDefault: isDefault != null ? Value(isDefault ? 1 : 0) : const Value.absent(),
      creditLimit: creditLimit != null ? Value(creditLimit) : const Value.absent(),
      billingDay: billingDay != null ? Value(billingDay) : const Value.absent(),
      dueDay: dueDay != null ? Value(dueDay) : const Value.absent(),
      trackedBalance: trackedBalance != null ? Value(trackedBalance) : const Value.absent(),
    );

    final count = await (_db.update(_db.accounts)
          ..where((a) => a.id.equals(id)))
        .write(companion);
    return count > 0;
  }

  Future<void> updateBalance(String id, int delta) async {
    await _db.customStatement(
      'UPDATE accounts SET tracked_balance = tracked_balance + ? WHERE id = ?',
      [delta, id],
    );
  }

  Future<bool> deleteAccount(String id) async {
    final count = await (_db.update(_db.accounts)
          ..where((a) => a.id.equals(id)))
        .write(const AccountsCompanion(isActive: Value(0)));
    return count > 0;
  }
}
