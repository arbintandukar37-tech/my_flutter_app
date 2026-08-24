import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:habit_flow/providers/habit_logs_provider.dart';
import 'package:habit_flow/providers/habits_provider.dart';
import 'package:habit_flow/theme/app_colors.dart';
import 'package:habit_flow/theme/app_typography.dart';

class DailyProgressRing extends ConsumerWidget {
  const DailyProgressRing({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completionPercentage = ref.watch(todayCompletionProvider);
    final todayLogs = ref.watch(todayLogsProvider);
    final habits = ref.watch(habitsProvider);
    final today = DateTime.now();
    final scheduledHabits = habits.where((h) => h.frequency.isScheduledForDate(today)).toList();
    
    final completedCount = todayLogs.where((l) => l.completed).length;
    final totalCount = scheduledHabits.length;

    return SizedBox(
      width: 120,
      height: 120,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: completionPercentage),
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return CustomPaint(
            painter: _ProgressRingPainter(
              progress: value,
              trackColor: AppColors.border,
              progressColor: AppColors.completed,
              strokeWidth: 8,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$completedCount/$totalCount',
                    style: AppTypography.heading2.copyWith(color: AppColors.textPrimary),
                  ),
                  Text(
                    'habits done',
                    style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color progressColor;
  final double strokeWidth;

  _ProgressRingPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    final sweepAngle = 2 * pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.trackColor != trackColor ||
           oldDelegate.progressColor != progressColor ||
           oldDelegate.strokeWidth != strokeWidth;
  }
}
