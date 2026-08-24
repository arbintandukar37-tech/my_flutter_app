import 'dart:math';
import 'package:flutter/material.dart';
import 'package:habit_flow/models/habit_log.dart';
import 'package:habit_flow/theme/app_colors.dart';

class StrengthAlgorithm {
  static double calculate(List<HabitLog> logs, DateTime createdAt) {
    if (logs.isEmpty) return 0.0;

    final sortedLogs = logs.toList()..sort((a, b) => b.dateOnly.compareTo(a.dateOnly));
    final lastLog = sortedLogs.firstWhere((l) => l.completed, orElse: () => sortedLogs.first);
    
    final DateTime today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);

    double recency = 0;
    if (lastLog.completed) {
      final daysSinceLastCompletion = todayOnly.difference(lastLog.dateOnly).inDays;
      recency = max(0.0, (100 * pow(0.9, daysSinceLastCompletion)).toDouble());
    }

    int completedInLast30 = 0;
    for (int i = 0; i < 30; i++) {
      final date = todayOnly.subtract(Duration(days: i));
      final log = logs.where((l) => l.dateOnly.isAtSameMomentAs(date)).firstOrNull;
      if (log != null && log.completed) {
        completedInLast30++;
      }
    }
    double consistency = (completedInLast30 / 30.0) * 100;

    final totalDaysTracked = todayOnly.difference(DateTime(createdAt.year, createdAt.month, createdAt.day)).inDays;
    double duration = min(100.0, (log(totalDaysTracked + 1) / ln10) / (log(365) / ln10) * 100);

    return (0.4 * recency) + (0.35 * consistency) + (0.25 * duration);
  }

  static String strengthLabel(double score) {
    if (score < 20) return 'Fragile';
    if (score < 40) return 'Forming';
    if (score < 60) return 'Developing';
    if (score < 80) return 'Strong';
    return 'Automatic';
  }

  static Color strengthColor(double score) {
    if (score < 20) return AppColors.missed;
    if (score < 40) return AppColors.badHabit;
    if (score < 60) return AppColors.accent;
    if (score < 80) return Colors.lightGreen;
    return AppColors.completed;
  }
}
