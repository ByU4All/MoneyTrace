import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/engine.dart';
import '../data/database.dart';
import '../l10n/strings.dart';
import '../providers/dashboard_provider.dart';
import '../providers/database_provider.dart';
import '../theme/colors.dart';
import '../widgets/amount_display.dart';
import 'friend_history_screen.dart';

final friendsProvider = FutureProvider.autoDispose<List<Friend>>((ref) async {
  return ref.watch(friendDaoProvider).getFriends();
});

final friendBalancesProvider = FutureProvider.autoDispose<Map<String, int>>((ref) async {
  final events = await ref.watch(eventDaoProvider).getEventsAsMaps();
  return computeFriendBalances(events);
});

class FriendsScreen extends ConsumerWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final friendsAsync = ref.watch(friendsProvider);
    final balancesAsync = ref.watch(friendBalancesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.get('friends'))),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddFriendSheet(context, ref),
        child: const Icon(Icons.person_add),
      ),
      body: friendsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (friends) {
          if (friends.isEmpty) {
            return Center(
              child: Text(AppStrings.get('no_friends_yet'),
                  style: const TextStyle(color: AppColors.textMuted)),
            );
          }

          final balances = balancesAsync.valueOrNull ?? {};

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: friends.length,
            itemBuilder: (context, index) {
              final friend = friends[index];
              final balance = balances[friend.id] ?? 0;

              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.surfaceLight,
                    child: Text(
                      friend.name[0].toUpperCase(),
                      style: const TextStyle(color: AppColors.accent),
                    ),
                  ),
                  title: Text(friend.name),
                  subtitle: Text(
                    balance > 0
                        ? AppStrings.format('owes_you', [formatAmount(balance)])
                        : balance < 0
                            ? AppStrings.format('you_owe_amount', [formatAmount(-balance)])
                            : AppStrings.get('settled_up'),
                    style: TextStyle(
                      color: balance > 0
                          ? AppColors.success
                          : balance < 0
                              ? AppColors.danger
                              : AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (balance != 0)
                        AmountDisplay(
                          amount: balance,
                          showSign: true,
                          colorize: true,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      PopupMenuButton<String>(
                        itemBuilder: (ctx) => [
                          PopupMenuItem(
                              value: 'delete',
                              child: Text(AppStrings.get('delete'),
                                  style: const TextStyle(color: AppColors.danger))),
                        ],
                        onSelected: (v) {
                          if (v == 'delete') _confirmDeleteFriend(context, ref, friend);
                        },
                      ),
                    ],
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FriendHistoryScreen(friend: friend),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddFriendSheet(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 16, right: 16, top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(AppStrings.get('add_friend'),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: AppStrings.get('name')),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(labelText: AppStrings.get('phone_optional')),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) return;
                await ref.read(friendDaoProvider).createFriend(
                      name: nameController.text.trim(),
                      phone: phoneController.text.trim().isNotEmpty
                          ? phoneController.text.trim()
                          : null,
                    );
                ref.invalidate(friendsProvider);
                if (context.mounted) Navigator.pop(context);
              },
              child: Text(AppStrings.get('add_friend')),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDeleteFriend(
      BuildContext context, WidgetRef ref, Friend friend) async {
    final eventDao = ref.read(eventDaoProvider);
    final linked = await eventDao.getEventsByFriend(friend.id);
    final friendBalances = computeFriendBalances(
      await eventDao.getEventsAsMaps(),
    );
    final balance = friendBalances[friend.id] ?? 0;

    if (!context.mounted) return;

    if (linked.isEmpty) {
      // No transactions — straight delete confirmation.
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(AppStrings.get('delete_friend_q')),
          content: Text(AppStrings.format('remove_name', [friend.name])),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(AppStrings.get('cancel'))),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
              child: Text(AppStrings.get('delete')),
            ),
          ],
        ),
      );
      if (confirm == true) {
        await ref.read(friendDaoProvider).deleteFriend(friend.id);
        ref.invalidate(friendsProvider);
        ref.invalidate(friendBalancesProvider);
        ref.invalidate(dashboardProvider);
      }
      return;
    }

    final choice = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.get('delete_friend_q')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.format('delete_friend_with_count',
                [friend.name, '${linked.length}', formatAmount(balance.abs())])),
            const SizedBox(height: 12),
            Text(AppStrings.get('delete_friend_choose'),
                style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, 'cancel'),
              child: Text(AppStrings.get('cancel'))),
          TextButton(
              onPressed: () => Navigator.pop(ctx, 'unlink'),
              child: Text(AppStrings.get('keep_unlink'))),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, 'delete_all'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: Text(AppStrings.get('delete_with_events')),
          ),
        ],
      ),
    );

    if (choice == null || choice == 'cancel') return;

    if (choice == 'unlink') {
      await eventDao.unlinkFriend(friend.id);
    } else if (choice == 'delete_all') {
      await eventDao.deleteEventsByFriend(friend.id);
    }
    await ref.read(friendDaoProvider).deleteFriend(friend.id);

    ref.invalidate(friendsProvider);
    ref.invalidate(friendBalancesProvider);
    ref.invalidate(dashboardProvider);
  }
}
