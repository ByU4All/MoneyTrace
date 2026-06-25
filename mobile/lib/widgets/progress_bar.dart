import 'package:flutter/material.dart';
import '../theme/colors.dart';

/// Custom progress bar matching web app style.
class AppProgressBar extends StatelessWidget {
  final double value; // 0-100
  final Color? color;
  final double height;

  const AppProgressBar({
    super.key,
    required this.value,
    this.color,
    this.height = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: (value / 100).clamp(0, 1),
        child: Container(
          decoration: BoxDecoration(
            color: color ?? AppColors.accent,
            borderRadius: BorderRadius.circular(height / 2),
          ),
        ),
      ),
    );
  }
}
