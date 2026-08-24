import 'package:flutter/material.dart';
import 'package:habit_flow/theme/app_colors.dart';
import 'package:habit_flow/theme/app_typography.dart';
import 'package:habit_flow/utils/strength_algorithm.dart';

class StrengthGauge extends StatelessWidget {
  final double score;
  final double height;
  final double width;

  const StrengthGauge({
    super.key,
    required this.score,
    this.height = 8.0,
    this.width = 120.0,
  });

  @override
  Widget build(BuildContext context) {
    final clampedScore = score.clamp(0.0, 100.0);
    final strengthColor = StrengthAlgorithm.strengthColor(clampedScore);
    final strengthText = StrengthAlgorithm.strengthLabel(clampedScore);

    Widget barContent = Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.cardHover,
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: Stack(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: clampedScore / 100.0),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: value,
                child: Container(
                  decoration: BoxDecoration(
                    color: strengthColor,
                    borderRadius: BorderRadius.circular(height / 2),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );

    final isInfinite = width == double.infinity;

    return Row(
      mainAxisSize: isInfinite ? MainAxisSize.max : MainAxisSize.min,
      children: [
        if (isInfinite)
          Expanded(child: barContent)
        else
          SizedBox(width: width, child: barContent),
        const SizedBox(width: 8),
        Text(
          '${clampedScore.toInt()} $strengthText',
          style: AppTypography.caption.copyWith(
            color: strengthColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
