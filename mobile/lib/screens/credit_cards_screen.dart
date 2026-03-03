import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../providers/database_provider.dart';
import '../theme/colors.dart';
import '../widgets/amount_display.dart';
import '../widgets/progress_bar.dart';

/// Credit card accounts are just accounts with type='credit_card'.
final creditCardsProvider = FutureProvider.autoDispose<List<Account>>((ref) async {
  final accounts = await ref.watch(accountDaoProvider).getAccounts();
  return accounts.where((a) => a.type == 'credit_card').toList();
});

class CreditCardsScreen extends ConsumerWidget {
  const CreditCardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardsAsync = ref.watch(creditCardsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Credit Cards')),
      body: cardsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (cards) {
          if (cards.isEmpty) {
            return const Center(
              child: Text('No credit cards', style: TextStyle(color: AppColors.textMuted)),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: cards.length,
            itemBuilder: (context, index) {
              final card = cards[index];
              final outstanding = card.trackedBalance.abs();
              final limit = card.creditLimit ?? 0;
              final utilization = limit > 0 ? (outstanding / limit * 100).clamp(0, 100).toDouble() : 0.0;

              return Card(
                child: InkWell(
                  onTap: () => _showCardStatements(context, ref, card),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(card.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                            if (card.institution != null)
                              Text(card.institution!, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Outstanding', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                                Text(formatAmount(outstanding), style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.w500)),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text('Available', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                                Text(formatAmount(limit - outstanding), style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.w500)),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text('Limit', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                                Text(formatAmount(limit)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        AppProgressBar(
                          value: utilization,
                          color: utilization > 70 ? AppColors.danger : AppColors.success,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showEditCardSheet(BuildContext context, WidgetRef ref, Account card) {
    final limitCtrl = TextEditingController(
      text: card.creditLimit != null ? (card.creditLimit! / 100).toStringAsFixed(0) : '',
    );
    final billingDayCtrl = TextEditingController(
      text: card.billingDay?.toString() ?? '',
    );
    final dueDayCtrl = TextEditingController(
      text: card.dueDay?.toString() ?? '',
    );

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
            Text('Edit ${card.name}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            TextField(
              controller: limitCtrl,
              decoration: const InputDecoration(labelText: 'Credit Limit (\u20B9)'),
              keyboardType: TextInputType.number,
              autofocus: true,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: billingDayCtrl,
                    decoration: const InputDecoration(labelText: 'Billing Day'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: dueDayCtrl,
                    decoration: const InputDecoration(labelText: 'Due Day'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final limit = double.tryParse(limitCtrl.text);
                final billingDay = int.tryParse(billingDayCtrl.text);
                final dueDay = int.tryParse(dueDayCtrl.text);

                await ref.read(accountDaoProvider).updateAccount(
                  card.id,
                  creditLimit: limit != null ? (limit * 100).round() : null,
                  billingDay: billingDay,
                  dueDay: dueDay,
                );
                ref.invalidate(creditCardsProvider);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCardStatements(BuildContext context, WidgetRef ref, Account card) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => FutureBuilder(
          future: ref.read(creditCardDaoProvider).getStatements(cardAccountId: card.id),
          builder: (context, snapshot) {
            final statements = snapshot.data ?? [];

            return ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              children: [
                Center(child: Text(card.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600))),
                const SizedBox(height: 12),
                Center(
                  child: TextButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showEditCardSheet(context, ref, card);
                    },
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Edit Card'),
                  ),
                ),
                const SizedBox(height: 8),
                if (statements.isEmpty)
                  const Center(child: Text('No statements', style: TextStyle(color: AppColors.textMuted)))
                else
                  ...statements.map((stmt) => Card(
                    child: ListTile(
                      title: Text('Statement: ${stmt.statementDate}'),
                      subtitle: Text(
                        'Due: ${stmt.dueDate} \u2022 ${stmt.isFullyPaid == 1 ? 'Paid' : 'Unpaid'}',
                        style: TextStyle(
                          color: stmt.isFullyPaid == 1 ? AppColors.success : AppColors.danger,
                          fontSize: 12,
                        ),
                      ),
                      trailing: Text(
                        formatAmount(stmt.statementAmount),
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  )),
              ],
            );
          },
        ),
      ),
    );
  }
}
