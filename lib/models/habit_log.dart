class HabitLog {
  final String id;
  final String habitId;
  final DateTime date;
  final bool completed;
  final double? quantity;
  final bool wasFrozen;

  const HabitLog({
    required this.id,
    required this.habitId,
    required this.date,
    required this.completed,
    this.quantity,
    this.wasFrozen = false,
  });

  DateTime get dateOnly => DateTime(date.year, date.month, date.day);

  HabitLog copyWith({
    String? id,
    String? habitId,
    DateTime? date,
    bool? completed,
    double? quantity,
    bool? wasFrozen,
  }) {
    return HabitLog(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      date: date ?? this.date,
      completed: completed ?? this.completed,
      quantity: quantity ?? this.quantity,
      wasFrozen: wasFrozen ?? this.wasFrozen,
    );
  }
}
