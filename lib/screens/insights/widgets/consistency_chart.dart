import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:habit_flow/theme/app_colors.dart';
import 'package:habit_flow/theme/app_typography.dart';
import 'package:habit_flow/widgets/glass_card.dart';

class ConsistencyChart extends ConsumerWidget {
  final List<double> weeklyRates;

  const ConsistencyChart({
    super.key,
    required this.weeklyRates,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (weeklyRates.isEmpty) {
      return GlassCard(
        padding: const EdgeInsets.all(24.0),
        backgroundColor: AppColors.card,
        child: SizedBox(
          height: 200,
          child: Center(
            child: Text(
              'No data yet',
              style: AppTypography.bodyMuted,
            ),
          ),
        ),
      );
    }

    // Ensure we take up to 8 weeks maximum
    final chartData = weeklyRates.take(8).toList();

    return GlassCard(
      padding: const EdgeInsets.all(16.0).copyWith(top: 24.0),
      backgroundColor: AppColors.card,
      child: SizedBox(
        height: 200,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: 100,
            minY: 0,
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                tooltipBgColor: AppColors.surface,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  return BarTooltipItem(
                    '${rod.toY.toInt()}%',
                    AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'W${value.toInt() + 1}',
                        style: AppTypography.caption,
                      ),
                    );
                  },
                ),
              ),
              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 25,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: AppColors.border.withValues(alpha: 0.3),
                  strokeWidth: 1,
                );
              },
            ),
            borderData: FlBorderData(show: false),
            barGroups: List.generate(chartData.length, (index) {
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: (chartData[index] * 100).clamp(0, 100),
                    width: 24,
                    gradient: const LinearGradient(
                      colors: [AppColors.accent, AppColors.completed],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      toY: 100,
                      color: Colors.transparent,
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}
