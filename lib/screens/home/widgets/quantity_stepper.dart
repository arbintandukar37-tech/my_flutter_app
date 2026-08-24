import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:habit_flow/models/habit.dart';
import 'package:habit_flow/providers/habit_logs_provider.dart';
import 'package:habit_flow/theme/app_colors.dart';
import 'package:habit_flow/theme/app_typography.dart';
import 'package:habit_flow/utils/haptic_utils.dart';

class QuantityStepper extends ConsumerStatefulWidget {
  final Habit habit;
  final DateTime date;

  const QuantityStepper({
    super.key,
    required this.habit,
    required this.date,
  });

  @override
  ConsumerState<QuantityStepper> createState() => _QuantityStepperState();
}

class _QuantityStepperState extends ConsumerState<QuantityStepper> {
  Timer? _timer;

  double get _step {
    final target = widget.habit.targetQuantity ?? 1.0;
    if (target >= 1000) return 250.0;
    if (target >= 100) return 10.0;
    if (target >= 20) return 5.0;
    return 1.0;
  }

  void _increment() {
    ref
        .read(habitLogsProvider.notifier)
        .incrementQuantity(widget.habit.id, widget.date, _step);
    HapticUtils.tickTap();
    _checkCompletion();
  }

  void _decrement() {
    ref
        .read(habitLogsProvider.notifier)
        .decrementQuantity(widget.habit.id, widget.date, _step);
    HapticUtils.lightTap();
  }

  void _startTimer(bool isIncrement) {
    _timer = Timer.periodic(const Duration(milliseconds: 150), (timer) {
      if (isIncrement) {
        _increment();
      } else {
        _decrement();
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }

  void _checkCompletion() {
    final dateOnly =
        DateTime(widget.date.year, widget.date.month, widget.date.day);
    final logs = ref.read(habitLogsProvider);
    final log = logs
        .where((l) => l.habitId == widget.habit.id && l.dateOnly == dateOnly)
        .firstOrNull;
    final currentQty = log?.quantity ?? 0.0;
    final targetQty = widget.habit.targetQuantity ?? 1.0;
    if (currentQty >= targetQty) {
      HapticUtils.successBuzz();
    }
  }

  String _formatNumber(double val) {
    if (val == val.roundToDouble()) {
      return val.toInt().toString();
    }
    return val.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final dateOnly =
        DateTime(widget.date.year, widget.date.month, widget.date.day);
    final logs = ref.watch(habitLogsProvider);
    final log = logs
        .where((l) => l.habitId == widget.habit.id && l.dateOnly == dateOnly)
        .firstOrNull;
    final currentQty = log?.quantity ?? 0.0;
    final targetQty = widget.habit.targetQuantity ?? 1.0;
    final isCompleted = currentQty >= targetQty;
    final unit = widget.habit.unit ?? '';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onLongPressStart: (_) => _startTimer(false),
          onLongPressEnd: (_) => _stopTimer(),
          child: InkWell(
            onTap: _decrement,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: AppColors.cardHover,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.remove,
                size: 16,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              _formatNumber(currentQty),
              style: AppTypography.bodyMedium.copyWith(
                color:
                    isCompleted ? AppColors.completed : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '/ ${_formatNumber(targetQty)} $unit',
              style: AppTypography.caption
                  .copyWith(color: AppColors.textSecondary, fontSize: 11),
            ),
            const SizedBox(height: 4),
            Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor:
                    targetQty > 0 ? (currentQty / targetQty).clamp(0.0, 1.0) : 0.0,
                child: Container(
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppColors.completed
                        : widget.habit.habitColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onLongPressStart: (_) => _startTimer(true),
          onLongPressEnd: (_) => _stopTimer(),
          child: InkWell(
            onTap: _increment,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: AppColors.cardHover,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add,
                size: 16,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
