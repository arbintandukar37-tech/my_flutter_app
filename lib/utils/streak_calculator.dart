import 'package:habit_flow/models/habit_frequency.dart';
import 'package:habit_flow/models/habit_log.dart';

class StreakResult {
  final int currentStreak;
  final int longestStreak;
  final int freezesUsed;
  final int freezesRemaining;

  const StreakResult({
    required this.currentStreak,
    required this.longestStreak,
    required this.freezesUsed,
    required this.freezesRemaining,
  });
}

class StreakCalculator {
  static StreakResult calculateStreak(
    List<HabitLog> logs,
    HabitFrequency frequency, {
    int freezesPerWeek = 1,
  }) {
    int current = 0;
    int longest = 0;
    int freezesUsed = 0;
    int freezesRemaining = freezesPerWeek;

    if (logs.isEmpty) {
      return StreakResult(
        currentStreak: 0,
        longestStreak: 0,
        freezesUsed: 0,
        freezesRemaining: freezesPerWeek,
      );
    }

    final sortedLogs = logs.toList()..sort((a, b) => b.dateOnly.compareTo(a.dateOnly));
    final DateTime today = DateTime.now();
    final DateTime todayOnly = DateTime(today.year, today.month, today.day);

    DateTime? previousDate;
    bool streakBroken = false;
    int rollingMisses = 0;

    for (var log in sortedLogs) {
      if (!frequency.isScheduledForDate(log.dateOnly)) {
        continue;
      }

      if (previousDate != null) {
        int diff = previousDate.difference(log.dateOnly).inDays;
        if (diff > 1 && !streakBroken) {
          int missingScheduledDays = 0;
          for (int i = 1; i < diff; i++) {
            final checkDate = log.dateOnly.add(Duration(days: i));
            if (frequency.isScheduledForDate(checkDate)) {
              missingScheduledDays++;
            }
          }

          if (missingScheduledDays > freezesRemaining) {
            streakBroken = true;
          } else {
            freezesRemaining -= missingScheduledDays;
            freezesUsed += missingScheduledDays;
          }
        }
      }

      if (log.completed && !streakBroken) {
        current++;
      } else if (!log.completed && !streakBroken && !log.wasFrozen) {
        if (freezesRemaining > 0) {
          freezesRemaining--;
          freezesUsed++;
        } else {
          streakBroken = true;
        }
      }
      
      previousDate = log.dateOnly;
    }
    
    // Simplified longest streak logic for the example
    longest = current > longest ? current : longest;

    return StreakResult(
      currentStreak: current,
      longestStreak: longest,
      freezesUsed: freezesUsed,
      freezesRemaining: freezesRemaining,
    );
  }

  static double calculateConsistency(List<HabitLog> logs, HabitFrequency frequency, int days) {
    if (logs.isEmpty) return 0.0;
    
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    
    int scheduledDays = 0;
    int completedDays = 0;

    for (int i = 0; i < days; i++) {
      final date = todayOnly.subtract(Duration(days: i));
      if (frequency.isScheduledForDate(date)) {
        scheduledDays++;
        final log = logs.where((l) => l.dateOnly.isAtSameMomentAs(date)).firstOrNull;
        if (log != null && log.completed) {
          completedDays++;
        }
      }
    }

    if (scheduledDays == 0) return 0.0;
    return completedDays / scheduledDays;
  }
}
