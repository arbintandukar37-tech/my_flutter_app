import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:habit_flow/models/habit.dart';
import 'package:habit_flow/theme/app_colors.dart';
import 'package:habit_flow/theme/app_typography.dart';
import 'package:habit_flow/providers/habits_provider.dart';
import 'package:habit_flow/providers/habit_logs_provider.dart';
import 'package:habit_flow/providers/insights_provider.dart';
import 'package:habit_flow/widgets/glass_card.dart';
import 'package:habit_flow/screens/insights/widgets/heatmap_calendar.dart';
import 'package:habit_flow/screens/insights/widgets/strength_gauge.dart';
import 'package:habit_flow/screens/insights/widgets/consistency_chart.dart';
import 'package:habit_flow/screens/insights/widgets/pattern_card.dart';
import 'package:habit_flow/screens/habit_detail/habit_detail_screen.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overallStats = ref.watch(overallStatsProvider);
    final habits = ref.watch(habitsProvider);

    // Sort habits by strength
    final sortedHabits = List<Habit>.from(habits)..sort((a, b) {
      final strengthA = ref.watch(habitStrengthProvider(a.id));
      final strengthB = ref.watch(habitStrengthProvider(b.id));
      return strengthB.compareTo(strengthA);
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Insights', style: AppTypography.heading2),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOverallStatsCard(overallStats),
            const SizedBox(height: 24),
            
            Text('Weekly Trend', style: AppTypography.heading3),
            const SizedBox(height: 4),
            Text('Last 8 weeks completion rates', style: AppTypography.caption),
            const SizedBox(height: 12),
            ConsistencyChart(weeklyRates: overallStats.weeklyCompletionRates),
            const SizedBox(height: 24),
            
            Text('Habit Strength', style: AppTypography.heading3),
            const SizedBox(height: 12),
            _buildStrengthLeaderboard(context, ref, sortedHabits),
            const SizedBox(height: 24),

            if (habits.isNotEmpty) ...[
              Text('Insights & Patterns', style: AppTypography.heading3),
              const SizedBox(height: 12),
              _buildTopPatterns(ref, habits),
              const SizedBox(height: 24),
            ],

            Text('Activity Overview', style: AppTypography.heading3),
            const SizedBox(height: 12),
            _buildHeatmapPreview(ref, habits),
            const SizedBox(height: 48),
          ].animate(interval: 50.ms).fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0),
        ),
      ),
    );
  }

  Widget _buildOverallStatsCard(dynamic overallStats) {
    Color consistencyColor = AppColors.missed;
    if (overallStats.overallConsistency > 0.7) {
      consistencyColor = AppColors.completed;
    } else if (overallStats.overallConsistency >= 0.4) {
      consistencyColor = AppColors.accent;
    }

    return GlassCard(
      padding: const EdgeInsets.all(24.0),
      backgroundColor: AppColors.card,
      borderRadius: BorderRadius.circular(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            value: overallStats.activeToday.toString(),
            label: 'Active Today',
            valueColor: AppColors.textPrimary,
          ),
          _buildStatItem(
            value: overallStats.completedToday.toString(),
            label: 'Completed',
            valueColor: AppColors.completed,
          ),
          _buildStatItem(
            value: '${(overallStats.overallConsistency * 100).toInt()}%',
            label: 'Consistency',
            valueColor: consistencyColor,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({required String value, required String label, required Color valueColor}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: AppTypography.heading2.copyWith(color: valueColor)),
        const SizedBox(height: 4),
        Text(label, style: AppTypography.caption),
      ],
    );
  }

  Widget _buildStrengthLeaderboard(BuildContext context, WidgetRef ref, List<Habit> habits) {
    if (habits.isEmpty) {
      return Text('No habits yet.', style: AppTypography.bodyMuted);
    }

    return Column(
      children: habits.map((habit) {
        final strength = ref.watch(habitStrengthProvider(habit.id));
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            backgroundColor: AppColors.card,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HabitDetailScreen(habit: habit),
                ),
              );
            },
            child: Row(
              children: [
                Icon(habit.iconData, color: habit.habitColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    habit.name,
                    style: AppTypography.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                StrengthGauge(score: strength, width: 80),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTopPatterns(WidgetRef ref, List<Habit> habits) {
    final allPatterns = <Widget>[];
    
    for (final habit in habits) {
      final patterns = ref.watch(habitPatternsProvider(habit.id));
      for (final pattern in patterns) {
        allPatterns.add(Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: PatternCard(insight: pattern, habitName: habit.name),
        ));
      }
    }

    if (allPatterns.isEmpty) {
      return Text('No significant patterns detected yet.', style: AppTypography.bodyMuted);
    }

    return Column(
      children: allPatterns.take(5).toList(),
    );
  }

  Widget _buildHeatmapPreview(WidgetRef ref, List<Habit> habits) {
    final logs = ref.watch(habitLogsProvider);
    final Map<DateTime, double> aggregateData = {};
    
    if (habits.isNotEmpty) {
      final completedCounts = <DateTime, int>{};
      for (final log in logs) {
        if (log.completed) {
          completedCounts[log.dateOnly] = (completedCounts[log.dateOnly] ?? 0) + 1;
        }
      }
      for (final entry in completedCounts.entries) {
        aggregateData[entry.key] = (entry.value / habits.length).clamp(0.0, 1.0);
      }
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlassCard(
          padding: const EdgeInsets.all(16.0),
          backgroundColor: AppColors.card,
          child: HeatmapCalendar(
            data: aggregateData,
            weeksToShow: 16,
            baseColor: AppColors.completed,
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            'Tap a habit above for detailed individual heatmap',
            style: AppTypography.caption.copyWith(fontStyle: FontStyle.italic),
          ),
        ),
      ],
    );
  }
}
