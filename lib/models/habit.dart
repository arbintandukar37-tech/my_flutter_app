import 'package:flutter/material.dart';
import 'package:habit_flow/models/habit_category.dart';
import 'package:habit_flow/models/habit_frequency.dart';
import 'package:habit_flow/models/habit_type.dart';

class Habit {
  final String id;
  final String name;
  final int iconCodePoint;
  final int color;
  final HabitType type;
  final HabitFrequency frequency;
  final bool isQuantitative;
  final double? targetQuantity;
  final String? unit;
  final HabitCategory category;
  final int streakFreezes;
  final DateTime createdAt;

  const Habit({
    required this.id,
    required this.name,
    required this.iconCodePoint,
    required this.color,
    required this.type,
    required this.frequency,
    this.isQuantitative = false,
    this.targetQuantity,
    this.unit,
    required this.category,
    this.streakFreezes = 1,
    required this.createdAt,
  });

  static const List<IconData> availableIcons = [
    Icons.self_improvement,
    Icons.water_drop,
    Icons.fitness_center,
    Icons.menu_book,
    Icons.edit_note,
    Icons.bedtime,
    Icons.restaurant,
    Icons.directions_run,
    Icons.music_note,
    Icons.code,
    Icons.school,
    Icons.phone_android,
    Icons.smoke_free,
    Icons.local_drink,
    Icons.pets,
    Icons.cleaning_services,
    Icons.savings,
    Icons.favorite,
    Icons.psychology,
    Icons.nature_people,
    Icons.language,
    Icons.brush,
    Icons.camera_alt,
    Icons.piano,
    Icons.medication,
    Icons.star,
  ];

  IconData get iconData {
    for (final icon in availableIcons) {
      if (icon.codePoint == iconCodePoint) return icon;
    }
    return Icons.star;
  }
  Color get habitColor => Color(color);

  Habit copyWith({
    String? id,
    String? name,
    int? iconCodePoint,
    int? color,
    HabitType? type,
    HabitFrequency? frequency,
    bool? isQuantitative,
    double? targetQuantity,
    String? unit,
    HabitCategory? category,
    int? streakFreezes,
    DateTime? createdAt,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      color: color ?? this.color,
      type: type ?? this.type,
      frequency: frequency ?? this.frequency,
      isQuantitative: isQuantitative ?? this.isQuantitative,
      targetQuantity: targetQuantity ?? this.targetQuantity,
      unit: unit ?? this.unit,
      category: category ?? this.category,
      streakFreezes: streakFreezes ?? this.streakFreezes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
