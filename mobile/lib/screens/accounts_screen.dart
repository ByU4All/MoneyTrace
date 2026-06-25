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
import '../widgets/modal_sheet.dart' show showConfirmDialog;

final accountsProvider = FutureProvider.autoDispose<List<Account>>((ref) async {
  return ref.watch(accountDaoProvider).getAccounts();
});

/// Incremented by the corner FAB in MainShell when the Accounts tab is active.
/// AccountsScreen listens and opens the add-account sheet in response.
final addAccountTriggerProvider = StateProvider<int>((ref) => 0);

/// Sum of autopay recurring amounts (this period) per account, used to render
/// "On hold: ₹X" subtitles next to each account card.
final accountOnHoldProvider =
    FutureProvider.autoDispose<Map<String, int>>((ref) async {
  final recurringDao = ref.watch(recurringDaoProvider);
  final settingsDao = ref.watch(settingsDaoProvider);
  final eventDao = ref.watch(eventDaoProvider);

  final now = DateTime.now();
  final resetDay = await settingsDao.getBudgetResetDay();
  final (year, month) = getBudgetPeriod(now, resetDay);
  final periodStart = DateTime(year, month, resetDay);
  final periodEnd = DateTime(year, month + 1, resetDay)
      .subtract(const Duration(days: 1));

  final events = await eventDao.getEventsAsMaps(month: month, year: year);
  final recurring = await recurringDao.getRecurring();

  final onHold = <String, int>{};
  for (final r in recurring) {
    if (r.isAutopay != 1) continue;
    if (r.accountId == null) continue;
    if (r.type != 'expense' && r.type != 'emi_payment') continue;

    final nextDue = r.nextDueDate != null ? DateTime.tryParse(r.nextDueDate!) : null;
    final relevant = (r.frequency == 'monthly' ||
            r.frequency == 'daily' ||
            r.frequency == 'weekly') ||
        (nextDue != null &&
            !nextDue.isBefore(periodStart) &&
            !nextDue.isAfter(periodEnd));
    if (!relevant) continue;

    final hasEvent = events.any((e) => e['recurring_id'] == r.id);
    if (hasEvent) continue;

    onHold[r.accountId!] = (onHold[r.accountId!] ?? 0) + r.amount;
  }
  return onHold;
});

class _HoldItem {
  final String name;
  final int amount;
  const _HoldItem(this.name, this.amount);
}

