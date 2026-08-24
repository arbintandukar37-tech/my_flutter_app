import 'package:flutter/material.dart';
import 'package:habit_flow/theme/app_colors.dart';
import 'package:habit_flow/theme/app_typography.dart';
import 'dart:math';

class HeatmapCalendar extends StatefulWidget {
  final Map<DateTime, double> data;
  final int weeksToShow;
  final Color baseColor;

  const HeatmapCalendar({
    super.key,
    required this.data,
    this.weeksToShow = 26,
    this.baseColor = AppColors.completed,
  });

  @override
  State<HeatmapCalendar> createState() => _HeatmapCalendarState();
}

class _HeatmapCalendarState extends State<HeatmapCalendar> {
  DateTime? _hoveredDate;
  double? _hoveredValue;
  Offset? _hoverPosition;

  void _handleTap(TapUpDetails details, Size size) {
    const cellSize = 12.0;
    const gap = 2.0;
    const totalCellSize = cellSize + gap;
    
    // Calculate row and col from local position (accounting for padding if any)
    final dx = details.localPosition.dx;
    final dy = details.localPosition.dy;
    
    // Y starts after month labels (approx 20px)
    const yOffset = 20.0;
    const xOffset = 20.0; // X starts after day labels
    
    if (dx < xOffset || dy < yOffset) return;
    
    final col = ((dx - xOffset) / totalCellSize).floor();
    final row = ((dy - yOffset) / totalCellSize).floor();
    
    if (col >= 0 && col < widget.weeksToShow && row >= 0 && row < 7) {
      final now = DateTime.now();
      // Calculate how many days ago this cell represents
      // Right-most column is current week.
      final daysToSubtract = ((widget.weeksToShow - 1 - col) * 7) + (now.weekday % 7 - row);
      final date = now.subtract(Duration(days: daysToSubtract));
      
      // Normalize date to midnight
      final normalizedDate = DateTime(date.year, date.month, date.day);
      final val = widget.data[normalizedDate] ?? 0.0;
      
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${normalizedDate.month}/${normalizedDate.day}/${normalizedDate.year}: ${(val * 100).toInt()}%',
            style: AppTypography.bodyMedium,
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.surface,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const cellSize = 12.0;
    const gap = 2.0;
    final width = 20.0 + (widget.weeksToShow * (cellSize + gap));
    const height = 20.0 + (7 * (cellSize + gap));

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      reverse: true,
      child: GestureDetector(
        onTapUp: (details) => _handleTap(details, Size(width, height)),
        child: CustomPaint(
          size: Size(width, height),
          painter: _HeatmapPainter(
            data: widget.data,
            weeksToShow: widget.weeksToShow,
            baseColor: widget.baseColor,
          ),
        ),
      ),
    );
  }
}

class _HeatmapPainter extends CustomPainter {
  final Map<DateTime, double> data;
  final int weeksToShow;
  final Color baseColor;

  _HeatmapPainter({
    required this.data,
    required this.weeksToShow,
    required this.baseColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const cellSize = 12.0;
    const gap = 2.0;
    const totalCellSize = cellSize + gap;
    const xOffset = 20.0;
    const yOffset = 20.0;
    
    final paint = Paint()..style = PaintingStyle.fill;
    
    // Draw day labels
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    final days = ['M', 'W', 'F'];
    final dayIndices = [1, 3, 5]; // Mon, Wed, Fri
    
    for (int i = 0; i < days.length; i++) {
      textPainter.text = TextSpan(text: days[i], style: AppTypography.caption.copyWith(fontSize: 10));
      textPainter.layout();
      textPainter.paint(canvas, Offset(0, yOffset + dayIndices[i] * totalCellSize));
    }

    final now = DateTime.now();
    final currentMidnight = DateTime(now.year, now.month, now.day);
    
    int currentMonth = -1;

    for (int col = 0; col < weeksToShow; col++) {
      for (int row = 0; row < 7; row++) {
        final daysToSubtract = ((weeksToShow - 1 - col) * 7) + (now.weekday % 7 - row);
        final date = currentMidnight.subtract(Duration(days: daysToSubtract));
        
        // Draw month label if month changed and it's top row
        if (row == 0 && date.month != currentMonth) {
          currentMonth = date.month;
          // Only draw if there's enough space (don't cramp at the very beginning)
          if (col > 1 || weeksToShow < 10) {
            final monthStr = _getMonthStr(date.month);
            textPainter.text = TextSpan(text: monthStr, style: AppTypography.caption.copyWith(fontSize: 10));
            textPainter.layout();
            textPainter.paint(canvas, Offset(xOffset + col * totalCellSize, 0));
          }
        }

        final isFuture = date.isAfter(currentMidnight);
        final val = data[date] ?? 0.0;
        
        Color cellColor;
        if (isFuture) {
          cellColor = AppColors.background;
        } else if (val == 0) {
          cellColor = AppColors.cardHover;
        } else if (val <= 0.25) {
          cellColor = baseColor.withValues(alpha: 0.2);
        } else if (val <= 0.50) {
          cellColor = baseColor.withValues(alpha: 0.4);
        } else if (val <= 0.75) {
          cellColor = baseColor.withValues(alpha: 0.7);
        } else {
          cellColor = baseColor;
        }

        paint.color = cellColor;
        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(
            xOffset + col * totalCellSize,
            yOffset + row * totalCellSize,
            cellSize,
            cellSize,
          ),
          const Radius.circular(2.0),
        );
        canvas.drawRRect(rect, paint);
      }
    }
  }

  String _getMonthStr(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[max(0, min(11, month - 1))];
  }

  @override
  bool shouldRepaint(covariant _HeatmapPainter oldDelegate) {
    return oldDelegate.data != data || oldDelegate.weeksToShow != weeksToShow || oldDelegate.baseColor != baseColor;
  }
}
