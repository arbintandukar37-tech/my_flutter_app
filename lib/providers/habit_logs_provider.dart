import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:habit_flow/models/habit_log.dart';
import 'package:habit_flow/models/habit.dart';
import 'package:habit_flow/providers/habits_provider.dart';

const _uuid = Uuid();

final habitLogsProvider = StateNotifierProvider<HabitLogsNotifier, List<HabitLog>>((ref) {
  final habits = ref.watch(habitsProvider);
  return HabitLogsNotifier(habits);
});

class HabitLogsNotifier extends StateNotifier<List<HabitLog>> {
  HabitLogsNotifier(List<Habit> demoHabits) : super(_generateMockLogs(demoHabits));

  static List<HabitLog> _generateMockLogs(List<Habit> demoHabits) {
    final logs = <HabitLog>[];
    final random = Random(42);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (final habit in demoHabits) {
      for (int i = 0; i < 90; i++) {
        final date = today.subtract(Duration(days: i));
        
        if (habit.frequency.isScheduledForDate(date)) {
          final isFriday = date.weekday == DateTime.friday;
          final isExercise = habit.name == 'Exercise';
          final completionChance = (isExercise && isFriday) ? 0.60 : 0.75;
          
          final isCompleted = random.nextDouble() < completionChance;
          final isFrozen = !isCompleted && random.nextDouble() < 0.05;
          
          if (isCompleted || isFrozen) {
            double? qty;
            if (habit.isQuantitative && isCompleted) {
              final target = habit.targetQuantity ?? 1.0;
              qty = target * (0.8 + random.nextDouble() * 0.4);
              qty = (qty * 10).roundToDouble() / 10;
            }
            
            logs.add(
              HabitLog(
                id: _uuid.v4(),
                habitId: habit.id,
                date: date,
                completed: isCompleted,
                quantity: qty,
                wasFrozen: isFrozen,
              )
            );
          }
        }
      }
    }
    return logs;
  }

  void toggleHabit(String habitId, DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    final existingIndex = state.indexWhere((l) => l.habitId == habitId && l.dateOnly == dateOnly);
    
    if (existingIndex != -1) {
      final existing = state[existingIndex];
      final updatedLogs = List<HabitLog>.from(state);
      updatedLogs[existingIndex] = existing.copyWith(completed: !existing.completed, wasFrozen: false);
      state = updatedLogs;
    } else {
      state = [
        ...state,
        HabitLog(
          id: _uuid.v4(),
          habitId: habitId,
          date: dateOnly,
          completed: true,
        )
      ];
    }
  }

  void incrementQuantity(String habitId, DateTime date, double amount) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    final existingIndex = state.indexWhere((l) => l.habitId == habitId && l.dateOnly == dateOnly);
    
    if (existingIndex != -1) {
      final existing = state[existingIndex];
      final updatedLogs = List<HabitLog>.from(state);
      updatedLogs[existingIndex] = existing.copyWith(
        quantity: (existing.quantity ?? 0.0) + amount,
        completed: true,
      );
      state = updatedLogs;
    } else {
      state = [
        ...state,
        HabitLog(
          id: _uuid.v4(),
          habitId: habitId,
          date: dateOnly,
          completed: true,
          quantity: amount,
        )
      ];
    }
  }

  void decrementQuantity(String habitId, DateTime date, double amount) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    final existingIndex = state.indexWhere((l) => l.habitId == habitId && l.dateOnly == dateOnly);
    
    if (existingIndex != -1) {
      final existing = state[existingIndex];
      final newQty = max(0.0, (existing.quantity ?? 0.0) - amount);
      final updatedLogs = List<HabitLog>.from(state);
      updatedLogs[existingIndex] = existing.copyWith(
        quantity: newQty,
        completed: newQty > 0,
      );
      state = updatedLogs;
    }
  }

  List<HabitLog> getLogsForHabit(String habitId) {
    return state.where((l) => l.habitId == habitId).toList();
  }

  List<HabitLog> getLogsForDate(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    return state.where((l) => l.dateOnly == dateOnly).toList();
  }

  bool isCompletedForDate(String habitId, DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    return state.any((l) => l.habitId == habitId && l.dateOnly == dateOnly && l.completed);
  }

  double getQuantityForDate(String habitId, DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    final log = state.where((l) => l.habitId == habitId && l.dateOnly == dateOnly).firstOrNull;
    return log?.quantity ?? 0.0;
  }
}

final todayCompletionProvider = Provider<double>((ref) {
  final habits = ref.watch(habitsProvider);
  final logs = ref.watch(habitLogsProvider);
  if (habits.isEmpty) return 0.0;

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  
  int activeCount = 0;
  int completedCount = 0;
  
  for (final habit in habits) {
    if (habit.frequency.isScheduledForDate(today)) {
      activeCount++;
      if (logs.any((l) => l.habitId == habit.id && l.dateOnly == today && l.completed)) {
        completedCount++;
      }
    }
  }
  
  return activeCount == 0 ? 0.0 : completedCount / activeCount;
});

final todayLogsProvider = Provider<List<HabitLog>>((ref) {
  final logs = ref.watch(habitLogsProvider);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  return logs.where((l) => l.dateOnly == today).toList();
});
