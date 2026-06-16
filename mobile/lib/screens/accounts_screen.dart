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

final accountsProvider = FutureProvider.autoDispose<List<Account>>((ref) async {
  return ref.watch(accountDaoProvider).getAccounts();
});

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

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountsProvider);
    final onHoldAsync = ref.watch(accountOnHoldProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get('accounts')),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_business),
            tooltip: AppStrings.get('add_account'),
            onPressed: () => _showAddAccountSheet(context, ref),
          ),
        ],
      ),
      body: accountsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (accounts) {
          if (accounts.isEmpty) {
            return Center(
              child: Text(AppStrings.get('no_accounts_yet'),
                  style: const TextStyle(color: AppColors.textMuted)),
            );
          }
          final onHold = onHoldAsync.valueOrNull ?? {};
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: accounts.length,
            itemBuilder: (context, index) {
              final account = accounts[index];
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
                  onTap: () => _showAccountDetail(context, ref, account),
                ),
              );
            },
          );
        },
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
                value: account.type,
                decoration: InputDecoration(labelText: AppStrings.get('type')),
                items: [
                  DropdownMenuItem(
                      value: account.type,
                      child: Text(AppStrings.accountTypeName(account.type))),
                ],
                onChanged: null,
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
    );
  }

  void _showAccountDetail(BuildContext context, WidgetRef ref, Account account) {
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
            Text(account.name,
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
