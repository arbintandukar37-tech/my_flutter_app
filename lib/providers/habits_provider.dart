import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:habit_flow/models/habit.dart';
import 'package:habit_flow/models/habit_type.dart';
import 'package:habit_flow/models/habit_category.dart';
import 'package:habit_flow/models/habit_frequency.dart';

const _uuid = Uuid();

final habitsProvider = StateNotifierProvider<HabitsNotifier, List<Habit>>((ref) {
  return HabitsNotifier();
});

class HabitsNotifier extends StateNotifier<List<Habit>> {
  HabitsNotifier() : super(_generateDemoHabits());

  static List<Habit> _generateDemoHabits() {
    final now = DateTime.now();
    final createdAt = now.subtract(const Duration(days: 90));
    return [
      Habit(
        id: _uuid.v4(),
        name: 'Meditate',
        iconCodePoint: Icons.self_improvement.codePoint,
        color: Colors.green.value,
        type: HabitType.good,
        frequency: const HabitFrequency(type: FrequencyType.daily),
        isQuantitative: false,
        category: HabitCategory.morning,
        createdAt: createdAt,
      ),
      Habit(
        id: _uuid.v4(),
        name: 'Drink 2L Water',
        iconCodePoint: Icons.water_drop.codePoint,
        color: Colors.blue.value,
        type: HabitType.good,
        frequency: const HabitFrequency(type: FrequencyType.daily),
        isQuantitative: true,
        targetQuantity: 2000,
        unit: 'ml',
        category: HabitCategory.morning,
        createdAt: createdAt,
      ),
      Habit(
        id: _uuid.v4(),
        name: 'Read',
        iconCodePoint: Icons.menu_book.codePoint,
        color: Colors.amber.value,
        type: HabitType.good,
        frequency: const HabitFrequency(type: FrequencyType.daily),
        isQuantitative: true,
        targetQuantity: 30,
        unit: 'pages',
        category: HabitCategory.deepWork,
        createdAt: createdAt,
      ),
      Habit(
        id: _uuid.v4(),
        name: 'Exercise',
        iconCodePoint: Icons.fitness_center.codePoint,
        color: Colors.orange.value,
        type: HabitType.good,
        frequency: const HabitFrequency(type: FrequencyType.specificDays, specificDays: [1, 3, 5]),
        isQuantitative: false,
        category: HabitCategory.deepWork,
        createdAt: createdAt,
      ),
      Habit(
        id: _uuid.v4(),
        name: 'Journal',
        iconCodePoint: Icons.edit_note.codePoint,
        color: Colors.purple.value,
        type: HabitType.good,
        frequency: const HabitFrequency(type: FrequencyType.daily),
        isQuantitative: false,
        category: HabitCategory.evening,
        createdAt: createdAt,
      ),
      Habit(
        id: _uuid.v4(),
        name: 'No Social Media',
        iconCodePoint: Icons.phone_android.codePoint,
        color: Colors.red.value,
        type: HabitType.bad,
        frequency: const HabitFrequency(type: FrequencyType.daily),
        isQuantitative: false,
        category: HabitCategory.deepWork,
        createdAt: createdAt,
      ),
      Habit(
        id: _uuid.v4(),
        name: 'Sleep by 11 PM',
        iconCodePoint: Icons.bedtime.codePoint,
        color: Colors.indigo.value,
        type: HabitType.good,
        frequency: const HabitFrequency(type: FrequencyType.daily),
        isQuantitative: false,
        category: HabitCategory.evening,
        createdAt: createdAt,
      ),
      Habit(
        id: _uuid.v4(),
        name: 'Study',
        iconCodePoint: Icons.school.codePoint,
        color: Colors.teal.value,
        type: HabitType.good,
        frequency: const HabitFrequency(type: FrequencyType.timesPerWeek, timesPerWeek: 5),
        isQuantitative: true,
        targetQuantity: 60,
        unit: 'min',
        category: HabitCategory.deepWork,
        createdAt: createdAt,
      ),
    ];
  }

  void addHabit(Habit habit) {
    state = [...state, habit];
  }

  void removeHabit(String id) {
    state = state.where((h) => h.id != id).toList();
  }

  void updateHabit(Habit updated) {
    state = [
      for (final h in state)
        if (h.id == updated.id) updated else h
    ];
  }
}
