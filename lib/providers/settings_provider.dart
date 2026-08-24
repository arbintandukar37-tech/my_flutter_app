import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_flow/models/habit_category.dart';

class AppSettings {
  final int defaultFreezesPerWeek;
  final HabitCategory defaultCategory;
  final bool showCompletedHabits;
  final bool hapticEnabled;

  AppSettings({
    this.defaultFreezesPerWeek = 1,
    this.defaultCategory = HabitCategory.morning,
    this.showCompletedHabits = true,
    this.hapticEnabled = true,
  });

  AppSettings copyWith({
    int? defaultFreezesPerWeek,
    HabitCategory? defaultCategory,
    bool? showCompletedHabits,
    bool? hapticEnabled,
  }) {
    return AppSettings(
      defaultFreezesPerWeek: defaultFreezesPerWeek ?? this.defaultFreezesPerWeek,
      defaultCategory: defaultCategory ?? this.defaultCategory,
      showCompletedHabits: showCompletedHabits ?? this.showCompletedHabits,
      hapticEnabled: hapticEnabled ?? this.hapticEnabled,
    );
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier();
});

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(AppSettings());

  void updateFreezes(int freezes) {
    state = state.copyWith(defaultFreezesPerWeek: freezes);
  }

  void updateCategory(HabitCategory category) {
    state = state.copyWith(defaultCategory: category);
  }

  void toggleShowCompleted(bool show) {
    state = state.copyWith(showCompletedHabits: show);
  }

  void toggleHaptic(bool enabled) {
    state = state.copyWith(hapticEnabled: enabled);
  }
}
