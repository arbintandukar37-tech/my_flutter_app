enum HabitType {
  good('Build', '💪'),
  bad('Quit', '🚫');

  const HabitType(this.label, this.emoji);
  final String label;
  final String emoji;
}
