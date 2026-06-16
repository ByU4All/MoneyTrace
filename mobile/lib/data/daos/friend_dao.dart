import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database.dart';

class FriendDao {
  final AppDatabase _db;
  const FriendDao(this._db);

  static const _uuid = Uuid();

  Future<String> createFriend({
    required String name,
    String? phone,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now().toIso8601String().split('T')[0];

    await _db.into(_db.friends).insert(FriendsCompanion.insert(
      id: id,
      name: name,
      phone: Value(phone),
      createdAt: now,
    ));

    return id;
  }

  Future<List<Friend>> getFriends() async {
    return (_db.select(_db.friends)
          ..orderBy([(f) => OrderingTerm.asc(f.name)]))
        .get();
  }

  Future<Friend?> getFriend(String id) async {
    return (_db.select(_db.friends)..where((f) => f.id.equals(id)))
        .getSingleOrNull();
  }

  Future<bool> updateFriend(String id, {String? name, String? phone}) async {
    final companion = FriendsCompanion(
      name: name != null ? Value(name) : const Value.absent(),
      phone: phone != null ? Value(phone) : const Value.absent(),
    );

    final count = await (_db.update(_db.friends)
          ..where((f) => f.id.equals(id)))
        .write(companion);
    return count > 0;
  }

  Future<bool> deleteFriend(String id) async {
    return _db.transaction(() async {
      // Strip any leftover multi-tag references so the join table never
      // holds rows pointing at a friend that no longer exists.
      await (_db.delete(_db.eventFriends)
            ..where((ef) => ef.friendId.equals(id)))
          .go();
      final count = await (_db.delete(_db.friends)
            ..where((f) => f.id.equals(id)))
          .go();
      return count > 0;
    });
  }
}
