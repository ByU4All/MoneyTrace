import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/engine.dart';
import '../data/database.dart';
import '../l10n/strings.dart';
import '../providers/database_provider.dart';
import '../providers/friend_history_provider.dart';
import '../theme/colors.dart';
import '../widgets/amount_display.dart' show AmountDisplay, colorForEventType, signedAmount;
import '../widgets/app_icons.dart';

/// Per-friend transaction history. Shows all events linked to the friend (via
/// the legacy primary friend_id or the multi-tag join table) with a running
/// balance computed from settlement-impacting events only.
class FriendHistoryScreen extends ConsumerWidget {
  final Friend friend;
  const FriendHistoryScreen({super.key, required this.friend});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(friendHistoryProvider(friend.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.format('friend_history', [friend.name])),
      ),
      body: eventsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (events) {
          if (events.isEmpty) {
            return Center(
              child: Text(AppStrings.get('no_history_with_friend'),
                  style: const TextStyle(color: AppColors.textMuted)),
            );
          }

          // Compute the live net balance from all events and display in the header.
          final allEventsFuture = ref.watch(eventDaoProvider).getEventsAsMaps();
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(friendHistoryProvider(friend.id)),
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: allEventsFuture,
              builder: (context, snapshot) {
                final balances =
                    snapshot.hasData ? computeFriendBalances(snapshot.data!) : <String, int>{};
                final balance = balances[friend.id] ?? 0;
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Card(
                      color: AppColors.surfaceLight.withValues(alpha: 0.3),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text(friend.name,
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text(
                              balance > 0
                                  ? AppStrings.get('owes_you_label')
                                  : balance < 0
                                      ? AppStrings.get('you_owe_label')
                                      : AppStrings.get('settled_up'),
                              style:
                                  const TextStyle(color: AppColors.textMuted, fontSize: 12),
                            ),
                            AmountDisplay(
                              amount: balance.abs(),
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: balance > 0
                                    ? AppColors.success
                                    : balance < 0
                                        ? AppColors.danger
                                        : AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...events.map((e) => _eventTile(e)),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _eventTile(Event e) {
    return Card(
      child: ListTile(
        leading: AppIcons.eventIcon(e.type),
        title: Text(
          e.description ?? AppStrings.eventTypeName(e.type),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${AppStrings.eventTypeName(e.type)} • ${e.eventDate}',
          style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
        ),
        trailing: AmountDisplay(
          amount: signedAmount(e.amount, e.type),
          showSign: true,
          color: colorForEventType(e.type),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
