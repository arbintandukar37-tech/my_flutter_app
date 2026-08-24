import 'package:flutter/material.dart';
import 'package:habit_flow/theme/app_colors.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.margin = const EdgeInsets.symmetric(horizontal: 4.0, vertical: 6.0),
    this.backgroundColor,
    this.onTap,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final defaultRadius = borderRadius ?? BorderRadius.circular(16.0);
    final cardColor = backgroundColor ?? AppColors.card;

    Widget content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: defaultRadius,
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.3),
          width: 1.0,
        ),
      ),
      child: child,
    );

    if (onTap != null) {
      content = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: defaultRadius,
          splashColor: AppColors.cardHover.withValues(alpha: 0.5),
          highlightColor: AppColors.cardHover.withValues(alpha: 0.3),
          child: content,
        ),
      );
    }

    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: defaultRadius,
        child: content,
      ),
    );
  }
}
