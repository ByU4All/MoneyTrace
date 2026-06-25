import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/budget.dart';
import '../data/database.dart';
import '../l10n/strings.dart';
import '../providers/dashboard_provider.dart';
import '../providers/database_provider.dart';
import '../theme/colors.dart';
import '../widgets/amount_display.dart';
import '../widgets/app_icons.dart';
import '../widgets/empty_picker_row.dart';
import '../widgets/modal_sheet.dart' show showConfirmDialog;

final recurringProvider = FutureProvider.autoDispose<List<RecurringTransaction>>((ref) async {
  return ref.watch(recurringDaoProvider).getRecurring();
});

final pendingProvider = FutureProvider.autoDispose<List<PendingTransaction>>((ref) async {
  return ref.watch(recurringDaoProvider).getPendingTransactions();
});

/// Bundle of recurring buckets for display: due-now, paid, and future.
class _RecurringBuckets {
  final List<RecurringTransaction> dueThisMonth;
  final List<RecurringTransaction> paidThisMonth;
  final List<RecurringTransaction> upcoming;

  _RecurringBuckets({
    required this.dueThisMonth,
    required this.paidThisMonth,
    required this.upcoming,
  });
}

final recurringBucketsProvider =
    FutureProvider.autoDispose<_RecurringBuckets>((ref) async {
  final recurring = await ref.watch(recurringProvider.future);
  final eventDao = ref.watch(eventDaoProvider);
  final settingsDao = ref.watch(settingsDaoProvider);

  final now = DateTime.now();
  final resetDay = await settingsDao.getBudgetResetDay();
  final (year, month) = getBudgetPeriod(now, resetDay);
  final periodStart = DateTime(year, month, resetDay);
  final periodEnd = DateTime(year, month + 1, resetDay)
      .subtract(const Duration(days: 1));

  final events = await eventDao.getEventsAsMaps(month: month, year: year);

  final dueThisMonth = <RecurringTransaction>[];
  final paidThisMonth = <RecurringTransaction>[];
  final upcoming = <RecurringTransaction>[];

  for (final rec in recurring) {
    final hasEvent = events.any((e) => e['recurring_id'] == rec.id);
    if (hasEvent) {
      paidThisMonth.add(rec);
      continue;
    }

    final nextDue = rec.nextDueDate != null
        ? DateTime.tryParse(rec.nextDueDate!)
        : null;

    bool relevant;
    if (rec.frequency == 'monthly' ||
        rec.frequency == 'daily' ||
        rec.frequency == 'weekly') {
      relevant = true;
    } else {
      relevant = nextDue != null &&
          !nextDue.isBefore(periodStart) &&
          !nextDue.isAfter(periodEnd);
    }

    if (relevant) {
      dueThisMonth.add(rec);
    } else {
      upcoming.add(rec);
    }
  }

  return _RecurringBuckets(
    dueThisMonth: dueThisMonth,
    paidThisMonth: paidThisMonth,
    upcoming: upcoming,
  );
});

