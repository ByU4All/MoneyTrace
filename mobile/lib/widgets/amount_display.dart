import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/colors.dart';

/// Returns color based on event type: red for outflows, green for inflows, null for neutral.
Color? colorForEventType(String type) {
  switch (type) {
    case 'expense':
    case 'settlement_paid':
    case 'credit_card_payment':
    case 'emi_payment':
      return AppColors.danger;
    case 'income':
    case 'settlement_received':
      return AppColors.success;
    default:
      return null;
  }
}

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

  if (paise < 0) return '-$formatted';
  if (showSign && paise > 0) return '+$formatted';
  return formatted;
}

/// Returns signed amount based on event type: negative for outflows, positive for inflows.
int signedAmount(int amount, String type) {
  switch (type) {
    case 'expense':
    case 'settlement_paid':
    case 'credit_card_payment':
    case 'emi_payment':
      return -amount;
    case 'income':
    case 'settlement_received':
      return amount;
    default:
      return amount;
  }
}

/// Widget that displays an amount with appropriate color.
class AmountDisplay extends StatelessWidget {
  final int amount;
  final bool showSign;
  final TextStyle? style;
  final bool colorize;
  final Color? color;

  const AmountDisplay({
    super.key,
    required this.amount,
    this.showSign = false,
    this.style,
    this.colorize = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    Color? effectiveColor = color;
    if (effectiveColor == null && colorize) {
      if (amount > 0) {
        effectiveColor = AppColors.success;
      } else if (amount < 0) {
        effectiveColor = AppColors.danger;
      }
    }

    return Text(
      formatAmount(amount, showSign: showSign),
      style: (style ?? const TextStyle()).copyWith(color: effectiveColor),
    );
  }
}
