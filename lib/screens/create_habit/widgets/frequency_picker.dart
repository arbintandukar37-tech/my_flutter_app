import 'package:flutter/material.dart';
import 'package:habit_flow/models/habit_frequency.dart';
import 'package:habit_flow/theme/app_colors.dart';
import 'package:habit_flow/theme/app_typography.dart';
import 'package:habit_flow/widgets/glass_card.dart';
import 'package:habit_flow/utils/haptic_utils.dart';

class FrequencyPicker extends StatefulWidget {
  final HabitFrequency? initialFrequency;
  final ValueChanged<HabitFrequency> onFrequencyChanged;

  const FrequencyPicker({
    super.key,
    this.initialFrequency,
    required this.onFrequencyChanged,
  });

  @override
  State<FrequencyPicker> createState() => _FrequencyPickerState();
}

class _FrequencyPickerState extends State<FrequencyPicker> {
  late FrequencyType _selectedType;
  late List<int> _specificDays;
  late int _timesPerWeek;
  late int _intervalDays;

  final List<String> _dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  void initState() {
    super.initState();
    final initial = widget.initialFrequency ?? const HabitFrequency(type: FrequencyType.daily);
    _selectedType = initial.type;
    _specificDays = initial.specificDays != null ? List.from(initial.specificDays!) : [1, 2, 3, 4, 5]; // Default M-F
    _timesPerWeek = initial.timesPerWeek ?? 3;
    _intervalDays = initial.intervalDays ?? 2;
  }

  void _notifyChange() {
    final freq = HabitFrequency(
      type: _selectedType,
      specificDays: _selectedType == FrequencyType.specificDays ? _specificDays : null,
      timesPerWeek: _selectedType == FrequencyType.timesPerWeek ? _timesPerWeek : null,
      intervalDays: _selectedType == FrequencyType.rollingInterval ? _intervalDays : null,
    );
    widget.onFrequencyChanged(freq);
  }

  Widget _buildSpecificDaysSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(7, (index) {
        final dayValue = index + 1; // 1-7 (Mon-Sun)
        final isSelected = _specificDays.contains(dayValue);
        
        return GestureDetector(
          onTap: () {
            HapticUtils.lightTap();
            setState(() {
              if (isSelected && _specificDays.length > 1) {
                _specificDays.remove(dayValue);
              } else if (!isSelected) {
                _specificDays.add(dayValue);
              }
            });
            _notifyChange();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? AppColors.accent : AppColors.cardHover,
            ),
            child: Center(
              child: Text(
                _dayLabels[index],
                style: AppTypography.bodyMedium.copyWith(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildNumberPicker(int value, int min, int max, String label, ValueChanged<int> onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: value > min ? () {
            HapticUtils.lightTap();
            onChanged(value - 1);
          } : null,
          icon: const Icon(Icons.remove_circle_outline),
          color: AppColors.accent,
        ),
        const SizedBox(width: 16),
        Text(
          '$value $label',
          style: AppTypography.heading2,
        ),
        const SizedBox(width: 16),
        IconButton(
          onPressed: value < max ? () {
            HapticUtils.lightTap();
            onChanged(value + 1);
          } : null,
          icon: const Icon(Icons.add_circle_outline),
          color: AppColors.accent,
        ),
      ],
    );
  }

  Widget _buildOptionCard({
    required FrequencyType type,
    required String title,
    required String description,
    required IconData icon,
    Widget? expandedContent,
  }) {
    final isSelected = _selectedType == type;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: GlassCard(
        backgroundColor: isSelected ? AppColors.cardHover : AppColors.card,
        padding: const EdgeInsets.all(16),
        onTap: () {
          if (!isSelected) {
            HapticUtils.lightTap();
            setState(() {
              _selectedType = type;
            });
            _notifyChange();
          }
        },
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, color: isSelected ? AppColors.accent : AppColors.textSecondary),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary)),
                      Text(description, style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
                    ],
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.check_circle, color: AppColors.accent),
              ],
            ),
            if (isSelected && expandedContent != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: expandedContent,
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildOptionCard(
          type: FrequencyType.daily,
          title: 'Every Day',
          description: 'Do this every single day',
          icon: Icons.all_inclusive,
        ),
        _buildOptionCard(
          type: FrequencyType.specificDays,
          title: 'Specific Days',
          description: 'Choose days of the week',
          icon: Icons.calendar_today,
          expandedContent: _buildSpecificDaysSelector(),
        ),
        _buildOptionCard(
          type: FrequencyType.timesPerWeek,
          title: 'Times Per Week',
          description: 'Flexible goal for the week',
          icon: Icons.view_week,
          expandedContent: _buildNumberPicker(
            _timesPerWeek,
            1,
            7,
            'times / week',
            (val) {
              setState(() => _timesPerWeek = val);
              _notifyChange();
            },
          ),
        ),
        _buildOptionCard(
          type: FrequencyType.rollingInterval,
          title: 'Every N Days',
          description: 'E.g., Every 3 days',
          icon: Icons.loop,
          expandedContent: _buildNumberPicker(
            _intervalDays,
            2,
            30,
            'days',
            (val) {
              setState(() => _intervalDays = val);
              _notifyChange();
            },
          ),
        ),
      ],
    );
  }
}
