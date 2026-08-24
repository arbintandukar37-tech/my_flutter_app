import 'package:flutter/material.dart';
import 'package:habit_flow/models/habit_category.dart';
import 'package:habit_flow/theme/app_colors.dart';
import 'package:habit_flow/theme/app_typography.dart';
import 'package:habit_flow/widgets/glass_card.dart';
import 'package:habit_flow/utils/haptic_utils.dart';

class CategorySelector extends StatelessWidget {
  final HabitCategory? selectedCategory;
  final ValueChanged<HabitCategory> onCategorySelected;
  final int? selectedColor;
  final ValueChanged<int> onColorSelected;

  const CategorySelector({
    super.key,
    this.selectedCategory,
    required this.onCategorySelected,
    this.selectedColor,
    required this.onColorSelected,
  });

  final List<int> _colors = const [
    0xFF00E676, // green
    0xFF40C4FF, // blue
    0xFFFFBE0B, // amber
    0xFFFF5252, // red
    0xFFFF9100, // orange
    0xFF7C4DFF, // purple
    0xFFFF4081, // pink
    0xFF00BFA5, // teal
    0xFFFFEA00, // yellow
    0xFF8D6E63, // brown
  ];

  String _getCategoryDescription(HabitCategory category) {
    switch (category) {
      case HabitCategory.morning:
        return 'Start your day right';
      case HabitCategory.deepWork:
        return 'Peak productivity hours';
      case HabitCategory.evening:
        return 'Wind down and reflect';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Category', style: AppTypography.heading3),
        const SizedBox(height: 16),
        ...HabitCategory.values.map((category) {
          final isSelected = selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: GlassCard(
              backgroundColor: isSelected ? AppColors.accent.withValues(alpha: 0.1) : AppColors.card,
              padding: const EdgeInsets.all(16),
              onTap: () {
                HapticUtils.lightTap();
                onCategorySelected(category);
              },
              child: Row(
                children: [
                  Text(category.emoji, style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(category.label, style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary)),
                        Text(_getCategoryDescription(category), style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                  if (isSelected)
                    const Icon(Icons.check_circle, color: AppColors.accent),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 32),
        Text('Color', style: AppTypography.heading3),
        const SizedBox(height: 16),
        SizedBox(
          height: 60,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _colors.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final colorValue = _colors[index];
              final isSelected = colorValue == selectedColor;
              return GestureDetector(
                onTap: () {
                  HapticUtils.lightTap();
                  onColorSelected(colorValue);
                },
                child: AnimatedScale(
                  scale: isSelected ? 1.1 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Color(colorValue),
                      shape: BoxShape.circle,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white)
                        : null,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
