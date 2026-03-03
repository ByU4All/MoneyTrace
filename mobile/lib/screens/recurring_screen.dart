import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../providers/database_provider.dart';
import '../theme/colors.dart';
import '../widgets/amount_display.dart';

final recurringProvider = FutureProvider.autoDispose<List<RecurringTransaction>>((ref) async {
  return ref.watch(recurringDaoProvider).getRecurring();
});

final pendingProvider = FutureProvider.autoDispose<List<PendingTransaction>>((ref) async {
  return ref.watch(recurringDaoProvider).getPendingTransactions();
});

class RecurringScreen extends ConsumerWidget {
  const RecurringScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recurringAsync = ref.watch(recurringProvider);
    final pendingAsync = ref.watch(pendingProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Recurring')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddRecurringSheet(context, ref),
        child: const Icon(Icons.add),
      ),
      body: recurringAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (items) {
          final pending = pendingAsync.valueOrNull ?? [];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Pending section
              if (pending.isNotEmpty) ...[
                Text('Pending Verification', style: Theme.of(context).textTheme.titleMedium),
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
                            await ref.read(recurringDaoProvider).updatePendingStatus(p.id, 'confirmed');
                            ref.invalidate(pendingProvider);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.skip_next, color: AppColors.textMuted),
                          onPressed: () async {
                            await ref.read(recurringDaoProvider).updatePendingStatus(p.id, 'skipped');
                            ref.invalidate(pendingProvider);
                          },
                        ),
                      ],
                    ),
                  ),
                )),
                const SizedBox(height: 16),
              ],

              // Active recurring
              Text('Active', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (items.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: Text('No recurring transactions', style: TextStyle(color: AppColors.textMuted))),
                  ),
                )
              else
                ...items.map((item) => Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.surfaceLight,
                      child: Icon(
                        item.type == 'emi_payment' ? Icons.calendar_today : Icons.repeat,
                        color: AppColors.accent,
                      ),
                    ),
                    title: Text(item.name),
                    subtitle: Text(
                      '${formatAmount(item.amount)} \u2022 ${item.frequency}${item.nextDueDate != null ? ' \u2022 Next: ${item.nextDueDate}' : ''}',
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                    ),
                    trailing: PopupMenuButton(
                      itemBuilder: (ctx) => [
                        const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: AppColors.danger))),
                      ],
                      onSelected: (value) async {
                        if (value == 'delete') {
                          await ref.read(recurringDaoProvider).deleteRecurring(item.id);
                          ref.invalidate(recurringProvider);
                        }
                      },
                    ),
                  ),
                )),
            ],
          );
        },
      ),
    );
  }

  void _showAddRecurringSheet(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final dayCtrl = TextEditingController(text: '1');
    String selectedType = 'expense';
    String selectedFrequency = 'monthly';

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
              const Text('Add Recurring Transaction', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name'), autofocus: true),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedType,
                      decoration: const InputDecoration(labelText: 'Type'),
                      items: const [
                        DropdownMenuItem(value: 'expense', child: Text('Expense')),
                        DropdownMenuItem(value: 'emi_payment', child: Text('EMI')),
                        DropdownMenuItem(value: 'income', child: Text('Income')),
                      ],
                      onChanged: (v) => setState(() => selectedType = v!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedFrequency,
                      decoration: const InputDecoration(labelText: 'Frequency'),
                      items: const [
                        DropdownMenuItem(value: 'daily', child: Text('Daily')),
                        DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                        DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                        DropdownMenuItem(value: 'yearly', child: Text('Yearly')),
                      ],
                      onChanged: (v) => setState(() => selectedFrequency = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: TextField(controller: amountCtrl, decoration: const InputDecoration(labelText: 'Amount (\u20B9)'), keyboardType: TextInputType.number)),
                  const SizedBox(width: 12),
                  Expanded(child: TextField(controller: dayCtrl, decoration: const InputDecoration(labelText: 'Day of Month'), keyboardType: TextInputType.number)),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final name = nameCtrl.text.trim();
                  final amount = double.tryParse(amountCtrl.text);
                  if (name.isEmpty || amount == null) return;

                  final now = DateTime.now();
                  final startDate = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

                  await ref.read(recurringDaoProvider).createRecurring(
                    name: name,
                    type: selectedType,
                    amount: (amount * 100).round(),
                    frequency: selectedFrequency,
                    dayOfMonth: int.tryParse(dayCtrl.text) ?? 1,
                    startDate: startDate,
                  );
                  ref.invalidate(recurringProvider);
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Add'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
