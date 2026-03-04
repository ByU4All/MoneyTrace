import 'package:flutter/material.dart';
import '../theme/colors.dart';
import 'amount_display.dart';
import 'progress_bar.dart';

/// Budget overview card for the dashboard.
class BudgetCard extends StatelessWidget {
  final int baseBudget;
  final int available;
  final int spent;
  final int liabilities;
  final int receivables;
  final int unpaidCommitments;
  final VoidCallback? onTap;
  final VoidCallback? onLiabilitiesTap;
  final VoidCallback? onReceivablesTap;

  const BudgetCard({
    super.key,
    required this.baseBudget,
    required this.available,
    required this.spent,
    this.liabilities = 0,
    this.receivables = 0,
    this.unpaidCommitments = 0,
    this.onTap,
    this.onLiabilitiesTap,
    this.onReceivablesTap,
  });

  @override
  Widget build(BuildContext context) {
    final usedPercent = baseBudget > 0
        ? ((baseBudget - available) / baseBudget * 100).clamp(0, 100).toDouble()
        : 0.0;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Budget',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  AmountDisplay(
                    amount: available,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: available >= 0 ? AppColors.success : AppColors.danger,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'of ${formatAmount(baseBudget)} remaining',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              AppProgressBar(
                value: usedPercent,
                color: usedPercent > 90
                    ? AppColors.danger
                    : usedPercent > 70
                        ? AppColors.warning
                        : AppColors.success,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _StatItem(
                    label: 'Spent',
                    amount: spent,
                    color: AppColors.danger,
                  ),
                  if (unpaidCommitments > 0)
                    _StatItem(
                      label: 'Reserved',
                      amount: unpaidCommitments,
                      color: AppColors.info,
                    ),
                  InkWell(
                    onTap: onLiabilitiesTap,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: _StatItem(
                        label: 'You Owe',
                        amount: liabilities,
                        color: AppColors.warning,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: onReceivablesTap,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: _StatItem(
                        label: 'Owed to You',
                        amount: receivables,
                        color: AppColors.success,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final int amount;
  final Color color;

  const _StatItem({
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall,
        ),
        const SizedBox(height: 2),
        Text(
          formatAmount(amount),
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
