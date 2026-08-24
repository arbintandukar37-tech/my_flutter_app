enum HabitCategory {
  morning('Morning Routine', '🌅', 0),
  deepWork('Deep Work', '💻', 1),
  evening('Evening Wind-Down', '🌙', 2);

  const HabitCategory(this.label, this.emoji, this.sortOrder);
  final String label;
  final String emoji;
  final int sortOrder;
}
