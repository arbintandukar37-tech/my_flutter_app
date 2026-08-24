enum FrequencyType {
  daily('Daily', 'Every day'),
  specificDays('Specific Days', 'On selected days'),
  timesPerWeek('Times Per Week', 'Flexible days per week'),
  rollingInterval('Rolling Interval', 'Every X days');

  final String label;
  final String description;

  const FrequencyType(this.label, this.description);
}

class HabitFrequency {
  final FrequencyType type;
  final List<int>? specificDays;
  final int? timesPerWeek;
  final int? intervalDays;

  const HabitFrequency({
    required this.type,
    this.specificDays,
    this.timesPerWeek,
    this.intervalDays,
  });

  String get displayText {
    switch (type) {
      case FrequencyType.daily:
        return 'Every day';
      case FrequencyType.specificDays:
        if (specificDays == null || specificDays!.isEmpty) return 'No days selected';
        const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        return specificDays!.map((d) => days[d - 1]).join(', ');
      case FrequencyType.timesPerWeek:
        return '${timesPerWeek ?? 1} times a week';
      case FrequencyType.rollingInterval:
        return 'Every ${intervalDays ?? 1} days';
    }
  }

  bool isScheduledForDate(DateTime date) {
    switch (type) {
      case FrequencyType.daily:
        return true;
      case FrequencyType.specificDays:
        return specificDays?.contains(date.weekday) ?? false;
      case FrequencyType.timesPerWeek:
        // Flexible completion, assumes always valid to attempt
        return true;
      case FrequencyType.rollingInterval:
        // Would properly require a start date to calculate interval
        return true;
    }
  }
}
