import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:habit_flow/models/habit.dart';
import 'package:habit_flow/models/habit_log.dart';
import 'package:habit_flow/theme/app_colors.dart';
import 'package:habit_flow/theme/app_typography.dart';
import 'package:habit_flow/providers/habits_provider.dart';
import 'package:habit_flow/providers/habit_logs_provider.dart';
import 'package:habit_flow/providers/insights_provider.dart';
import 'package:habit_flow/utils/strength_algorithm.dart';
import 'package:habit_flow/widgets/glass_card.dart';
import 'package:habit_flow/screens/insights/widgets/heatmap_calendar.dart';
import 'package:habit_flow/screens/insights/widgets/strength_gauge.dart';
import 'package:habit_flow/screens/insights/widgets/pattern_card.dart';
import 'package:habit_flow/screens/create_habit/create_habit_screen.dart';

class HabitDetailScreen extends ConsumerWidget {
  final Habit habit;

  const HabitDetailScreen({
    super.key,
    required this.habit,
  });

  String _formatQty(double qty) {
    if (qty == qty.roundToDouble()) {
      return qty.toInt().toString();
    }
    return qty.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch current habit to reflect any updates made during editing
    final habits = ref.watch(habitsProvider);
    final currentHabit = habits.where((h) => h.id == habit.id).firstOrNull ?? habit;

    final streakData = ref.watch(habitStreakProvider(currentHabit.id));
    final strength = ref.watch(habitStrengthProvider(currentHabit.id));
    final consistency = ref.watch(habitConsistencyProvider(currentHabit.id));
    final patterns = ref.watch(habitPatternsProvider(currentHabit.id));
    
    final allLogs = ref
        .watch(habitLogsProvider)
        .where((log) => log.habitId == currentHabit.id)
        .toList();
    allLogs.sort((a, b) => b.date.compareTo(a.date)); // descending
    
    final Map<DateTime, double> heatmapData = {};
    for (var log in allLogs) {
      if (log.completed) {
        heatmapData[log.dateOnly] = 1.0;
      } else if (log.wasFrozen) {
        heatmapData[log.dateOnly] = 0.5; // Represents freeze visually
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(currentHabit.name, style: AppTypography.heading2),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded, color: AppColors.textPrimary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CreateHabitScreen(habit: currentHabit),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_rounded, color: AppColors.missed),
            onPressed: () => _confirmDelete(context, ref, currentHabit),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroStats(streakData.currentStreak, strength, consistency),
            const SizedBox(height: 24),
            
            GlassCard(
              padding: const EdgeInsets.all(20.0),
              backgroundColor: AppColors.card,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Overall Strength', style: AppTypography.heading3),
                  const SizedBox(height: 16),
                  StrengthGauge(score: strength, width: double.infinity, height: 12),
                  const SizedBox(height: 8),
                  Text(
                    StrengthAlgorithm.strengthLabel(strength),
                    style: AppTypography.caption,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            Text('Activity Grid', style: AppTypography.heading3),
            const SizedBox(height: 12),
            GlassCard(
              padding: const EdgeInsets.all(16.0),
              backgroundColor: AppColors.card,
              child: HeatmapCalendar(
                data: heatmapData,
                weeksToShow: 16,
                baseColor: currentHabit.habitColor,
              ),
            ),
            const SizedBox(height: 24),

            Text('Insights', style: AppTypography.heading3),
            const SizedBox(height: 12),
            _buildPatterns(patterns, currentHabit.name),
            const SizedBox(height: 24),

            Text('Recent Activity', style: AppTypography.heading3),
            const SizedBox(height: 12),
            _buildRecentHistory(allLogs, currentHabit),
            const SizedBox(height: 48),
          ].animate(interval: 50.ms).fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0),
        ),
      ),
    );
  }

  Widget _buildHeroStats(int streak, double strength, double consistency) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: _buildStatCard('🔥', streak.toString(), 'days streak')),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('💪', strength.toInt().toString(), StrengthAlgorithm.strengthLabel(strength))),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('📈', '${(consistency * 100).toInt()}%', '30d consistency')),
      ],
    );
  }

  Widget _buildStatCard(String emoji, String main, String sub) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      backgroundColor: AppColors.card,
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          Text(main, style: AppTypography.heading2),
          const SizedBox(height: 2),
          Text(sub, style: AppTypography.caption, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildPatterns(List<dynamic> patterns, String habitName) {
    if (patterns.isEmpty) {
      return GlassCard(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            'Keep going! Insights will appear as more data is collected.',
            style: AppTypography.bodyMuted,
          ),
        ),
      );
    }
    
    return Column(
      children: patterns.map((p) => Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: PatternCard(insight: p, habitName: habitName),
      )).toList(),
    );
  }

  Widget _buildRecentHistory(List<HabitLog> logs, Habit currentHabit) {
    final recentLogs = logs.take(14).toList();
    if (recentLogs.isEmpty) {
      return GlassCard(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Text('No recent activity.', style: AppTypography.bodyMuted),
        ),
      );
    }

    return GlassCard(
      padding: const EdgeInsets.all(12.0),
      backgroundColor: AppColors.card,
      child: Column(
        children: recentLogs.map((log) {
          IconData icon;
          Color color;
          if (log.wasFrozen) {
            icon = Icons.ac_unit_rounded;
            color = AppColors.frozen;
          } else if (log.completed) {
            icon = Icons.check_circle_rounded;
            color = AppColors.completed;
          } else {
            icon = Icons.cancel_rounded;
            color = AppColors.missed;
          }

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${log.date.month}/${log.date.day}/${log.date.year}',
                  style: AppTypography.bodyMedium,
                ),
                Row(
                  children: [
                    if (currentHabit.isQuantitative && log.completed && log.quantity != null) ...[
                      Text(
                        '${_formatQty(log.quantity!)} ${currentHabit.unit ?? ''}',
                        style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Icon(icon, color: color, size: 20),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Habit currentHabit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete Habit?', style: AppTypography.heading3),
        content: Text(
          'Are you sure you want to delete "${currentHabit.name}"? This will also remove all its history.',
          style: AppTypography.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              ref.read(habitsProvider.notifier).removeHabit(currentHabit.id);
              Navigator.pop(context); // Pop dialog
              Navigator.pop(context); // Pop back to previous screen
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.missed)),
          ),
        ],
      ),
    );
  }
}
