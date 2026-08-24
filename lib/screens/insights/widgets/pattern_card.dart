import 'package:flutter/material.dart';
import 'package:habit_flow/theme/app_colors.dart';
import 'package:habit_flow/theme/app_typography.dart';
import 'package:habit_flow/utils/pattern_detector.dart';
import 'package:habit_flow/widgets/glass_card.dart';

class PatternCard extends StatelessWidget {
  final PatternInsight insight;
  final String habitName;

  const PatternCard({
    super.key,
    required this.insight,
    required this.habitName,
  });

  @override
  Widget build(BuildContext context) {
    IconData iconData;
    Color typeColor;

    switch (insight.type) {
      case PatternType.warning:
        iconData = Icons.warning_amber_rounded;
        typeColor = AppColors.missed;
        break;
      case PatternType.positive:
        iconData = Icons.thumb_up_rounded;
        typeColor = AppColors.completed;
        break;
      case PatternType.suggestion:
        iconData = Icons.lightbulb_rounded;
        typeColor = AppColors.accent;
        break;
    }

    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: typeColor, width: 4.0),
        ),
      ),
      child: GlassCard(
        padding: const EdgeInsets.all(16.0),
        backgroundColor: AppColors.card,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(iconData, color: typeColor, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(habitName, style: AppTypography.bodyMedium),
                  const SizedBox(height: 4),
                  Text(
                    insight.message,
                    style: AppTypography.body.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
