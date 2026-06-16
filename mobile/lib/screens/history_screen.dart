import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../l10n/strings.dart';
import '../providers/dashboard_provider.dart';
import '../providers/database_provider.dart';
import '../theme/colors.dart';
import '../widgets/amount_display.dart' show AmountDisplay, formatAmount, colorForEventType, signedAmount;
import '../widgets/app_icons.dart';
import 'accounts_screen.dart' show accountsProvider;
import 'edit_event_screen.dart';

final historyProvider = FutureProvider.autoDispose<List<Event>>((ref) async {
  return ref.watch(eventDaoProvider).getEvents(limit: 200);
});

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  bool _moneyOnly = true;

  static const _moneyTypes = {
    'expense', 'income', 'settlement_paid', 'settlement_received',
    'emi_payment', 'credit_card_payment',
  };

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(historyProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get('history')),
        actions: [
          FilterChip(
            label: Text(_moneyOnly ? AppStrings.get('money_only') : AppStrings.get('all_activity')),
            selected: _moneyOnly,
            onSelected: (v) => setState(() => _moneyOnly = v),
            selectedColor: AppColors.accent.withAlpha(50),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: historyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (events) {
          final filtered = _moneyOnly
              ? events.where((e) => _moneyTypes.contains(e.type)).toList()
              : events;

          if (filtered.isEmpty) {
            return Center(
              child: Text(AppStrings.get('no_transactions_yet'), style: const TextStyle(color: AppColors.textMuted)),
            );
          }

          // Group by date
          final grouped = <String, List<Event>>{};
          for (final event in filtered) {
            grouped.putIfAbsent(event.eventDate, () => []).add(event);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: grouped.length,
            itemBuilder: (context, index) {
              final dateKey = grouped.keys.elementAt(index);
              final dayEvents = grouped[dateKey]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      dateKey,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  ...dayEvents.map((event) => Card(
                    child: ListTile(
                      leading: AppIcons.eventIcon(event.type, radius: 16),
                      title: Text(
                        event.description ?? AppStrings.eventTypeName(event.type),
                        style: const TextStyle(fontSize: 14),
                      ),
                      subtitle: Text(
                        event.category ?? AppStrings.eventTypeName(event.type),
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                      ),
                      trailing: AmountDisplay(
                        amount: signedAmount(event.amount, event.type),
                        showSign: true,
                        color: colorForEventType(event.type),
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      onTap: () async {
                        final edited = await showEditEventSheet(context, ref, event);
                        if (edited == true) {
                          ref.invalidate(historyProvider);
                          ref.invalidate(dashboardProvider);
                        }
                      },
                      onLongPress: () => _confirmDelete(context, ref, event),
                    ),
                  )),
                ],
              );
            },
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Event event) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.get('delete_transaction_q')),
        content: Text(AppStrings.format('delete_transaction_msg', [event.description ?? AppStrings.eventTypeName(event.type), formatAmount(event.amount)])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(AppStrings.get('cancel'))),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: Text(AppStrings.get('delete')),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(eventDaoProvider).deleteEvent(event.id);
      ref.invalidate(historyProvider);
      ref.invalidate(dashboardProvider);
      ref.invalidate(accountsProvider);
    }
  }
}
