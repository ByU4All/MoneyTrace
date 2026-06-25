import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/strings.dart';
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
              // ── Budget card ────────────────────────────────────────────
              BudgetCard(
                baseBudget: data.baseBudget,
                available: data.available,
                spent: data.spent,
                unpaidCommitments: data.unpaidCommitments,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => VisualSummaryScreen(data: data)),
                ),
                onReservedTap: data.unpaidRecurringItems.isNotEmpty
                    ? () => _showReservedBreakdown(context, data)
                    : null,
              ),
              const SizedBox(height: 8),

              // ── You Owe / Owed to You ──────────────────────────────────
              _buildFriendBalanceRow(context, data),

              // ── On Hold ────────────────────────────────────────────────
              if (data.onHoldItems.isNotEmpty) ...[
                const SizedBox(height: 4),
                const Divider(color: AppColors.surfaceLight, thickness: 1),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () => _showOnHoldSheet(context, data),
                  borderRadius: BorderRadius.circular(12),
                  child: Row(
                    children: [
                      const Icon(Icons.lock_clock, size: 18, color: AppColors.info),
                      const SizedBox(width: 8),
                      Text(AppStrings.get('on_hold'),
                          style: Theme.of(context).textTheme.titleMedium),
                      const Spacer(),
                      const Icon(Icons.chevron_right, size: 16, color: AppColors.textMuted),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () => _showOnHoldSheet(context, data),
                  borderRadius: BorderRadius.circular(12),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Column(
                        children: data.onHoldItems.map((item) => ListTile(
                              dense: true,
                              leading: const Icon(Icons.lock_outline,
                                  color: AppColors.info, size: 20),
                              title: Text(item['name'] as String),
                              subtitle: Text(
                                item['reason'] as String? ?? '',
                                style: const TextStyle(
                                    color: AppColors.textMuted, fontSize: 11),
                              ),
                              trailing: AmountDisplay(
                                amount: item['amount'] as int,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.info),
                              ),
                            )).toList(),
                      ),
                    ),
                  ),
                ),
              ],

              // ── Category spend ─────────────────────────────────────────
              if (data.categorySpend.isNotEmpty) ...[
                const SizedBox(height: 4),
                const Divider(color: AppColors.surfaceLight, thickness: 1),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => VisualSummaryScreen(data: data)),
                  ),
                  borderRadius: BorderRadius.circular(4),
                  child: Row(
                    children: [
                      Text(AppStrings.get('spending_by_category'),
                          style: Theme.of(context).textTheme.titleMedium),
                      const Spacer(),
                      const Icon(Icons.chevron_right, size: 16, color: AppColors.textMuted),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => VisualSummaryScreen(data: data)),
                  ),
                  borderRadius: BorderRadius.circular(12),
                  child: Card(
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
                                  child: Text(entry.key,
                                      style: Theme.of(context).textTheme.bodyMedium),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: LinearProgressIndicator(
                                    value: percent / 100,
                                    backgroundColor: AppColors.surfaceLight,
                                    valueColor: AlwaysStoppedAnimation(
                                      AppColors.categoryColors[
                                          data.categorySpend.keys
                                                  .toList()
                                                  .indexOf(entry.key) %
                                              AppColors.categoryColors.length],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(formatAmount(entry.value),
                                    style: Theme.of(context).textTheme.bodySmall),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ],

              // ── Recent activity ────────────────────────────────────────
              const SizedBox(height: 4),
              const Divider(color: AppColors.surfaceLight, thickness: 1),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => Navigator.pushNamed(context, '/history'),
                borderRadius: BorderRadius.circular(4),
                child: Row(
                  children: [
                    Text(AppStrings.get('recent_activity'),
                        style: Theme.of(context).textTheme.titleMedium),
                    const Spacer(),
                    const Icon(Icons.chevron_right, size: 16, color: AppColors.textMuted),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              if (data.recentEvents.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        AppStrings.get('no_transactions_yet'),
                        style: const TextStyle(color: AppColors.textMuted),
                      ),
                    ),
                  ),
                )
              else
                ...data.recentEvents.map((event) => Card(
                      child: ListTile(
                        leading: AppIcons.eventIcon(event['type'] as String),
                        title: Text(
                          event['description'] as String? ??
                              AppStrings.eventTypeName(event['type'] as String),
                        ),
                        subtitle: Text(
                          '${event['category'] ?? ''} • ${event['event_date']}',
                          style: const TextStyle(
                              color: AppColors.textMuted, fontSize: 12),
                        ),
                        trailing: AmountDisplay(
                          amount: signedAmount(
                              event['amount'] as int, event['type'] as String),
                          showSign: true,
                          color: colorForEventType(event['type'] as String),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    )),
            ],
          ),
        ),
      ),
    );
  }

  // ── Friend balance row ───────────────────────────────────────────────────

  Widget _buildFriendBalanceRow(BuildContext context, DashboardData data) {
    final owes = data.friendBalances.entries
        .where((e) => e.value < 0)
        .toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    final owed = data.friendBalances.entries
        .where((e) => e.value > 0)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (owes.isEmpty && owed.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _FriendCard(
                  title: AppStrings.get('you_owe'),
                  total: data.liabilities,
                  entries: owes,
                  friendNames: data.friendNames,
                  color: AppColors.warning,
                  emptyLabel: AppStrings.get('no_balances'),
                  onTap: () => _showBalanceSheet(
                    context,
                    title: AppStrings.get('you_owe'),
                    totalAmount: data.liabilities,
                    friendBalances: data.friendBalances,
                    friendNames: data.friendNames,
                    filterPositive: false,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _FriendCard(
                  title: AppStrings.get('owed_to_you'),
                  total: data.receivables,
                  entries: owed,
                  friendNames: data.friendNames,
                  color: AppColors.success,
                  emptyLabel: AppStrings.get('no_balances'),
                  onTap: () => _showBalanceSheet(
                    context,
                    title: AppStrings.get('owed_to_you'),
                    totalAmount: data.receivables,
                    friendBalances: data.friendBalances,
                    friendNames: data.friendNames,
                    filterPositive: true,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  // ── Bottom sheets ────────────────────────────────────────────────────────

  void _showBalanceSheet(
    BuildContext context, {
    required String title,
    required int totalAmount,
    required Map<String, int> friendBalances,
    required Map<String, String> friendNames,
    required bool filterPositive,
  }) {
    final entries = friendBalances.entries.where((e) {
      return filterPositive ? e.value > 0 : e.value < 0;
    }).toList()
      ..sort((a, b) => b.value.abs().compareTo(a.value.abs()));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
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
              child: Text(title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600)),
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
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(AppStrings.get('no_balances'),
                      style: const TextStyle(color: AppColors.textMuted)),
                ),
              )
            else
              ...entries.map((entry) {
                final name = friendNames[entry.key] ?? 'Unknown';
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
                    amount: entry.value.abs(),
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

  void _showOnHoldSheet(BuildContext context, DashboardData data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
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
              child: Text(AppStrings.get('on_hold'),
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(AppStrings.get('on_hold_subtitle'),
                  style: const TextStyle(
                      color: AppColors.textMuted, fontSize: 12)),
            ),
            const SizedBox(height: 16),
            ...data.onHoldItems.map((item) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.info.withAlpha(30),
                    child: const Icon(Icons.lock_outline,
                        color: AppColors.info, size: 18),
                  ),
                  title: Text(item['name'] as String),
                  subtitle: Text(
                    item['reason'] as String? ?? '',
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 12),
                  ),
                  trailing: AmountDisplay(
                    amount: item['amount'] as int,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, color: AppColors.info),
                  ),
                )),
          ],
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
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.4,
        minChildSize: 0.25,
        maxChildSize: 0.7,
        expand: false,
        builder: (context, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: Text(AppStrings.get('reserved'),
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 8),
            Center(
              child: AmountDisplay(
                amount: data.unpaidCommitments,
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.info),
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(AppStrings.get('unpaid_recurring_this_month'),
                  style: const TextStyle(
                      color: AppColors.textMuted, fontSize: 12)),
            ),
            const SizedBox(height: 16),
            ...data.unpaidRecurringItems.map((item) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.surfaceLight,
                    child: Icon(
                      item['type'] == 'emi_payment'
                          ? Icons.receipt_long
                          : Icons.repeat,
                      color: AppColors.info,
                      size: 18,
                    ),
                  ),
                  title: Text(item['name'] as String),
                  subtitle: Text(
                    AppStrings.eventTypeName(item['type'] as String),
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 12),
                  ),
                  trailing: AmountDisplay(
                    amount: item['amount'] as int,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, color: AppColors.info),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

// ── Friend balance card widget ─────────────────────────────────────────────

class _FriendCard extends StatelessWidget {
  final String title;
  final int total;
  final List<MapEntry<String, int>> entries;
  final Map<String, String> friendNames;
  final Color color;
  final String emptyLabel;
  final VoidCallback? onTap;

  const _FriendCard({
    required this.title,
    required this.total,
    required this.entries,
    required this.friendNames,
    required this.color,
    required this.emptyLabel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                total > 0 ? '$title  ${formatAmount(total)}' : title,
                style: TextStyle(
                    fontSize: 10,
                    color: color,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3),
              ),
              const SizedBox(height: 6),
              if (entries.isEmpty)
                Text(emptyLabel,
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 11))
              else
                ...entries.take(3).map((e) {
                  final name = friendNames[e.key] ?? '?';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 11,
                          backgroundColor: color.withAlpha(40),
                          child: Text(
                            name.isNotEmpty ? name[0].toUpperCase() : '?',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: color),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            name,
                            style: const TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          formatAmount(e.value.abs()),
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: color),
                        ),
                      ],
                    ),
                  );
                }),
              if (entries.length > 3)
                Text(
                  '+${entries.length - 3} more',
                  style: const TextStyle(
                      color: AppColors.textMuted, fontSize: 10),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
