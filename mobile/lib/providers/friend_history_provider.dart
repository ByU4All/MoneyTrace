import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import 'database_provider.dart';

/// All events linked to a friend (primary friend_id OR multi-tag join table),
/// ordered most-recent first.
final friendHistoryProvider = FutureProvider.autoDispose
    .family<List<Event>, String>((ref, friendId) async {
  final eventDao = ref.watch(eventDaoProvider);
  return eventDao.getEventsByFriend(friendId);
});
