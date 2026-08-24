import 'package:flutter/material.dart';

import 'package:habit_flow/models/habit_category.dart';
import 'package:habit_flow/theme/app_colors.dart';
import 'package:habit_flow/theme/app_typography.dart';

class CategoryHeader extends StatelessWidget {
  final HabitCategory category;
  final int completedCount;
  final int totalCount;

  const CategoryHeader({
    super.key,
    required this.category,
    required this.completedCount,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    final isAllDone = totalCount > 0 && completedCount == totalCount;

    return Container(
      padding: const EdgeInsets.only(bottom: 8),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(category.emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text(
                category.label.toUpperCase(),
                style: AppTypography.label.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isAllDone ? AppColors.completedDim : AppColors.card,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$completedCount/$totalCount',
              style: AppTypography.caption.copyWith(
                color: isAllDone ? AppColors.completed : AppColors.textSecondary,
                fontWeight: isAllDone ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