class RecurringScreen extends ConsumerWidget {
  const RecurringScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bucketsAsync = ref.watch(recurringBucketsProvider);
    final pendingAsync = ref.watch(pendingProvider);

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.get('recurring'))),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddRecurringSheet(context, ref),
        tooltip: AppStrings.get('add_recurring'),
        child: const Icon(Icons.add),
      ),
      body: bucketsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (buckets) {
          final pending = pendingAsync.valueOrNull ?? [];

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(recurringBucketsProvider);
              ref.invalidate(pendingProvider);
              ref.invalidate(recurringProvider);
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (pending.isNotEmpty) ...[
                  Text(AppStrings.get('pending_verification'),
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  ...pending.map((p) => Card(
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: AppColors.warning,
                            child: Icon(Icons.pending_actions, color: Colors.black),
                          ),
                          title: Text('Due: ${p.dueDate}'),
                          subtitle: Text(formatAmount(p.amount)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.check, color: AppColors.success),
                                onPressed: () async {
                                  await ref
                                      .read(recurringDaoProvider)
                                      .updatePendingStatus(p.id, 'confirmed');
                                  ref.invalidate(pendingProvider);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.skip_next, color: AppColors.textMuted),
                                onPressed: () async {
                                  await ref
                                      .read(recurringDaoProvider)
                                      .updatePendingStatus(p.id, 'skipped');
                                  ref.invalidate(pendingProvider);
                                },
                              ),
                            ],
                          ),
                        ),
                      )),
                  const SizedBox(height: 16),
                ],

                if (buckets.dueThisMonth.isEmpty &&
                    (buckets.paidThisMonth.isNotEmpty || buckets.upcoming.isNotEmpty))
                  Card(
                    color: AppColors.success.withValues(alpha: 0.15),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: AppColors.success),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              AppStrings.get('all_done_this_month'),
                              style: const TextStyle(
                                  color: AppColors.success, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                if (buckets.dueThisMonth.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(AppStrings.get('due_this_month'),
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  ...buckets.dueThisMonth
                      .map((item) => _recurringTile(context, ref, item, _RecurringStatus.due)),
                ],

                if (buckets.paidThisMonth.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(AppStrings.get('paid_this_month'),
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  ...buckets.paidThisMonth
                      .map((item) => _recurringTile(context, ref, item, _RecurringStatus.paid)),
                ],

                if (buckets.upcoming.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(AppStrings.get('upcoming'),
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  ...buckets.upcoming
                      .map((item) => _recurringTile(context, ref, item, _RecurringStatus.upcoming)),
                ],

                if (buckets.dueThisMonth.isEmpty &&
                    buckets.paidThisMonth.isEmpty &&
                    buckets.upcoming.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Text(AppStrings.get('no_recurring_transactions'),
                            style: const TextStyle(color: AppColors.textMuted)),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _recurringTile(
      BuildContext context, WidgetRef ref, RecurringTransaction item, _RecurringStatus status) {
    final dim = status == _RecurringStatus.upcoming;
    final paid = status == _RecurringStatus.paid;

    return Opacity(
      opacity: dim ? 0.55 : 1.0,
      child: Card(
        child: ListTile(
          leading: paid
              ? const CircleAvatar(
                  backgroundColor: AppColors.success,
                  child: Icon(Icons.check, color: Colors.black, size: 18),
                )
              : AppIcons.eventIcon(item.type),
          title: Text(
            item.name,
            style: paid
                ? const TextStyle(decoration: TextDecoration.lineThrough)
                : null,
          ),
          subtitle: Text(
            '${formatAmount(item.amount)} • ${item.frequency}'
            '${item.nextDueDate != null ? ' • Next: ${item.nextDueDate}' : ''}'
            '${item.isAutopay == 1 ? ' • Auto-pay' : ''}',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
          trailing: PopupMenuButton(
                  itemBuilder: (ctx) => [
                    PopupMenuItem(value: 'edit', child: Text(AppStrings.get('edit'))),
                    PopupMenuItem(
                        value: 'delete',
                        child: Text(AppStrings.get('delete'),
                            style: const TextStyle(color: AppColors.danger))),
                  ],
                  onSelected: (value) async {
                    if (value == 'edit') {
                      _showEditRecurringSheet(context, ref, item);
                    } else if (value == 'delete') {
                      final confirmed = await showConfirmDialog(
                        context: context,
                        title: 'Delete recurring?',
                        message: '"${item.name}" will be permanently deleted.',
                        confirmText: 'Delete',
                        isDangerous: true,
                      );
                      if (!confirmed) return;
                      await ref.read(recurringDaoProvider).deleteRecurring(item.id);
                      ref.invalidate(recurringProvider);
                      ref.invalidate(recurringBucketsProvider);
                      ref.invalidate(dashboardProvider);
                    }
                  },
                ),
        ),
      ),
    );
  }

  void _showAddRecurringSheet(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final dayCtrl = TextEditingController(text: '1');
    String selectedType = 'expense';
    String selectedFrequency = 'monthly';
    String? selectedCategory;
    String? selectedAccountId;
    bool isAutopay = false;

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
        child: StatefulBuilder(
          builder: (context, setState) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(AppStrings.get('add_recurring_transaction'),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(labelText: AppStrings.get('name')),
                    autofocus: true),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedType,
                        decoration: InputDecoration(labelText: AppStrings.get('type')),
                        items: [
                          DropdownMenuItem(
                              value: 'expense', child: Text(AppStrings.get('tab_expense'))),
                          DropdownMenuItem(
                              value: 'emi_payment', child: Text(AppStrings.get('emi'))),
                          DropdownMenuItem(
                              value: 'income', child: Text(AppStrings.get('tab_income'))),
                        ],
                        onChanged: (v) => setState(() {
                          selectedType = v!;
                          if (v != 'expense') selectedCategory = null;
                        }),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedFrequency,
                        decoration: InputDecoration(labelText: AppStrings.get('frequency')),
                        items: [
                          DropdownMenuItem(
                              value: 'daily',
                              child: Text(AppStrings.frequencyName('daily'))),
                          DropdownMenuItem(
                              value: 'weekly',
                              child: Text(AppStrings.frequencyName('weekly'))),
                          DropdownMenuItem(
                              value: 'monthly',
                              child: Text(AppStrings.frequencyName('monthly'))),
                          DropdownMenuItem(
                              value: 'bimonthly',
                              child: Text(AppStrings.frequencyName('bimonthly'))),
                          DropdownMenuItem(
                              value: 'quarterly',
                              child: Text(AppStrings.frequencyName('quarterly'))),
                          DropdownMenuItem(
                              value: 'half_yearly',
                              child: Text(AppStrings.frequencyName('half_yearly'))),
                          DropdownMenuItem(
                              value: 'yearly',
                              child: Text(AppStrings.frequencyName('yearly'))),
                        ],
                        onChanged: (v) => setState(() => selectedFrequency = v!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                        child: TextField(
                            controller: amountCtrl,
                            decoration:
                                InputDecoration(labelText: AppStrings.get('amount')),
                            keyboardType: TextInputType.number)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: TextField(
                            controller: dayCtrl,
                            decoration:
                                InputDecoration(labelText: AppStrings.get('day_of_month')),
                            keyboardType: TextInputType.number)),
                  ],
                ),
                if (selectedType == 'expense') ...[
                  const SizedBox(height: 12),
                  FutureBuilder(
                    future: ref
                        .read(databaseProvider)
                        .select(ref.read(databaseProvider).categories)
                        .get(),
                    builder: (context, snapshot) {
                      final categories = snapshot.data ?? [];
                      if (categories.isEmpty) {
                        return const EmptyPickerRow(
                          icon: Icons.category_outlined,
                          label: 'No categories yet',
                          dialogTitle: 'No categories yet',
                          dialogMessage:
                              'You need at least one category to assign to this recurring expense.\n\n'
                              'Go to: More → Settings → Categories\n\n'
                              'Default categories are added automatically on a fresh install.',
                        );
                      }
                      return DropdownButtonFormField<String>(
                        value: selectedCategory,
                        decoration: InputDecoration(labelText: AppStrings.get('category')),
                        items: categories
                            .map((c) =>
                                DropdownMenuItem(value: c.name, child: Text(c.name)))
                            .toList(),
                        onChanged: (v) => setState(() => selectedCategory = v),
                      );
                    },
                  ),
                ],
                const SizedBox(height: 12),
                FutureBuilder(
                  future: ref.read(accountDaoProvider).getAccounts(),
                  builder: (context, snapshot) {
                    final accounts = snapshot.data ?? [];
                    if (accounts.isEmpty) {
                      return const EmptyPickerRow(
                        icon: Icons.account_balance_outlined,
                        label: 'No accounts yet',
                        dialogTitle: 'No accounts yet',
                        dialogMessage:
                            'You need at least one account to link autopay to.\n\n'
                            'Go to the Accounts tab (🏦) and tap + to add one.\n\n'
                            'A Cash account is created automatically on a fresh install.',
                      );
                    }
                    return DropdownButtonFormField<String>(
                      value: selectedAccountId,
                      decoration:
                          InputDecoration(labelText: AppStrings.get('account_optional')),
                      items: [
                        DropdownMenuItem(
                            value: null, child: Text(AppStrings.get('no_account'))),
                        ...accounts.map(
                            (a) => DropdownMenuItem(value: a.id, child: Text(a.name))),
                      ],
                      onChanged: (v) => setState(() => selectedAccountId = v),
                    );
                  },
                ),
                SwitchListTile(
                  title: Text(AppStrings.get('autopay')),
                  subtitle: Text(AppStrings.get('autopay_subtitle')),
                  value: isAutopay,
                  onChanged: (v) => setState(() => isAutopay = v),
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    final name = nameCtrl.text.trim();
                    final amount = double.tryParse(amountCtrl.text);
                    if (name.isEmpty || amount == null) return;

                    final now = DateTime.now();
                    final startDate =
                        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
                    final day = int.tryParse(dayCtrl.text) ?? 1;

                    String nextDueDate;
                    if (selectedFrequency == 'daily') {
                      final tomorrow = now.add(const Duration(days: 1));
                      nextDueDate =
                          '${tomorrow.year}-${tomorrow.month.toString().padLeft(2, '0')}-${tomorrow.day.toString().padLeft(2, '0')}';
                    } else if (selectedFrequency == 'weekly') {
                      final nextWeek = now.add(const Duration(days: 7));
                      nextDueDate =
                          '${nextWeek.year}-${nextWeek.month.toString().padLeft(2, '0')}-${nextWeek.day.toString().padLeft(2, '0')}';
                    } else if (selectedFrequency == 'yearly') {
                      final nextYear =
                          DateTime(now.year + 1, now.month, day.clamp(1, 28));
                      nextDueDate =
                          '${nextYear.year}-${nextYear.month.toString().padLeft(2, '0')}-${nextYear.day.toString().padLeft(2, '0')}';
                    } else {
                      final monthInterval = switch (selectedFrequency) {
                        'bimonthly' => 2,
                        'quarterly' => 3,
                        'half_yearly' => 6,
                        _ => 1,
                      };
                      final dueThisMonth =
                          DateTime(now.year, now.month, day.clamp(1, 28));
                      final due = dueThisMonth.isAfter(now)
                          ? dueThisMonth
                          : DateTime(
                              now.year, now.month + monthInterval, day.clamp(1, 28));
                      nextDueDate =
                          '${due.year}-${due.month.toString().padLeft(2, '0')}-${due.day.toString().padLeft(2, '0')}';
                    }

                    await ref.read(recurringDaoProvider).createRecurring(
                          name: name,
                          type: selectedType,
                          amount: (amount * 100).round(),
                          category: selectedCategory,
                          accountId: selectedAccountId,
                          frequency: selectedFrequency,
                          dayOfMonth: day,
                          startDate: startDate,
                          isAutopay: isAutopay,
                          nextDueDate: nextDueDate,
                        );
                    ref.invalidate(recurringProvider);
                    ref.invalidate(recurringBucketsProvider);
                    ref.invalidate(dashboardProvider);
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: Text(AppStrings.get('add')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditRecurringSheet(BuildContext context, WidgetRef ref, RecurringTransaction item) {
    final nameCtrl = TextEditingController(text: item.name);
    final amountCtrl = TextEditingController(text: (item.amount / 100).toString());
    final dayCtrl = TextEditingController(text: (item.dayOfMonth ?? 1).toString());
    String? selectedCategory = item.category;
    String? selectedAccountId = item.accountId;
    bool isAutopay = item.isAutopay == 1;

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
        child: StatefulBuilder(
          builder: (context, setState) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(AppStrings.get('edit_recurring_transaction'),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(labelText: AppStrings.get('name'))),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                        child: TextField(
                            controller: amountCtrl,
                            decoration:
                                InputDecoration(labelText: AppStrings.get('amount')),
                            keyboardType: TextInputType.number)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: TextField(
                            controller: dayCtrl,
                            decoration:
                                InputDecoration(labelText: AppStrings.get('day_of_month')),
                            keyboardType: TextInputType.number)),
                  ],
                ),
                if (item.type == 'expense') ...[
                  const SizedBox(height: 12),
                  FutureBuilder(
                    future: ref
                        .read(databaseProvider)
                        .select(ref.read(databaseProvider).categories)
                        .get(),
                    builder: (context, snapshot) {
                      final categories = snapshot.data ?? [];
                      if (categories.isEmpty) {
                        return const EmptyPickerRow(
                          icon: Icons.category_outlined,
                          label: 'No categories yet',
                          dialogTitle: 'No categories yet',
                          dialogMessage:
                              'You need at least one category to assign to this recurring expense.\n\n'
                              'Go to: More → Settings → Categories\n\n'
                              'Default categories are added automatically on a fresh install.',
                        );
                      }
                      return DropdownButtonFormField<String>(
                        value: selectedCategory,
                        decoration: InputDecoration(labelText: AppStrings.get('category')),
                        items: [
                          DropdownMenuItem(
                              value: null, child: Text(AppStrings.get('none'))),
                          ...categories.map(
                              (c) => DropdownMenuItem(value: c.name, child: Text(c.name))),
                        ],
                        onChanged: (v) => setState(() => selectedCategory = v),
                      );
                    },
                  ),
                ],
                const SizedBox(height: 12),
                FutureBuilder(
                  future: ref.read(accountDaoProvider).getAccounts(),
                  builder: (context, snapshot) {
                    final accounts = snapshot.data ?? [];
                    if (accounts.isEmpty) {
                      return const EmptyPickerRow(
                        icon: Icons.account_balance_outlined,
                        label: 'No accounts yet',
                        dialogTitle: 'No accounts yet',
                        dialogMessage:
                            'You need at least one account to link autopay to.\n\n'
                            'Go to the Accounts tab (🏦) and tap + to add one.\n\n'
                            'A Cash account is created automatically on a fresh install.',
                      );
                    }
                    return DropdownButtonFormField<String>(
                      value: selectedAccountId,
                      decoration:
                          InputDecoration(labelText: AppStrings.get('account_optional')),
                      items: [
                        DropdownMenuItem(
                            value: null, child: Text(AppStrings.get('no_account'))),
                        ...accounts.map(
                            (a) => DropdownMenuItem(value: a.id, child: Text(a.name))),
                      ],
                      onChanged: (v) => setState(() => selectedAccountId = v),
                    );
                  },
                ),
                SwitchListTile(
                  title: Text(AppStrings.get('autopay')),
                  subtitle: Text(AppStrings.get('autopay_subtitle')),
                  value: isAutopay,
                  onChanged: (v) => setState(() => isAutopay = v),
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    final name = nameCtrl.text.trim();
                    final amount = double.tryParse(amountCtrl.text);
                    if (name.isEmpty || amount == null) return;

                    await ref.read(recurringDaoProvider).updateRecurring(
                          item.id,
                          name: name,
                          amount: (amount * 100).round(),
                          category: selectedCategory,
                          accountId: selectedAccountId,
                          dayOfMonth: int.tryParse(dayCtrl.text) ?? 1,
                          isAutopay: isAutopay,
                        );
                    ref.invalidate(recurringProvider);
                    ref.invalidate(recurringBucketsProvider);
                    ref.invalidate(dashboardProvider);
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: Text(AppStrings.get('save_changes')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum _RecurringStatus { due, paid, upcoming }
