import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../data/daos/event_dao.dart';
import '../data/daos/friend_dao.dart';
import '../data/daos/account_dao.dart';
import '../data/daos/recurring_dao.dart';
import '../data/daos/loan_dao.dart';
import '../data/daos/credit_card_dao.dart';
import '../data/daos/settings_dao.dart';
import '../data/daos/audit_dao.dart';
import '../data/daos/bill_photo_dao.dart';
import '../data/daos/data_dao.dart';

/// Global database instance.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

/// DAO providers — one per entity.
final eventDaoProvider = Provider((ref) => EventDao(ref.watch(databaseProvider)));
final friendDaoProvider = Provider((ref) => FriendDao(ref.watch(databaseProvider)));
final accountDaoProvider = Provider((ref) => AccountDao(ref.watch(databaseProvider)));
final recurringDaoProvider = Provider((ref) => RecurringDao(ref.watch(databaseProvider)));
final loanDaoProvider = Provider((ref) => LoanDao(ref.watch(databaseProvider)));
final creditCardDaoProvider = Provider((ref) => CreditCardDao(ref.watch(databaseProvider)));
final settingsDaoProvider = Provider((ref) => SettingsDao(ref.watch(databaseProvider)));
final auditDaoProvider = Provider((ref) => AuditDao(ref.watch(databaseProvider)));
final billPhotoDaoProvider = Provider((ref) => BillPhotoDao(ref.watch(databaseProvider)));
final dataDaoProvider = Provider((ref) => DataDao(
  ref.watch(databaseProvider),
  ref.watch(settingsDaoProvider),
));
