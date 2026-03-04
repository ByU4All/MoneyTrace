import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../providers/dashboard_provider.dart';
import '../theme/colors.dart';
import '../widgets/amount_display.dart';

class VisualSummaryScreen extends StatelessWidget {
  final DashboardData data;

  const VisualSummaryScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Budget Summary')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Donut chart — category spending
          if (data.categorySpend.isNotEmpty) ...[
            Text('Spending by Category', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 60,
                      sections: _buildSections(),
                    ),
                  ),
                  // Center text — remaining budget
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Available', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                      AmountDisplay(
                        amount: data.available,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: data.available >= 0 ? AppColors.success : AppColors.danger,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Legend
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: data.categorySpend.entries.toList().asMap().entries.map((entry) {
                final color = AppColors.categoryColors[entry.key % AppColors.categoryColors.length];
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                    const SizedBox(width: 4),
                    Text(entry.value.key, style: const TextStyle(fontSize: 12)),
                    const SizedBox(width: 4),
                    Text(formatAmount(entry.value.value), style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  ],
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],

          // Stats grid
          Text('Overview', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          _buildStatGrid(context),
          const SizedBox(height: 24),

          // You Owe breakdown
          if (_oweEntries.isNotEmpty) ...[
            Text('You Owe', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: _oweEntries.map((e) => ListTile(
                  title: Text(data.friendNames[e.key] ?? 'Unknown'),
                  trailing: AmountDisplay(
                    amount: e.value.abs(),
                    style: const TextStyle(color: AppColors.warning, fontWeight: FontWeight.w600),
                  ),
                )).toList(),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Owed to You breakdown
          if (_owedEntries.isNotEmpty) ...[
            Text('Owed to You', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: _owedEntries.map((e) => ListTile(
                  title: Text(data.friendNames[e.key] ?? 'Unknown'),
                  trailing: AmountDisplay(
                    amount: e.value,
                    style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.w600),
                  ),
                )).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildSections() {
    final entries = data.categorySpend.entries.toList();
    final total = entries.fold<int>(0, (sum, e) => sum + e.value);
    if (total == 0) return [];

    return entries.asMap().entries.map((entry) {
      final percent = entry.value.value / total * 100;
      final color = AppColors.categoryColors[entry.key % AppColors.categoryColors.length];
      return PieChartSectionData(
        color: color,
        value: entry.value.value.toDouble(),
        title: '${percent.toStringAsFixed(0)}%',
        titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
        radius: 35,
      );
    }).toList();
  }

  List<MapEntry<String, int>> get _oweEntries =>
      data.friendBalances.entries.where((e) => e.value < 0).toList()
        ..sort((a, b) => a.value.compareTo(b.value));

  List<MapEntry<String, int>> get _owedEntries =>
      data.friendBalances.entries.where((e) => e.value > 0).toList()
        ..sort((a, b) => b.value.compareTo(a.value));

  Widget _buildStatGrid(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: _statTile('Total Spent', data.spent, AppColors.danger)),
                Expanded(child: _statTile('Budget', data.baseBudget, AppColors.textPrimary)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _statTile('Available', data.available, data.available >= 0 ? AppColors.success : AppColors.danger)),
                if (data.unpaidCommitments > 0)
                  Expanded(child: _statTile('Reserved', data.unpaidCommitments, AppColors.info)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _statTile('You Owe', data.liabilities, AppColors.warning)),
                Expanded(child: _statTile('Owed to You', data.receivables, AppColors.success)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statTile(String label, int amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
        const SizedBox(height: 2),
        Text(
          formatAmount(amount),
          style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ],
    );
  }
}
