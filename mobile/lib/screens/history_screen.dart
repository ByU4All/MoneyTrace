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
  return ref.watch(eventDaoProvider).getEvents();
});

final _historyPhotoIdsProvider = FutureProvider.autoDispose<Set<String>>((ref) async {
  return ref.watch(billPhotoDaoProvider).getEventIdsWithPhotos();
});

enum _DateFilter { all, week, period, custom }

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  bool _moneyOnly = true;
  _DateFilter _dateFilter = _DateFilter.period;
  DateTimeRange? _customRange;
  int _displayCount = 50;
  int _budgetResetDay = 1;
  String _searchQuery = '';

  static const _moneyTypes = {
    'expense', 'income', 'settlement_paid', 'settlement_received',
    'emi_payment', 'credit_card_payment',
  };

  @override
  void initState() {
    super.initState();
    _loadBudgetResetDay();
  }

  Future<void> _loadBudgetResetDay() async {
    final day = await ref.read(settingsDaoProvider).getBudgetResetDay();
    if (mounted) setState(() => _budgetResetDay = day);
  }

  String _dateStr(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  List<Event> _applyDateFilter(List<Event> events) {
    final now = DateTime.now();
    switch (_dateFilter) {
      case _DateFilter.all:
        return events;
      case _DateFilter.week:
        final cutoff = now.subtract(const Duration(days: 7));
        return events.where((e) => e.eventDate.compareTo(_dateStr(cutoff)) >= 0).toList();
      case _DateFilter.period:
        final DateTime periodStart;
        if (now.day >= _budgetResetDay) {
          periodStart = DateTime(now.year, now.month, _budgetResetDay);
        } else {
          final prev = DateTime(now.year, now.month - 1, 1);
          periodStart = DateTime(prev.year, prev.month, _budgetResetDay);
        }
        return events.where((e) => e.eventDate.compareTo(_dateStr(periodStart)) >= 0).toList();
      case _DateFilter.custom:
        if (_customRange == null) return events;
        final s = _customRange!.start;
        final e = _customRange!.end;
        return events
            .where((ev) =>
                ev.eventDate.compareTo(_dateStr(s)) >= 0 &&
                ev.eventDate.compareTo(_dateStr(e)) <= 0)
            .toList();
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
        _displayCount = 50;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(historyProvider);
    final photoIds = ref.watch(_historyPhotoIdsProvider).valueOrNull ?? {};

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get('history')),
        actions: [
          FilterChip(
            label: Text(_moneyOnly ? AppStrings.get('money_only') : AppStrings.get('all_activity')),
            selected: _moneyOnly,
            onSelected: (v) => setState(() {
              _moneyOnly = v;
              _displayCount = 50;
            }),
            selectedColor: AppColors.accent.withAlpha(50),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchBar(),
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
                if (_searchQuery.isNotEmpty) {
                  final q = _searchQuery.toLowerCase();
                  filtered = filtered.where((e) =>
                    (e.description?.toLowerCase().contains(q) ?? false) ||
                    (e.category?.toLowerCase().contains(q) ?? false)
                  ).toList();
                }

                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      AppStrings.get('no_transactions_yet'),
                      style: const TextStyle(color: AppColors.textMuted),
                    ),
                  );
                }

                final visible = filtered.take(_displayCount).toList();
                final hasMore = _displayCount < filtered.length;
                final remaining = filtered.length - _displayCount;

                final grouped = <String, List<Event>>{};
                for (final event in visible) {
                  grouped.putIfAbsent(event.eventDate, () => []).add(event);
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: grouped.length + (hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == grouped.length) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: OutlinedButton(
                            onPressed: () => setState(() => _displayCount += 50),
                            child: Text(
                              'Load more (${remaining > 50 ? 50 : remaining} of $remaining remaining)',
                            ),
                          ),
                        ),
                      );
                    }

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
                                    if (event.billPhotoPath != null || photoIds.contains(event.id))
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
                                onTap: () => _showDetailSheet(context, ref, event, photoIds),
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

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search transactions…',
          hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
          prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textMuted),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () => setState(() {
                    _searchQuery = '';
                    _displayCount = 50;
                  }),
                )
              : null,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        onChanged: (v) => setState(() {
          _searchQuery = v;
          _displayCount = 50;
        }),
      ),
    );
  }

  void _showDetailSheet(BuildContext context, WidgetRef ref, Event event, Set<String> photoIds) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetCtx) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 32, height: 3,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                AppIcons.eventIcon(event.type, radius: 18),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.description ?? AppStrings.eventTypeName(event.type),
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        event.category ?? AppStrings.eventTypeName(event.type),
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                AmountDisplay(
                  amount: signedAmount(event.amount, event.type),
                  showSign: true,
                  color: colorForEventType(event.type),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(color: AppColors.surfaceLight),
            _detailRow('Date', event.eventDate),
            if (_recordedTime(event.createdAt) case final t?)
              _detailRow('Time', t),
            if (event.billPhotoPath != null || photoIds.contains(event.id))
              FutureBuilder<List<BillPhoto>>(
                future: ref.read(billPhotoDaoProvider).getPhotosForEvent(event.id),
                builder: (context, snapshot) {
                  final dbPhotos = snapshot.data ?? [];
                  // Deduplicate: the v4 migration copies bill_photo_path into
                  // bill_photos but leaves the legacy column set — use a Set to
                  // avoid rendering the same file twice.
                  final seen = <String>{};
                  final allPaths = [
                    if (event.billPhotoPath != null) event.billPhotoPath!,
                    ...dbPhotos.map((p) => p.filePath),
                  ].where(seen.add).toList();
                  if (allPaths.isEmpty) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Receipt', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                        const SizedBox(height: 6),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: allPaths.map((path) {
                              final file = File(path);
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: file.existsSync()
                                      ? Image.file(file, width: 80, height: 80, fit: BoxFit.cover)
                                      : Container(
                                          width: 80, height: 80,
                                          color: AppColors.surfaceLight,
                                          child: const Icon(Icons.broken_image_outlined, color: AppColors.textMuted),
                                        ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Edit'),
                    onPressed: () async {
                      Navigator.pop(sheetCtx);
                      final edited = await showEditEventSheet(context, ref, event);
                      if (edited == true && mounted) {
                        ref.invalidate(historyProvider);
                        ref.invalidate(dashboardProvider);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.delete_outline, size: 16),
                    label: const Text('Delete'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      side: const BorderSide(color: AppColors.danger),
                    ),
                    onPressed: () {
                      Navigator.pop(sheetCtx);
                      _confirmDelete(context, ref, event);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      children: [
        SizedBox(
          width: 56,
          child: Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
        ),
        Text(value, style: const TextStyle(fontSize: 13)),
      ],
    ),
  );

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
          _dateChip('Budget Period', _DateFilter.period),
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
      onSelected: (_) => setState(() {
        _dateFilter = filter;
        _displayCount = 50;
      }),
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

    // 1. Reverse account balance impact
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

    // 2. Delete auto-created split receivables
    if (event.type == 'expense') {
      final splits = await eventDao.findSplitReceivables(event.eventDate, event.description);
      for (final split in splits) {
        await eventDao.deleteEvent(split.id);
      }
    }

    // 3. Delete bill photos (multi-photo table + legacy column)
    final paths = await ref.read(billPhotoDaoProvider).deletePhotosForEvent(event.id);
    for (final path in paths) {
      final f = File(path);
      if (await f.exists()) await f.delete();
    }
    if (event.billPhotoPath != null) {
      final f = File(event.billPhotoPath!);
      if (await f.exists()) await f.delete();
    }

    // 4. Delete the event
    await eventDao.deleteEvent(event.id);

    if (mounted) {
      ref.invalidate(historyProvider);
      ref.invalidate(dashboardProvider);
      ref.invalidate(accountsProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${event.description ?? 'Transaction'} deleted'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
