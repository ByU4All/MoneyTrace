import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/engine.dart' show balanceImpact;
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

enum _DateFilter { all, week, month, custom }

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  bool _moneyOnly = true;
  _DateFilter _dateFilter = _DateFilter.month;
  DateTimeRange? _customRange;

  static const _moneyTypes = {
    'expense', 'income', 'settlement_paid', 'settlement_received',
    'emi_payment', 'credit_card_payment',
  };

  List<Event> _applyDateFilter(List<Event> events) {
    final now = DateTime.now();
    switch (_dateFilter) {
      case _DateFilter.all:
        return events;
      case _DateFilter.week:
        final cutoff = now.subtract(const Duration(days: 7));
        final cutoffStr = '${cutoff.year}-${cutoff.month.toString().padLeft(2, '0')}-${cutoff.day.toString().padLeft(2, '0')}';
        return events.where((e) => e.eventDate.compareTo(cutoffStr) >= 0).toList();
      case _DateFilter.month:
        final monthStr = '${now.year}-${now.month.toString().padLeft(2, '0')}';
        return events.where((e) => e.eventDate.startsWith(monthStr)).toList();
      case _DateFilter.custom:
        if (_customRange == null) return events;
        final s = _customRange!.start;
        final e = _customRange!.end;
        final startStr = '${s.year}-${s.month.toString().padLeft(2, '0')}-${s.day.toString().padLeft(2, '0')}';
        final endStr = '${e.year}-${e.month.toString().padLeft(2, '0')}-${e.day.toString().padLeft(2, '0')}';
        return events.where((ev) => ev.eventDate.compareTo(startStr) >= 0 && ev.eventDate.compareTo(endStr) <= 0).toList();
    }
  }

  Future<void> _pickCustomRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _customRange ??
          DateTimeRange(
            start: DateTime.now().subtract(const Duration(days: 30)),
            end: DateTime.now(),
          ),
    );
    if (range != null) {
      setState(() {
        _customRange = range;
        _dateFilter = _DateFilter.custom;
      });
    }
  }

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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDateFilterRow(),
          Expanded(
            child: historyAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
              data: (events) {
                var filtered = _applyDateFilter(events);
                if (_moneyOnly) {
                  filtered = filtered.where((e) => _moneyTypes.contains(e.type)).toList();
                }

                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      AppStrings.get('no_transactions_yet'),
                      style: const TextStyle(color: AppColors.textMuted),
                    ),
                  );
                }

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
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      event.category ?? AppStrings.eventTypeName(event.type),
                                      style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                                    ),
                                    if (_recordedTime(event.createdAt) case final t?)
                                      Text(
                                        t,
                                        style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
                                      ),
                                    if (event.billPhotoPath != null)
                                      const Row(children: [
                                        Icon(Icons.receipt_long, size: 10, color: AppColors.textMuted),
                                        SizedBox(width: 2),
                                        Text('receipt', style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
                                      ]),
                                  ],
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
          ),
        ],
      ),
    );
  }

  String? _recordedTime(String createdAt) {
    if (!createdAt.contains('T')) return null;
    final dt = DateTime.tryParse(createdAt);
    if (dt == null) return null;
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildDateFilterRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _dateChip('All', _DateFilter.all),
          const SizedBox(width: 8),
          _dateChip('This Week', _DateFilter.week),
          const SizedBox(width: 8),
          _dateChip('This Month', _DateFilter.month),
          const SizedBox(width: 8),
          FilterChip(
            label: Text(
              _dateFilter == _DateFilter.custom && _customRange != null
                  ? '${_customRange!.start.day}/${_customRange!.start.month} – ${_customRange!.end.day}/${_customRange!.end.month}'
                  : 'Custom',
            ),
            selected: _dateFilter == _DateFilter.custom,
            onSelected: (_) => _pickCustomRange(),
            selectedColor: AppColors.accent.withAlpha(50),
          ),
        ],
      ),
    );
  }

  Widget _dateChip(String label, _DateFilter filter) {
    return FilterChip(
      label: Text(label),
      selected: _dateFilter == filter,
      onSelected: (_) => setState(() => _dateFilter = filter),
      selectedColor: AppColors.accent.withAlpha(50),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Event event) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.get('delete_transaction_q')),
        content: Text(AppStrings.format('delete_transaction_msg', [
          event.description ?? AppStrings.eventTypeName(event.type),
          formatAmount(event.amount),
        ])),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppStrings.get('cancel')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: Text(AppStrings.get('delete')),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    final eventDao = ref.read(eventDaoProvider);
    final accountDao = ref.read(accountDaoProvider);

    // 1. Reverse account balance impact of the deleted event
    if (event.type == 'transfer') {
      if (event.fromAccountId != null) {
        await accountDao.updateBalance(event.fromAccountId!, event.amount);
      }
      if (event.toAccountId != null) {
        await accountDao.updateBalance(event.toAccountId!, -event.amount);
      }
    } else if (event.accountId != null) {
      final impact = balanceImpact(event.type, event.amount);
      if (impact != 0) {
        await accountDao.updateBalance(event.accountId!, -impact);
      }
    }

    // 2. If this is a split expense, delete the auto-created RECEIVABLE events
    if (event.type == 'expense') {
      final splits = await eventDao.findSplitReceivables(
          event.eventDate, event.description);
      for (final split in splits) {
        await eventDao.deleteEvent(split.id);
      }
    }

    // 3. Delete bill photo file if attached
    if (event.billPhotoPath != null) {
      final f = File(event.billPhotoPath!);
      if (await f.exists()) await f.delete();
    }

    // 4. Delete the event itself
    await eventDao.deleteEvent(event.id);

    if (mounted) {
      ref.invalidate(historyProvider);
      ref.invalidate(dashboardProvider);
      ref.invalidate(accountsProvider);
    }
  }
}
