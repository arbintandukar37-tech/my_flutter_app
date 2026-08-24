import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:habit_flow/models/habit_log.dart';

enum PatternType { warning, positive, suggestion }

class PatternInsight {
  final String message;
  final PatternType type;
  final IconData icon;

  const PatternInsight({
    required this.message,
    required this.type,
    required this.icon,
  });
}

class PatternDetector {
  static List<PatternInsight> detect(String habitName, List<HabitLog> logs) {
    final insights = <PatternInsight>[];
    if (logs.isEmpty) return insights;

    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);

    // Weekday completion analysis
    final weekdayTotals = List.filled(7, 0);
    final weekdayCompletions = List.filled(7, 0);

    for (var log in logs) {
      if (todayOnly.difference(log.dateOnly).inDays <= 56) { // Last 8 weeks
        final weekdayIndex = log.dateOnly.weekday - 1;
        weekdayTotals[weekdayIndex]++;
        if (log.completed) {
          weekdayCompletions[weekdayIndex]++;
        }
      }
    }

    for (int i = 0; i < 7; i++) {
      if (weekdayTotals[i] >= 4) { // Enough data
        final rate = weekdayCompletions[i] / weekdayTotals[i];
        final dayName = DateFormat('EEEE').format(DateTime(2023, 1, 2 + i)); // Offset to get correct weekday

        if (rate < 0.5) {
          insights.add(PatternInsight(
            message: 'You miss $habitName ${(1 - rate) * 100}% of the time on ${dayName}s — want to reschedule it?',
            type: PatternType.warning,
            icon: Icons.event_busy,
          ));
        } else if (rate > 0.9) {
          insights.add(PatternInsight(
            message: '${dayName}s are your strongest day for $habitName. Keep it up!',
            type: PatternType.positive,
            icon: Icons.star_rounded,
          ));
        }
      }
    }

    // Trend analysis
    int recentCompletions = 0;
    int previousCompletions = 0;
    
    for (var log in logs) {
      final daysAgo = todayOnly.difference(log.dateOnly).inDays;
      if (daysAgo <= 28) {
        if (log.completed) recentCompletions++;
      } else if (daysAgo <= 56) {
        if (log.completed) previousCompletions++;
      }
    }

    if (previousCompletions > 0) {
      if (recentCompletions > previousCompletions * 1.5) {
        insights.add(const PatternInsight(
          message: 'Your consistency is improving over the last 4 weeks!',
          type: PatternType.positive,
          icon: Icons.trending_up,
        ));
      } else if (recentCompletions < previousCompletions * 0.5) {
        insights.add(const PatternInsight(
          message: 'You\'ve been struggling lately. Consider reducing the frequency to build momentum.',
          type: PatternType.suggestion,
          icon: Icons.trending_down,
        ));
      }
    }

    return insights;
  }
}
