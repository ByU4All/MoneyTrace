import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/colors.dart';

/// Format paise to Indian rupee display string.
String formatAmount(int paise, {bool showSign = false}) {
  final rupees = paise / 100;
  // Indian number format: 1,00,000
  final formatter = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '\u20B9',
    decimalDigits: 0,
  );
  final formatted = formatter.format(rupees.abs());

  if (showSign && paise != 0) {
    return paise > 0 ? '+$formatted' : '-$formatted';
  }
  return formatted;
}

/// Widget that displays an amount with appropriate color.
class AmountDisplay extends StatelessWidget {
  final int amount;
  final bool showSign;
  final TextStyle? style;
  final bool colorize;

  const AmountDisplay({
    super.key,
    required this.amount,
    this.showSign = false,
    this.style,
    this.colorize = false,
  });

  @override
  Widget build(BuildContext context) {
    Color? color;
    if (colorize) {
      if (amount > 0) {
        color = AppColors.success;
      } else if (amount < 0) {
        color = AppColors.danger;
      }
    }

    return Text(
      formatAmount(amount, showSign: showSign),
      style: (style ?? const TextStyle()).copyWith(color: color),
    );
  }
}
