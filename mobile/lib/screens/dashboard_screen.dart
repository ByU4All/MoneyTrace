import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/dashboard_provider.dart';
import '../theme/colors.dart';
import '../widgets/amount_display.dart' show AmountDisplay, formatAmount, colorForEventType, signedAmount;
import '../widgets/app_icons.dart';
import '../widgets/budget_card.dart';
import 'visual_summary_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('MoneyTrace'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: dashboardAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (data) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(dashboardProvider),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Budget Card
              BudgetCard(
                baseBudget: data.baseBudget,
                available: data.available,
                spent: data.spent,
                liabilities: data.liabilities,
                receivables: data.receivables,
                unpaidCommitments: data.unpaidCommitments,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => VisualSummaryScreen(data: data)),
                ),
                onReservedTap: data.unpaidRecurringItems.isNotEmpty
                    ? () => _showReservedBreakdown(context, data)
                    : null,
                onLiabilitiesTap: () => _showBalanceSheet(
                  context,
                  title: 'You Owe',
                  totalAmount: data.liabilities,
                  friendBalances: data.friendBalances,
                  friendNames: data.friendNames,
                  filterPositive: false,
                ),
                onReceivablesTap: () => _showBalanceSheet(
                  context,
                  title: 'Owed to You',
                  totalAmount: data.receivables,
                  friendBalances: data.friendBalances,
                  friendNames: data.friendNames,
                  filterPositive: true,
                ),
              ),
              const SizedBox(height: 8),
              const Divider(color: AppColors.surfaceLight, thickness: 1),
              const SizedBox(height: 8),

              // Category Spending
              if (data.categorySpend.isNotEmpty) ...[
                Text(
                  'Spending by Category',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: data.categorySpend.entries.map((entry) {
                        final percent = data.spent > 0
                            ? (entry.value / data.spent * 100)
                            : 0.0;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  entry.key,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: LinearProgressIndicator(
                                  value: percent / 100,
                                  backgroundColor: AppColors.surfaceLight,
                                  valueColor: AlwaysStoppedAnimation(
                                    AppColors.categoryColors[
                                        data.categorySpend.keys.toList().indexOf(entry.key) %
                                            AppColors.categoryColors.length],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                formatAmount(entry.value),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Divider(color: AppColors.surfaceLight, thickness: 1),
                const SizedBox(height: 8),
              ],

              // Recent Activity
              Text(
                'Recent Activity',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              if (data.recentEvents.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        'No transactions yet',
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                    ),
                  ),
                )
              else ...[
                ...data.recentEvents.map((event) => Card(
                      child: ListTile(
                        leading: AppIcons.eventIcon(event['type'] as String),
                        title: Text(
                          event['description'] as String? ??
                              _eventTypeName(event['type'] as String),
                        ),
                        subtitle: Text(
                          '${event['category'] ?? ''} \u2022 ${event['event_date']}',
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                        ),
                        trailing: AmountDisplay(
                          amount: signedAmount(event['amount'] as int, event['type'] as String),
                          showSign: true,
                          color: colorForEventType(event['type'] as String),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    )),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/history'),
                    child: const Text('View All'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showReservedBreakdown(BuildContext context, DashboardData data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.4,
        minChildSize: 0.25,
        maxChildSize: 0.7,
        expand: false,
        builder: (context, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          children: [
            const Center(
              child: Text('Reserved', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 8),
            Center(
              child: AmountDisplay(
                amount: data.unpaidCommitments,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.info,
                ),
              ),
            ),
            const SizedBox(height: 4),
            const Center(
              child: Text(
                'Unpaid recurring this month',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
            ),
            const SizedBox(height: 16),
            ...data.unpaidRecurringItems.map((item) => ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.surfaceLight,
                child: Icon(
                  item['type'] == 'emi_payment' ? Icons.receipt_long : Icons.repeat,
                  color: AppColors.info,
                  size: 18,
                ),
              ),
              title: Text(item['name'] as String),
              subtitle: Text(
                item['type'] == 'emi_payment' ? 'EMI Payment' : 'Expense',
                style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
              trailing: AmountDisplay(
                amount: item['amount'] as int,
                style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.info),
              ),
            )),
          ],
        ),
      ),
    );
  }

  void _showBalanceSheet(
    BuildContext context, {
    required String title,
    required int totalAmount,
    required Map<String, int> friendBalances,
    required Map<String, String> friendNames,
    required bool filterPositive,
  }) {
    // filterPositive=true → receivables (positive balances = friend owes you)
    // filterPositive=false → liabilities (negative balances = you owe friend)
    final entries = friendBalances.entries.where((e) {
      return filterPositive ? e.value > 0 : e.value < 0;
    }).toList()
      ..sort((a, b) => b.value.abs().compareTo(a.value.abs()));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.85,
        expand: false,
        builder: (context, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 8),
            Center(
              child: AmountDisplay(
                amount: totalAmount,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: filterPositive ? AppColors.success : AppColors.warning,
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (entries.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('No balances', style: TextStyle(color: AppColors.textMuted)),
                ),
              )
            else
              ...entries.map((entry) {
                final name = friendNames[entry.key] ?? 'Unknown';
                final amount = entry.value.abs();
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.surfaceLight,
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  title: Text(name),
                  trailing: AmountDisplay(
                    amount: amount,
                    colorize: true,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  String _eventTypeName(String type) {
    final names = {
      'expense': 'Expense',
      'liability': 'I Owe',
      'receivable': 'Owes Me',
      'settlement_paid': 'Settled (Paid)',
      'settlement_received': 'Settled (Received)',
      'budget_adjustment': 'Adjustment',
      'transfer': 'Transfer',
      'income': 'Income',
      'credit_card_payment': 'CC Payment',
      'emi_payment': 'EMI Payment',
    };
    return names[type] ?? type;
  }
}
