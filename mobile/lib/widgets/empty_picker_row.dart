import 'package:flutter/material.dart';

import '../theme/colors.dart';

/// Shown in place of a dropdown when the list it would display is empty.
/// Tapping opens an [AlertDialog] explaining what needs to be created and how.
class EmptyPickerRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String dialogTitle;
  final String dialogMessage;

  const EmptyPickerRow({
    super.key,
    required this.icon,
    required this.label,
    required this.dialogTitle,
    required this.dialogMessage,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(dialogTitle),
          content: Text(
            dialogMessage,
            style: const TextStyle(color: AppColors.textSecondary, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      ),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.warning.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.warning),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(color: AppColors.warning, fontSize: 14),
              ),
            ),
            const Icon(Icons.info_outline, size: 18, color: AppColors.warning),
          ],
        ),
      ),
    );
  }
}
