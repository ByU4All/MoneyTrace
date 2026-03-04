import 'package:flutter/material.dart';
import '../theme/colors.dart';

/// Centralized PNG icon mapping for event types and account types.
class AppIcons {
  AppIcons._();

  static const _eventIcons = <String, String>{
    'expense': 'assets/icons/expense.png',
    'income': 'assets/icons/income.png',
    'transfer': 'assets/icons/transfer.png',
    'liability': 'assets/icons/i_owe.png',
    'receivable': 'assets/icons/owes_me.png',
    'settlement_paid': 'assets/icons/settle.png',
    'settlement_received': 'assets/icons/settle.png',
    'budget_adjustment': 'assets/icons/income.png',
    'credit_card_payment': 'assets/icons/card.png',
    'emi_payment': 'assets/icons/bank.png',
  };

  static const _accountIcons = <String, String>{
    'savings': 'assets/icons/bank.png',
    'current': 'assets/icons/bank.png',
    'cash': 'assets/icons/cash.png',
    'credit_card': 'assets/icons/card.png',
    'upi_wallet': 'assets/icons/cash.png',
    'debit_card': 'assets/icons/card.png',
  };

  /// Returns a CircleAvatar with the PNG icon for the given event type.
  static Widget eventIcon(String type, {double radius = 20}) {
    final path = _eventIcons[type];
    if (path == null) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.surfaceLight,
        child: Icon(Icons.receipt, color: AppColors.accent, size: radius),
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.surfaceLight,
      child: ClipOval(
        child: Image.asset(
          path,
          width: radius * 1.4,
          height: radius * 1.4,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  /// Returns a CircleAvatar with the PNG icon for the given account type.
  static Widget accountIcon(String type, {double radius = 20}) {
    final path = _accountIcons[type];
    if (path == null) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.surfaceLight,
        child: Icon(Icons.account_balance_wallet, color: AppColors.accent, size: radius),
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.surfaceLight,
      child: ClipOval(
        child: Image.asset(
          path,
          width: radius * 1.4,
          height: radius * 1.4,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
