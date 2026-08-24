import 'package:flutter/material.dart';
import 'package:habit_flow/theme/app_colors.dart';
import 'package:habit_flow/theme/app_typography.dart';
import 'package:habit_flow/widgets/glass_card.dart';
import 'package:habit_flow/utils/haptic_utils.dart';

class TargetConfig extends StatefulWidget {
  final bool isQuantitative;
  final double? targetQuantity;
  final String? unit;
  final ValueChanged<bool> onTypeChanged;
  final ValueChanged<double> onTargetChanged;
  final ValueChanged<String> onUnitChanged;

  const TargetConfig({
    super.key,
    required this.isQuantitative,
    this.targetQuantity,
    this.unit,
    required this.onTypeChanged,
    required this.onTargetChanged,
    required this.onUnitChanged,
  });

  @override
  State<TargetConfig> createState() => _TargetConfigState();
}

class _TargetConfigState extends State<TargetConfig> {
  final List<String> _commonUnits = ['min', 'pages', 'ml', 'km', 'reps', 'cal', 'hrs'];
  bool _isCustomUnit = false;
  final TextEditingController _customUnitController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.unit != null && !_commonUnits.contains(widget.unit)) {
      _isCustomUnit = true;
      _customUnitController.text = widget.unit!;
    }
  }

  @override
  void dispose() {
    _customUnitController.dispose();
    super.dispose();
  }

  void _increment() {
    HapticUtils.lightTap();
    double current = widget.targetQuantity ?? 1.0;
    double step = current >= 100 ? 10.0 : (current >= 10 ? 5.0 : 1.0);
    widget.onTargetChanged(current + step);
  }

  void _decrement() {
    HapticUtils.lightTap();
    double current = widget.targetQuantity ?? 1.0;
    double step = current > 100 ? 10.0 : (current > 10 ? 5.0 : 1.0);
    if (current - step > 0) {
      widget.onTargetChanged(current - step);
    } else {
      widget.onTargetChanged(1.0);
    }
  }

  Widget _buildTypeToggle() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              HapticUtils.lightTap();
              widget.onTypeChanged(false);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: !widget.isQuantitative ? AppColors.accent : AppColors.card,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Center(
                child: Text(
                  'Just do it',
                  style: AppTypography.bodyMedium.copyWith(
                    color: !widget.isQuantitative ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: GestureDetector(
            onTap: () {
              HapticUtils.lightTap();
              widget.onTypeChanged(true);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: widget.isQuantitative ? AppColors.accent : AppColors.card,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Center(
                child: Text(
                  'Set a target',
                  style: AppTypography.bodyMedium.copyWith(
                    color: widget.isQuantitative ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuantitativeConfig() {
    final currentTarget = widget.targetQuantity ?? 1.0;
    final displayTarget = currentTarget == currentTarget.toInt() 
        ? currentTarget.toInt().toString() 
        : currentTarget.toStringAsFixed(1);
    final displayUnit = widget.unit ?? 'unit';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlassCard(
          padding: const EdgeInsets.all(32),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: _decrement,
                icon: const Icon(Icons.remove, size: 32),
                color: AppColors.accent,
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.cardHover,
                  padding: const EdgeInsets.all(12),
                ),
              ),
              Column(
                children: [
                  Text(displayTarget, style: AppTypography.heading1.copyWith(fontSize: 48)),
                  Text(displayUnit, style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
                ],
              ),
              IconButton(
                onPressed: _increment,
                icon: const Icon(Icons.add, size: 32),
                color: AppColors.accent,
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.cardHover,
                  padding: const EdgeInsets.all(12),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Text('Unit', style: AppTypography.heading3),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ..._commonUnits.map((u) {
              final isSelected = widget.unit == u && !_isCustomUnit;
              return ChoiceChip(
                label: Text(u),
                selected: isSelected,
                selectedColor: AppColors.accent,
                backgroundColor: AppColors.card,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
                onSelected: (selected) {
                  if (selected) {
                    HapticUtils.lightTap();
                    setState(() {
                      _isCustomUnit = false;
                    });
                    widget.onUnitChanged(u);
                  }
                },
              );
            }),
            ChoiceChip(
              label: const Text('Custom'),
              selected: _isCustomUnit,
              selectedColor: AppColors.accent,
              backgroundColor: AppColors.card,
              labelStyle: TextStyle(
                color: _isCustomUnit ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
              onSelected: (selected) {
                if (selected) {
                  HapticUtils.lightTap();
                  setState(() {
                    _isCustomUnit = true;
                  });
                  if (_customUnitController.text.isNotEmpty) {
                    widget.onUnitChanged(_customUnitController.text);
                  }
                }
              },
            ),
          ],
        ),
        if (_isCustomUnit)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: TextField(
              controller: _customUnitController,
              style: AppTypography.body.copyWith(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Enter custom unit',
                hintStyle: AppTypography.body.copyWith(color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.card,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: widget.onUnitChanged,
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTypeToggle(),
        if (widget.isQuantitative) ...[
          const SizedBox(height: 32),
          _buildQuantitativeConfig(),
        ],
      ],
    );
  }
}
