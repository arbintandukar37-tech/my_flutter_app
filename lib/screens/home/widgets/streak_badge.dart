import 'package:flutter/material.dart';
import 'package:habit_flow/theme/app_colors.dart';
import 'package:habit_flow/theme/app_typography.dart';

class StreakBadge extends StatelessWidget {
  final int streak;
  final bool hasFreezeUsed;
  final double consistencyPercent;

  const StreakBadge({
    super.key,
    required this.streak,
    this.hasFreezeUsed = false,
    required this.consistencyPercent,
  });

  @override
  Widget build(BuildContext context) {
    if (streak == 0) return const SizedBox.shrink();

    final isHighStreak = streak > 7;
    final percentStr = (consistencyPercent * 100).toStringAsFixed(0);

    return Tooltip(
      message: '$streak day streak • $percentStr% consistency this month',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.cardHover,
          borderRadius: BorderRadius.circular(12),
          border: isHighStreak ? Border.all(color: AppColors.accent.withValues(alpha: 0.5)) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '🔥',
              style: TextStyle(
                fontSize: 12,
                shadows: isHighStreak
                    ? [
                        const Shadow(
                          color: AppColors.accent,
                          blurRadius: 4,
                        )
                      ]
                    : null,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              streak.toString(),
              style: AppTypography.caption.copyWith(
                fontWeight: FontWeight.bold,
                color: isHighStreak ? AppColors.accent : AppColors.textPrimary,
              ),
            ),
            if (hasFreezeUsed) ...[
              const SizedBox(width: 4),
              const Text('❄️', style: TextStyle(fontSize: 10)),
            ],
          ],
        ),
      ),
    );
  }
}
