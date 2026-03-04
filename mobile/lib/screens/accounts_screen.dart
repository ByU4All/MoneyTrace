import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../providers/dashboard_provider.dart';
import '../providers/database_provider.dart';
import '../theme/colors.dart';
import '../widgets/amount_display.dart';
import '../widgets/app_icons.dart';

final accountsProvider = FutureProvider.autoDispose<List<Account>>((ref) async {
  return ref.watch(accountDaoProvider).getAccounts();
});

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accounts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_business),
            tooltip: 'Add Account',
            onPressed: () => _showAddAccountSheet(context, ref),
          ),
        ],
      ),
      body: accountsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (accounts) {
          if (accounts.isEmpty) {
            return const Center(
              child: Text('No accounts yet', style: TextStyle(color: AppColors.textMuted)),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: accounts.length,
            itemBuilder: (context, index) {
              final account = accounts[index];
              return Card(
                child: ListTile(
                  leading: AppIcons.accountIcon(account.type),
                  title: Text(account.name),
                  subtitle: Text(
                    '${_accountTypeName(account.type)}${account.institution != null ? ' \u2022 ${account.institution}' : ''}',
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
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

  String _accountTypeName(String type) {
    switch (type) {
      case 'savings': return 'Savings';
      case 'current': return 'Current';
      case 'cash': return 'Cash';
      case 'credit_card': return 'Credit Card';
      case 'upi_wallet': return 'UPI Wallet';
      case 'debit_card': return 'Debit Card';
      default: return type;
    }
  }

  void _showAddAccountSheet(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final institutionController = TextEditingController();
    final balanceController = TextEditingController(text: '0');
    String selectedType = 'savings';

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
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Add Account', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Account Name'),
                autofocus: true,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: const InputDecoration(labelText: 'Type'),
                items: const [
                  DropdownMenuItem(value: 'savings', child: Text('Savings')),
                  DropdownMenuItem(value: 'current', child: Text('Current')),
                  DropdownMenuItem(value: 'cash', child: Text('Cash')),
                  DropdownMenuItem(value: 'credit_card', child: Text('Credit Card')),
                  DropdownMenuItem(value: 'upi_wallet', child: Text('UPI Wallet')),
                ],
                onChanged: (v) => setState(() => selectedType = v!),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: institutionController,
                decoration: const InputDecoration(labelText: 'Institution (optional)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: balanceController,
                decoration: const InputDecoration(labelText: 'Initial Balance (\u20B9)'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (nameController.text.trim().isEmpty) return;
                  final balanceRupees = double.tryParse(balanceController.text) ?? 0;
                  final balancePaise = (balanceRupees * 100).round();
                  await ref.read(accountDaoProvider).createAccount(
                    name: nameController.text.trim(),
                    type: selectedType,
                    institution: institutionController.text.trim().isNotEmpty
                        ? institutionController.text.trim()
                        : null,
                    trackedBalance: balancePaise,
                  );
                  ref.invalidate(accountsProvider);
                  ref.invalidate(dashboardProvider);
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Add Account'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditAccountSheet(BuildContext context, WidgetRef ref, Account account) {
    final nameController = TextEditingController(text: account.name);
    final institutionController = TextEditingController(text: account.institution ?? '');

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
            const Text('Edit Account', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Account Name'),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: account.type,
              decoration: const InputDecoration(labelText: 'Type'),
              items: [
                DropdownMenuItem(value: account.type, child: Text(_accountTypeName(account.type))),
              ],
              onChanged: null, // Disabled — changing type breaks balance semantics
            ),
            const SizedBox(height: 12),
            TextField(
              controller: institutionController,
              decoration: const InputDecoration(labelText: 'Institution (optional)'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) return;
                await ref.read(accountDaoProvider).updateAccount(
                  account.id,
                  name: nameController.text.trim(),
                  institution: institutionController.text.trim().isNotEmpty
                      ? institutionController.text.trim()
                      : null,
                );
                ref.invalidate(accountsProvider);
                ref.invalidate(dashboardProvider);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Save Changes'),
            ),
          ],
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
            Text(account.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text('Balance', style: TextStyle(color: AppColors.textMuted)),
                    AmountDisplay(amount: account.trackedBalance, colorize: true,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
                Column(
                  children: [
                    const Text('Type', style: TextStyle(color: AppColors.textMuted)),
                    Text(_accountTypeName(account.type)),
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
                label: const Text('Edit'),
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
                label: const Text('Deactivate', style: TextStyle(color: AppColors.danger)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
