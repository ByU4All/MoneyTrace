import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/engine.dart';
import '../data/database.dart';
import '../providers/database_provider.dart';
import '../theme/colors.dart';
import '../widgets/amount_display.dart';

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
      appBar: AppBar(title: const Text('Friends')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddFriendSheet(context, ref),
        child: const Icon(Icons.person_add),
      ),
      body: friendsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (friends) {
          if (friends.isEmpty) {
            return const Center(
              child: Text('No friends added yet', style: TextStyle(color: AppColors.textMuted)),
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
                        ? 'Owes you ${formatAmount(balance)}'
                        : balance < 0
                            ? 'You owe ${formatAmount(-balance)}'
                            : 'Settled up',
                    style: TextStyle(
                      color: balance > 0
                          ? AppColors.success
                          : balance < 0
                              ? AppColors.danger
                              : AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                  trailing: balance != 0
                      ? AmountDisplay(
                          amount: balance,
                          showSign: true,
                          colorize: true,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        )
                      : null,
                  onTap: () => _showFriendDetail(context, ref, friend, balance),
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
            const Text('Add Friend', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Phone (optional)'),
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
              child: const Text('Add Friend'),
            ),
          ],
        ),
      ),
    );
  }

  void _showFriendDetail(BuildContext context, WidgetRef ref, Friend friend, int balance) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: AppColors.surfaceLight,
              child: Text(friend.name[0].toUpperCase(),
                  style: const TextStyle(fontSize: 24, color: AppColors.accent)),
            ),
            const SizedBox(height: 8),
            Text(friend.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            if (friend.phone != null) Text(friend.phone!, style: const TextStyle(color: AppColors.textMuted)),
            const SizedBox(height: 16),
            Text(
              balance > 0
                  ? 'Owes you'
                  : balance < 0
                      ? 'You owe'
                      : 'Settled up',
              style: const TextStyle(color: AppColors.textMuted),
            ),
            AmountDisplay(
              amount: balance.abs(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: balance > 0 ? AppColors.success : balance < 0 ? AppColors.danger : AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Delete Friend?'),
                    content: Text('Remove "${friend.name}"?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await ref.read(friendDaoProvider).deleteFriend(friend.id);
                  ref.invalidate(friendsProvider);
                  ref.invalidate(friendBalancesProvider);
                  if (context.mounted) Navigator.pop(context);
                }
              },
              icon: const Icon(Icons.delete, color: AppColors.danger),
              label: const Text('Delete', style: TextStyle(color: AppColors.danger)),
            ),
          ],
        ),
      ),
    );
  }
}
