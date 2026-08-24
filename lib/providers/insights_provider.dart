import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_flow/utils/streak_calculator.dart';
import 'package:habit_flow/utils/strength_algorithm.dart';
import 'package:habit_flow/utils/pattern_detector.dart';
import 'package:habit_flow/providers/habits_provider.dart';
import 'package:habit_flow/providers/habit_logs_provider.dart';

class OverallStats {
  final int totalHabits;
  final int activeToday;
  final int completedToday;
  final double overallConsistency;
  final String strongestHabit;
  final List<double> weeklyCompletionRates;

  OverallStats({
    required this.totalHabits,
    required this.activeToday,
    required this.completedToday,
    required this.overallConsistency,
    required this.strongestHabit,
    required this.weeklyCompletionRates,
  });
}

final habitStrengthProvider = Provider.family<double, String>((ref, habitId) {
  final logs = ref.watch(habitLogsProvider.notifier).getLogsForHabit(habitId);
  final habits = ref.watch(habitsProvider);
  final habit = habits.firstWhere((h) => h.id == habitId);
  return StrengthAlgorithm.calculate(logs, habit.createdAt);
});

final habitStreakProvider = Provider.family<StreakResult, String>((ref, habitId) {
  final logs = ref.watch(habitLogsProvider.notifier).getLogsForHabit(habitId);
  final habits = ref.watch(habitsProvider);
  final habit = habits.firstWhere((h) => h.id == habitId);
  return StreakCalculator.calculateStreak(logs, habit.frequency, freezesPerWeek: habit.streakFreezes);
});

final habitConsistencyProvider = Provider.family<double, String>((ref, habitId) {
  final logs = ref.watch(habitLogsProvider.notifier).getLogsForHabit(habitId);
  final habits = ref.watch(habitsProvider);
  final habit = habits.firstWhere((h) => h.id == habitId);
  return StreakCalculator.calculateConsistency(logs, habit.frequency, 30);
});

final habitPatternsProvider = Provider.family<List<PatternInsight>, String>((ref, habitId) {
  final logs = ref.watch(habitLogsProvider.notifier).getLogsForHabit(habitId);
  final habits = ref.watch(habitsProvider);
  final habit = habits.firstWhere((h) => h.id == habitId);
  return PatternDetector.detect(habit.name, logs);
});

final overallStatsProvider = Provider<OverallStats>((ref) {
  final habits = ref.watch(habitsProvider);
  final logs = ref.watch(habitLogsProvider);
  
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  
  int activeToday = 0;
  int completedToday = 0;
  double totalConsistency = 0.0;
  
  String strongestHabit = 'None';
  double maxStrength = -1.0;
  
  for (final habit in habits) {
    if (habit.frequency.isScheduledForDate(today)) {
      activeToday++;
      if (logs.any((l) => l.habitId == habit.id && l.dateOnly == today && l.completed)) {
        completedToday++;
      }
    }
    
    final habitLogs = logs.where((l) => l.habitId == habit.id).toList();
    totalConsistency += StreakCalculator.calculateConsistency(habitLogs, habit.frequency, 30);
    
    final strength = StrengthAlgorithm.calculate(habitLogs, habit.createdAt);
    if (strength > maxStrength) {
      maxStrength = strength;
      strongestHabit = '${habit.name} (${strength.toStringAsFixed(1)})';
    }
  }
  
  final overallConsistency = habits.isEmpty ? 0.0 : totalConsistency / habits.length;
  
  final weeklyRates = <double>[];
  for (int w = 0; w < 8; w++) {
    int weekActive = 0;
    int weekComplete = 0;
    for (int d = 0; d < 7; d++) {
      final date = today.subtract(Duration(days: w * 7 + d));
      for (final habit in habits) {
        if (habit.frequency.isScheduledForDate(date)) {
          weekActive++;
          if (logs.any((l) => l.habitId == habit.id && l.dateOnly == date && l.completed)) {
            weekComplete++;
          }
        }
      }
    }
    weeklyRates.add(weekActive == 0 ? 0.0 : weekComplete / weekActive);
  }
  
  return OverallStats(
    totalHabits: habits.length,
    activeToday: activeToday,
    completedToday: completedToday,
    overallConsistency: overallConsistency,
    strongestHabit: strongestHabit,
    weeklyCompletionRates: weeklyRates.reversed.toList(),
  );
});
