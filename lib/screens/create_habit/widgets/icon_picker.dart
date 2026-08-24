import 'package:flutter/material.dart';
import 'package:habit_flow/theme/app_colors.dart';
import 'package:habit_flow/utils/haptic_utils.dart';

class IconPicker extends StatefulWidget {
  final int? selectedIconCodePoint;
  final ValueChanged<int> onIconSelected;

  const IconPicker({
    super.key,
    this.selectedIconCodePoint,
    required this.onIconSelected,
  });

  @override
  State<IconPicker> createState() => _IconPickerState();
}

class _IconPickerState extends State<IconPicker> {
  final List<IconData> _icons = [
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
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      itemCount: _icons.length,
      itemBuilder: (context, index) {
        final icon = _icons[index];
        final isSelected = icon.codePoint == widget.selectedIconCodePoint;

        return GestureDetector(
          onTap: () {
            HapticUtils.lightTap();
            widget.onIconSelected(icon.codePoint);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? AppColors.accent : AppColors.card,
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.white : AppColors.textSecondary,
              size: 24,
            ),
          ),
        );
      },
    );
  }
}
