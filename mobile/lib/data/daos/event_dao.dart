import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database.dart';

const _sentinel = Object();

/// Data access object for financial events.
class EventDao {
  final AppDatabase _db;
  const EventDao(this._db);

  static const _uuid = Uuid();

  /// Create a new event. Returns the event ID.
  Future<String> createEvent({
    required String type,
    required int amount,
    String? category,
    String? description,
    String? friendId,
    String? accountId,
    String? fromAccountId,
    String? toAccountId,
    String? recurringId,
    String? loanId,
    required String eventDate,
    String? billPhotoPath,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now().toIso8601String();

    await _db.into(_db.events).insert(EventsCompanion.insert(
      id: id,
      type: type,
      amount: amount,
      category: Value(category),
      description: Value(description),
      friendId: Value(friendId),
      accountId: Value(accountId),
      fromAccountId: Value(fromAccountId),
      toAccountId: Value(toAccountId),
      recurringId: Value(recurringId),
      loanId: Value(loanId),
      eventDate: eventDate,
      createdAt: now,
      billPhotoPath: Value(billPhotoPath),
    ));

    return id;
  }

  /// Get all events, ordered by date descending.
  Future<List<Event>> getEvents({int? limit}) async {
    final query = _db.select(_db.events)
      ..orderBy([
        (e) => OrderingTerm.desc(e.eventDate),
        (e) => OrderingTerm.desc(e.createdAt),
      ]);
    if (limit != null) {
      query.limit(limit);
    }
    return query.get();
  }

  /// Get events as maps (for engine calculations).
  Future<List<Map<String, dynamic>>> getEventsAsMaps({
    int? month,
    int? year,
  }) async {
    final events = await getEvents();
    return events.map((e) {
      final map = <String, dynamic>{
        'id': e.id,
        'type': e.type,
        'amount': e.amount,
        'category': e.category,
        'description': e.description,
        'friend_id': e.friendId,
        'account_id': e.accountId,
        'from_account_id': e.fromAccountId,
        'to_account_id': e.toAccountId,
        'recurring_id': e.recurringId,
        'loan_id': e.loanId,
        'event_date': e.eventDate,
        'created_at': e.createdAt,
      };
      return map;
    }).where((m) {
      if (month != null && year != null) {
        final d = DateTime.parse(m['event_date'] as String);
        return d.month == month && d.year == year;
      }
      return true;
    }).toList();
  }

  /// Get a single event by ID.
  Future<Event?> getEventById(String id) async {
    return (_db.select(_db.events)..where((e) => e.id.equals(id)))
        .getSingleOrNull();
  }

  /// Update an existing event.
  Future<bool> updateEvent(String id, {
    String? type,
    int? amount,
    String? category,
    String? description,
    String? friendId,
    String? accountId,
    String? fromAccountId,
    String? toAccountId,
    String? eventDate,
    Object? billPhotoPath = _sentinel,
  }) async {
    final companion = EventsCompanion(
      type: type != null ? Value(type) : const Value.absent(),
      amount: amount != null ? Value(amount) : const Value.absent(),
      category: category != null ? Value(category) : const Value.absent(),
      description: description != null ? Value(description) : const Value.absent(),
      friendId: friendId != null ? Value(friendId) : const Value.absent(),
      accountId: accountId != null ? Value(accountId) : const Value.absent(),
      fromAccountId: fromAccountId != null ? Value(fromAccountId) : const Value.absent(),
      toAccountId: toAccountId != null ? Value(toAccountId) : const Value.absent(),
      eventDate: eventDate != null ? Value(eventDate) : const Value.absent(),
      billPhotoPath: billPhotoPath == _sentinel ? const Value.absent() : Value(billPhotoPath as String?),
    );

    final count = await (_db.update(_db.events)
          ..where((e) => e.id.equals(id)))
        .write(companion);
    return count > 0;
  }

  /// Delete an event by ID.
  Future<bool> deleteEvent(String id) async {
    final count = await (_db.delete(_db.events)
          ..where((e) => e.id.equals(id)))
        .go();
    return count > 0;
  }

  /// Get events linked to a friend either as the primary friend (Events.friendId)
  /// or as a multi-friend tag (event_friends join table).
  Future<List<Event>> getEventsByFriend(String friendId) async {
    final byPrimary = await (_db.select(_db.events)
          ..where((e) => e.friendId.equals(friendId)))
        .get();
    final tagged = await (_db.select(_db.events).join([
      innerJoin(_db.eventFriends, _db.eventFriends.eventId.equalsExp(_db.events.id)),
    ])
          ..where(_db.eventFriends.friendId.equals(friendId)))
        .map((row) => row.readTable(_db.events))
        .get();

    final seen = <String>{};
    final merged = <Event>[];
    for (final e in [...byPrimary, ...tagged]) {
      if (seen.add(e.id)) merged.add(e);
    }
    merged.sort((a, b) => b.eventDate.compareTo(a.eventDate));
    return merged;
  }

  /// Replace the set of friends tagged on an event with the given list.
  Future<void> tagFriends(String eventId, List<String> friendIds) async {
    await _db.transaction(() async {
      await (_db.delete(_db.eventFriends)
            ..where((ef) => ef.eventId.equals(eventId)))
          .go();
      for (final fid in friendIds) {
        await _db.into(_db.eventFriends).insert(
              EventFriendsCompanion.insert(eventId: eventId, friendId: fid),
              mode: InsertMode.insertOrIgnore,
            );
      }
    });
  }

  /// Read the friend IDs tagged on an event (multi-tag join table only;
  /// does not include the primary Events.friendId).
  Future<List<String>> getTaggedFriends(String eventId) async {
    final rows = await (_db.select(_db.eventFriends)
          ..where((ef) => ef.eventId.equals(eventId)))
        .get();
    return rows.map((r) => r.friendId).toList();
  }

  /// Null out the primary friend reference on every event linked to this friend.
  /// Also removes any join-table tags pointing at the friend.
  Future<int> unlinkFriend(String friendId) async {
    return _db.transaction(() async {
      final updated = await (_db.update(_db.events)
            ..where((e) => e.friendId.equals(friendId)))
          .write(const EventsCompanion(friendId: Value(null)));
      await (_db.delete(_db.eventFriends)
            ..where((ef) => ef.friendId.equals(friendId)))
          .go();
      return updated;
    });
  }

  /// Find RECEIVABLE events that were auto-created as split partners of an expense.
  /// Matches by type, eventDate, and the 'Split: <description>' naming convention.
  Future<List<Event>> findSplitReceivables(String eventDate, String? expenseDescription) async {
    final splitDesc = (expenseDescription != null && expenseDescription.isNotEmpty)
        ? 'Split: $expenseDescription'
        : 'Split';
    return (_db.select(_db.events)
          ..where((e) =>
              e.type.equals('receivable') &
              e.eventDate.equals(eventDate) &
              e.description.equals(splitDesc)))
        .get();
  }

  /// Delete every event linked to a friend (primary or multi-tag).
  /// Returns the number of deleted events.
  Future<int> deleteEventsByFriend(String friendId) async {
    return _db.transaction(() async {
      final ids = (await getEventsByFriend(friendId)).map((e) => e.id).toList();
      if (ids.isEmpty) return 0;
      await (_db.delete(_db.eventFriends)
            ..where((ef) => ef.eventId.isIn(ids)))
          .go();
      final deleted = await (_db.delete(_db.events)
            ..where((e) => e.id.isIn(ids)))
          .go();
      return deleted;
    });
  }

  /// Get events for a specific account.
  Future<List<Event>> getEventsByAccount(String accountId, {int limit = 50}) async {
    return (_db.select(_db.events)
          ..where((e) =>
              e.accountId.equals(accountId) |
              e.fromAccountId.equals(accountId) |
              e.toAccountId.equals(accountId))
          ..orderBy([(e) => OrderingTerm.desc(e.eventDate)])
          ..limit(limit))
        .get();
  }

  /// Get events for a specific loan.
  Future<List<Event>> getEventsByLoan(String loanId) async {
    return (_db.select(_db.events)
          ..where((e) => e.loanId.equals(loanId))
          ..orderBy([(e) => OrderingTerm.desc(e.eventDate)]))
        .get();
  }
}
