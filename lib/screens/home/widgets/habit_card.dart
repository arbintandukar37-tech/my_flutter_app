import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:habit_flow/models/habit.dart';
import 'package:habit_flow/models/habit_type.dart';
import 'package:habit_flow/providers/habit_logs_provider.dart';
import 'package:habit_flow/providers/insights_provider.dart';
import 'package:habit_flow/theme/app_colors.dart';
import 'package:habit_flow/theme/app_typography.dart';
import 'package:habit_flow/utils/haptic_utils.dart';
import 'package:habit_flow/screens/home/widgets/habit_checkbox.dart';
import 'package:habit_flow/screens/home/widgets/quantity_stepper.dart';
import 'package:habit_flow/screens/home/widgets/streak_badge.dart';
import 'package:habit_flow/screens/habit_detail/habit_detail_screen.dart';

class HabitCard extends ConsumerWidget {
  final Habit habit;
  final DateTime date;

  const HabitCard({
    super.key,
    required this.habit,
    required this.date,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCompleted =
        ref.watch(habitLogsProvider.notifier).isCompletedForDate(habit.id, date);
    final streakResult = ref.watch(habitStreakProvider(habit.id));
    final consistency = ref.watch(habitConsistencyProvider(habit.id));

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => HabitDetailScreen(habit: habit),
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isCompleted ? AppColors.completedDim : AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCompleted
                ? AppColors.completed.withValues(alpha: 0.3)
                : AppColors.border.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Habit icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: habit.habitColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(habit.iconData, color: habit.habitColor, size: 24),
              ),
              const SizedBox(width: 16),

              // Habit info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.name,
                      style: AppTypography.bodyMedium.copyWith(
                        color: isCompleted
                            ? AppColors.textSecondary
                            : AppColors.textPrimary,
                        decoration:
                            isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          habit.frequency.displayText,
                          style: AppTypography.caption
                              .copyWith(color: AppColors.textMuted),
                        ),
                        if (streakResult.currentStreak > 0) ...[
                          const SizedBox(width: 8),
                          StreakBadge(
                            streak: streakResult.currentStreak,
                            hasFreezeUsed: streakResult.freezesUsed > 0,
                            consistencyPercent: consistency,
                          ),
                        ],
                      ],
                    ),
                    if (habit.type == HabitType.bad) ...[
                      const SizedBox(height: 4),
                      Text(
                        isCompleted ? 'Slip logged' : 'Tap to log a slip',
                        style: AppTypography.caption
                            .copyWith(color: AppColors.badHabit),
                      ),
                    ],
                  ],
                ),
              ),

              // Action widget (checkbox / stepper / bad habit button)
              if (habit.type == HabitType.bad)
                IconButton(
                  icon: Icon(
                    isCompleted ? Icons.close_rounded : Icons.close_rounded,
                    color: isCompleted ? AppColors.missed : AppColors.textMuted,
                  ),
                  onPressed: () {
                    ref
                        .read(habitLogsProvider.notifier)
                        .toggleHabit(habit.id, date);
                    HapticUtils.lightTap();
                  },
                )
              else if (habit.isQuantitative)
                QuantityStepper(habit: habit, date: date)
              else
                HabitCheckbox(
                  isChecked: isCompleted,
                  color: habit.habitColor,
                  onTap: () {
                    ref
                        .read(habitLogsProvider.notifier)
                        .toggleHabit(habit.id, date);
                    if (!isCompleted) HapticUtils.successBuzz();
                  },
                ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.05, end: 0);
  }
}
