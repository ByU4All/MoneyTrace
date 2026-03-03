import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/events.dart';
import '../data/database.dart';
import '../providers/database_provider.dart';
import '../theme/colors.dart';
import '../widgets/amount_display.dart';

final accountsProvider = FutureProvider.autoDispose<List<Account>>((ref) async {
  return ref.watch(accountDaoProvider).getAccounts();
});

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Accounts')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddAccountSheet(context, ref),
        child: const Icon(Icons.add),
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
                  leading: CircleAvatar(
                    backgroundColor: AppColors.surfaceLight,
                    child: Icon(
                      _accountIcon(account.type),
                      color: AppColors.accent,
                    ),
                  ),
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

  IconData _accountIcon(String type) {
    switch (type) {
      case 'savings': return Icons.savings;
      case 'current': return Icons.account_balance;
      case 'cash': return Icons.money;
      case 'credit_card': return Icons.credit_card;
      case 'upi_wallet': return Icons.phone_android;
      case 'debit_card': return Icons.credit_card;
      default: return Icons.account_balance_wallet;
    }
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
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (nameController.text.trim().isEmpty) return;
                  await ref.read(accountDaoProvider).createAccount(
                    name: nameController.text.trim(),
                    type: selectedType,
                    institution: institutionController.text.trim().isNotEmpty
                        ? institutionController.text.trim()
                        : null,
                  );
                  ref.invalidate(accountsProvider);
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
