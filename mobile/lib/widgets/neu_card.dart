import 'package:flutter/material.dart';
import '../theme/colors.dart';

/// Neumorphic card with dual BoxShadow (light top-left, dark bottom-right).
/// Use this for prominent containers where the raised-surface effect matters.
/// Regular [Card] widgets pick up the shadow from the theme automatically.
class NeuCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color? color;

  const NeuCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 16,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final base = color ?? AppColors.card;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: base,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowLight,
            offset: Offset(-4, -4),
            blurRadius: 10,
          ),
          BoxShadow(
            color: AppColors.shadowDark,
            offset: Offset(4, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: padding != null
            ? Padding(padding: padding!, child: child)
            : child,
      ),
    );
  }
}
