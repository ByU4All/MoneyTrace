import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../l10n/strings.dart';
import '../providers/dashboard_provider.dart';
import '../providers/database_provider.dart';
import '../screens/accounts_screen.dart';
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
      appBar: AppBar(title: Text(AppStrings.get('credit_cards'))),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCreditCardSheet(context, ref),
        tooltip: AppStrings.get('credit_cards'),
        child: const Icon(Icons.add),
      ),
      body: cardsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (cards) {
          if (cards.isEmpty) {
            return Center(
              child: Text(AppStrings.get('no_credit_cards'), style: const TextStyle(color: AppColors.textMuted)),
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
                                Text(AppStrings.get('outstanding'), style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                                Text(formatAmount(outstanding), style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.w500)),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(AppStrings.get('available'), style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                                Text(formatAmount(limit - outstanding), style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.w500)),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(AppStrings.get('limit'), style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
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

  void _showAddCreditCardSheet(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final institutionCtrl = TextEditingController();
    final limitCtrl = TextEditingController();
    final billingDayCtrl = TextEditingController();
    final dueDayCtrl = TextEditingController();

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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(AppStrings.get('credit_cards'),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(labelText: AppStrings.get('account_name')),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: institutionCtrl,
              decoration: InputDecoration(labelText: AppStrings.get('institution_optional')),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: limitCtrl,
              decoration: InputDecoration(labelText: AppStrings.get('credit_limit')),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: billingDayCtrl,
                    decoration: InputDecoration(labelText: AppStrings.get('billing_day')),
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
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty) return;
                final creditLimit = (int.tryParse(limitCtrl.text) ?? 0) * 100;
                await ref.read(accountDaoProvider).createAccount(
                  name: nameCtrl.text.trim(),
                  type: 'credit_card',
                  institution: institutionCtrl.text.trim().isNotEmpty
                      ? institutionCtrl.text.trim()
                      : null,
                  isCredit: true,
                  creditLimit: creditLimit,
                  billingDay: int.tryParse(billingDayCtrl.text),
                  dueDay: int.tryParse(dueDayCtrl.text),
                );
                ref.invalidate(creditCardsProvider);
                ref.invalidate(accountsProvider);
                ref.invalidate(dashboardProvider);
                if (context.mounted) Navigator.pop(context);
              },
              child: Text(AppStrings.get('credit_cards')),
            ),
          ],
        ),
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
            Text(AppStrings.format('edit_card_name', [card.name]), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            TextField(
              controller: limitCtrl,
              decoration: InputDecoration(labelText: AppStrings.get('credit_limit')),
              keyboardType: TextInputType.number,
              autofocus: true,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: billingDayCtrl,
                    decoration: InputDecoration(labelText: AppStrings.get('billing_day')),
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
              child: Text(AppStrings.get('save_changes')),
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
                    label: Text(AppStrings.get('edit_card')),
                  ),
                ),
                const SizedBox(height: 8),
                if (statements.isEmpty)
                  Center(child: Text(AppStrings.get('no_statements'), style: const TextStyle(color: AppColors.textMuted)))
                else
                  ...statements.map((stmt) => Card(
                    child: ListTile(
                      title: Text(AppStrings.format('statement_date', [stmt.statementDate])),
                      subtitle: Text(
                        '${AppStrings.format('due_paid_status', [stmt.dueDate])} \u2022 ${stmt.isFullyPaid == 1 ? AppStrings.get('paid') : AppStrings.get('unpaid')}',
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
