import 'package:flutter/material.dart';
import '../l10n/strings.dart';
import '../theme/colors.dart';
import 'amount_display.dart';
import 'progress_bar.dart';

/// Budget overview card for the dashboard.
class BudgetCard extends StatelessWidget {
  final int baseBudget;
  final int available;
  final int spent;
  final int unpaidCommitments;
  final VoidCallback? onTap;
  final VoidCallback? onReservedTap;

  const BudgetCard({
    super.key,
    required this.baseBudget,
    required this.available,
    required this.spent,
    this.unpaidCommitments = 0,
    this.onTap,
    this.onReservedTap,
  });

  @override
  Widget build(BuildContext context) {
    final usedPercent = baseBudget > 0
        ? ((baseBudget - available) / baseBudget * 100).clamp(0, 100).toDouble()
        : 0.0;
    final barColor = usedPercent > 90
        ? AppColors.danger
        : usedPercent > 70
            ? AppColors.warning
            : AppColors.success;

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
                  Text(AppStrings.get('budget'),
                      style: Theme.of(context).textTheme.titleMedium),
                  AmountDisplay(
                    amount: available,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: available >= 0 ? AppColors.success : AppColors.danger,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              AppProgressBar(value: usedPercent, color: barColor),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${formatAmount(spent)} ${AppStrings.get('spent')}',
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                  ),
                  Text(
                    '${formatAmount(baseBudget)} total',
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                  ),
                ],
              ),
              if (unpaidCommitments > 0) ...[
                const SizedBox(height: 10),
                InkWell(
                  onTap: onReservedTap,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.info.withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.lock_clock, size: 14, color: AppColors.info),
                        const SizedBox(width: 6),
                        Text(
                          '${AppStrings.get('reserved')} ${formatAmount(unpaidCommitments)}',
                          style: const TextStyle(
                              color: AppColors.info, fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