final accountOnHoldItemsProvider =
    FutureProvider.autoDispose<Map<String, List<_HoldItem>>>((ref) async {
  final recurringDao = ref.watch(recurringDaoProvider);
  final settingsDao = ref.watch(settingsDaoProvider);
  final eventDao = ref.watch(eventDaoProvider);

  final now = DateTime.now();
  final resetDay = await settingsDao.getBudgetResetDay();
  final (year, month) = getBudgetPeriod(now, resetDay);
  final periodStart = DateTime(year, month, resetDay);
  final periodEnd = DateTime(year, month + 1, resetDay)
      .subtract(const Duration(days: 1));

  final events = await eventDao.getEventsAsMaps(month: month, year: year);
  final recurring = await recurringDao.getRecurring();

  final result = <String, List<_HoldItem>>{};
  for (final r in recurring) {
    if (r.isAutopay != 1) continue;
    if (r.accountId == null) continue;
    if (r.type != 'expense' && r.type != 'emi_payment') continue;

    final nextDue = r.nextDueDate != null ? DateTime.tryParse(r.nextDueDate!) : null;
    final relevant = (r.frequency == 'monthly' ||
            r.frequency == 'daily' ||
            r.frequency == 'weekly') ||
        (nextDue != null &&
            !nextDue.isBefore(periodStart) &&
            !nextDue.isAfter(periodEnd));
    if (!relevant) continue;

    final hasEvent = events.any((e) => e['recurring_id'] == r.id);
    if (hasEvent) continue;

    result.putIfAbsent(r.accountId!, () => []).add(_HoldItem(r.name, r.amount));
  }
  return result;
});

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountsProvider);
    final onHoldAsync = ref.watch(accountOnHoldProvider);
    final holdItemsAsync = ref.watch(accountOnHoldItemsProvider);

    ref.listen<int>(addAccountTriggerProvider, (_, __) {
      _showAddAccountSheet(context, ref);
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get('accounts')),
        actions: const [],
      ),
      body: accountsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (accounts) {
          if (accounts.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.account_balance_outlined,
                        size: 64, color: AppColors.textMuted),
                    const SizedBox(height: 16),
                    const Text('No accounts yet',
                        style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    const Text(
                      'Add your first bank, UPI, or Cash account to start tracking balances.\n\nTap the button below or the + icon at the top right.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary, height: 1.5),
                    ),
                    const SizedBox(height: 28),
                    FilledButton.icon(
                      onPressed: () => _showAddAccountSheet(context, ref),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Account',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
            );
          }
          final onHold = onHoldAsync.valueOrNull ?? {};
          final holdItems = holdItemsAsync.valueOrNull ?? {};
          final totalBalance = accounts.fold<int>(0, (sum, a) => sum + a.trackedBalance);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Net worth header
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.account_balance_wallet_outlined,
                        color: totalBalance >= 0 ? AppColors.success : AppColors.danger,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total Balance',
                              style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                          AmountDisplay(
                            amount: totalBalance,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: totalBalance >= 0 ? AppColors.success : AppColors.danger,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        '${accounts.length} account${accounts.length == 1 ? '' : 's'}',
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 4),
              ...accounts.map((account) {
              final hold = onHold[account.id] ?? 0;
              final base =
                  '${AppStrings.accountTypeName(account.type)}${account.institution != null ? ' • ${account.institution}' : ''}';
              return Card(
                child: ListTile(
                  leading: AppIcons.accountIcon(account.type),
                  title: Text(account.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(base,
                          style: const TextStyle(
                              color: AppColors.textMuted, fontSize: 12)),
                      if (hold > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Row(
                            children: [
                              const Icon(Icons.lock_outline,
                                  size: 12, color: AppColors.info),
                              const SizedBox(width: 4),
                              Text(
                                '${AppStrings.get('on_hold')}: ${formatAmount(hold)}',
                                style: const TextStyle(
                                    color: AppColors.info, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  trailing: AmountDisplay(
                    amount: account.trackedBalance,
                    colorize: true,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  onTap: () => _showAccountDetail(
                      context, ref, account, holdItems[account.id] ?? []),
                ),
              );
            }),
            ],
          );
        },
      ),
    );
  }

  void _showOnHoldDetail(BuildContext context, List<_HoldItem> items) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Upcoming Autopay',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              'Amounts reserved for this billing period',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
            const SizedBox(height: 12),
            if (items.isEmpty)
              const Text('No items on hold',
                  style: TextStyle(color: AppColors.textMuted))
            else
              ...items.map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                            child: Text(item.name,
                                style: const TextStyle(fontSize: 14))),
                        AmountDisplay(amount: item.amount),
                      ],
                    ),
                  )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showAddAccountSheet(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final institutionController = TextEditingController();
    final balanceController = TextEditingController(text: '0');
    final creditLimitCtrl = TextEditingController();
    final billingDayCtrl = TextEditingController();
    final dueDayCtrl = TextEditingController();
    String selectedType = 'savings';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 16, right: 16, top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(AppStrings.get('add_account'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: AppStrings.get('account_name')),
                autofocus: true,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: InputDecoration(labelText: AppStrings.get('type')),
                items: [
                  DropdownMenuItem(
                      value: 'savings',
                      child: Text(AppStrings.accountTypeName('savings'))),
                  DropdownMenuItem(
                      value: 'current',
                      child: Text(AppStrings.accountTypeName('current'))),
                  DropdownMenuItem(
                      value: 'cash', child: Text(AppStrings.accountTypeName('cash'))),
                  DropdownMenuItem(
                      value: 'credit_card',
                      child: Text(AppStrings.accountTypeName('credit_card'))),
                  DropdownMenuItem(
                      value: 'upi_wallet',
                      child: Text(AppStrings.accountTypeName('upi_wallet'))),
                ],
                onChanged: (v) => setState(() => selectedType = v!),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: institutionController,
                decoration:
                    InputDecoration(labelText: AppStrings.get('institution_optional')),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: balanceController,
                decoration: InputDecoration(labelText: AppStrings.get('initial_balance')),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              if (selectedType == 'credit_card') ...[
                const SizedBox(height: 12),
                TextField(
                  controller: creditLimitCtrl,
                  decoration: InputDecoration(labelText: AppStrings.get('credit_limit')),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: billingDayCtrl,
                        decoration:
                            InputDecoration(labelText: AppStrings.get('billing_day')),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: dueDayCtrl,
                        decoration: InputDecoration(labelText: AppStrings.get('due_day')),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (nameController.text.trim().isEmpty) return;
                  final balanceRupees = double.tryParse(balanceController.text) ?? 0;
                  final balancePaise = (balanceRupees * 100).round();
                  final isCreditCard = selectedType == 'credit_card';
                  final creditLimit = isCreditCard
                      ? (int.tryParse(creditLimitCtrl.text) ?? 0) * 100
                      : null;
                  final billingDay =
                      isCreditCard ? int.tryParse(billingDayCtrl.text) : null;
                  final dueDay = isCreditCard ? int.tryParse(dueDayCtrl.text) : null;
                  await ref.read(accountDaoProvider).createAccount(
                        name: nameController.text.trim(),
                        type: selectedType,
                        institution: institutionController.text.trim().isNotEmpty
                            ? institutionController.text.trim()
                            : null,
                        trackedBalance: balancePaise,
                        isCredit: isCreditCard,
                        creditLimit: creditLimit,
                        billingDay: billingDay,
                        dueDay: dueDay,
                      );
                  ref.invalidate(accountsProvider);
                  ref.invalidate(dashboardProvider);
                  if (context.mounted) Navigator.pop(context);
                },
                child: Text(AppStrings.get('add_account')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditAccountSheet(BuildContext context, WidgetRef ref, Account account) {
    final nameController = TextEditingController(text: account.name);
    final institutionController =
        TextEditingController(text: account.institution ?? '');
    final balanceController = TextEditingController(
        text: (account.trackedBalance / 100).toStringAsFixed(2));
    final originalBalance = account.trackedBalance;
    String selectedType = account.type;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(

        padding: EdgeInsets.only(
          left: 16, right: 16, top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(AppStrings.get('edit_account'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: AppStrings.get('account_name')),
                autofocus: true,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: InputDecoration(labelText: AppStrings.get('type')),
                items: const [
                  DropdownMenuItem(value: 'cash', child: Text('Cash')),
                  DropdownMenuItem(value: 'savings', child: Text('Savings')),
                  DropdownMenuItem(value: 'current', child: Text('Current')),
                  DropdownMenuItem(value: 'debit_card', child: Text('Debit Card')),
                  DropdownMenuItem(value: 'credit_card', child: Text('Credit Card')),
                  DropdownMenuItem(value: 'upi_wallet', child: Text('UPI Wallet')),
                ],
                onChanged: (v) => setModalState(() => selectedType = v!),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: institutionController,
                decoration:
                    InputDecoration(labelText: AppStrings.get('institution_optional')),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: balanceController,
                decoration: InputDecoration(
                  labelText: AppStrings.get('initial_balance'),
                  helperText: AppStrings.get('initial_balance_warning'),
                  helperMaxLines: 3,
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (nameController.text.trim().isEmpty) return;
                  final newBalanceRupees = double.tryParse(balanceController.text);
                  final newBalancePaise = newBalanceRupees != null
                      ? (newBalanceRupees * 100).round()
                      : originalBalance;

                  if (newBalancePaise != originalBalance &&
                      originalBalance != 0 &&
                      ((newBalancePaise - originalBalance).abs() / originalBalance.abs()) > 0.10) {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text(AppStrings.get('large_change_warning')),
                        content: Text(
                          '${formatAmount(originalBalance)} → ${formatAmount(newBalancePaise)}',
                        ),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: Text(AppStrings.get('cancel'))),
                          ElevatedButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: Text(AppStrings.get('save_changes'))),
                        ],
                      ),
                    );
                    if (ok != true) return;
                  }

                  await ref.read(accountDaoProvider).updateAccount(
                        account.id,
                        name: nameController.text.trim(),
                        type: selectedType,
                        institution: institutionController.text.trim().isNotEmpty
                            ? institutionController.text.trim()
                            : null,
                        trackedBalance: newBalancePaise,
                      );
                  ref.invalidate(accountsProvider);
                  ref.invalidate(dashboardProvider);
                  if (context.mounted) Navigator.pop(context);
                },
                child: Text(AppStrings.get('save_changes')),
              ),
            ],
          ),
        ),
      ),
    ),  // StatefulBuilder
    );
  }

  void _showAccountDetail(BuildContext context, WidgetRef ref, Account account,
      List<_HoldItem> holdItems) {
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(account.name,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(AppStrings.get('balance'),
                        style: const TextStyle(color: AppColors.textMuted)),
                    AmountDisplay(
                        amount: account.trackedBalance,
                        colorize: true,
                        style:
                            const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
                Column(
                  children: [
                    Text(AppStrings.get('type'),
                        style: const TextStyle(color: AppColors.textMuted)),
                    Text(AppStrings.accountTypeName(account.type)),
                  ],
                ),
              ],
            ),
            if (holdItems.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.lock_outline, size: 14, color: AppColors.info),
                    const SizedBox(width: 6),
                    const Text(
                      'On Hold — Upcoming Autopay',
                      style: TextStyle(
                          color: AppColors.info,
                          fontSize: 13,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              ...holdItems.map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                            child: Text(item.name,
                                style: const TextStyle(fontSize: 13))),
                        AmountDisplay(
                            amount: item.amount,
                            style: const TextStyle(fontSize: 13)),
                      ],
                    ),
                  )),
            ],
            const SizedBox(height: 16),
            if (account.isActive == 1) ...[
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _showEditAccountSheet(context, ref, account);
                },
                icon: const Icon(Icons.edit),
                label: Text(AppStrings.get('edit')),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () async {
                  final confirmed = await showConfirmDialog(
                    context: context,
                    title: 'Delete account?',
                    message: '"${account.name}" will be permanently deleted. This cannot be undone.',
                    confirmText: 'Delete',
                    isDangerous: true,
                  );
                  if (!confirmed) return;
                  await ref.read(accountDaoProvider).deleteAccount(account.id);
                  ref.invalidate(accountsProvider);
                  ref.invalidate(dashboardProvider);
                  if (context.mounted) Navigator.pop(context);
                },
                icon: const Icon(Icons.delete, color: AppColors.danger),
                label: Text(AppStrings.get('deactivate'),
                    style: const TextStyle(color: AppColors.danger)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
