import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:habit_flow/models/habit.dart';
import 'package:habit_flow/models/habit_log.dart';

class WidgetService {
  static const String appGroupId = 'group.com.example.habit_flow';
  static const String androidWidgetName = 'HabitWidgetProvider';
  static const String iosWidgetName = 'HabitWidget';

  /// Initialize HomeWidget callbacks
  static Future<void> initialize() async {
    if (kIsWeb) return;
    try {
      await HomeWidget.setAppGroupId(appGroupId);
      HomeWidget.registerInteractivityCallback(interactiveCallback);
    } catch (e) {
      debugPrint('WidgetService.initialize error: $e');
    }
  }

  /// Interactive callback triggered when user taps checkmark directly on the home screen widget
  @pragma('vm:entry-point')
  static Future<void> interactiveCallback(Uri? uri) async {
    if (uri != null && uri.host == 'toggle_habit') {
      final habitId = uri.queryParameters['id'];
      if (habitId != null) {
        // Handle widget quick-check completion
        debugPrint('Quick-check from widget for habit: $habitId');
        // Update widget data
        await HomeWidget.updateWidget(
          name: androidWidgetName,
          iOSName: iosWidgetName,
        );
      }
    }
  }

  /// Sync today's active habits and completion status to the home screen widget
  static Future<void> updateWidgetData({
    required List<Habit> habits,
    required List<HabitLog> todayLogs,
  }) async {
    if (kIsWeb) return;
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      final scheduledHabits = habits
          .where((h) => h.frequency.isScheduledForDate(today))
          .take(4)
          .toList();

      final widgetItems = scheduledHabits.map((h) {
        final log = todayLogs.where((l) => l.habitId == h.id).firstOrNull;
        final isDone = log?.completed ?? false;
        return {
          'id': h.id,
          'name': h.name,
          'isDone': isDone,
          'target': h.isQuantitative ? '${h.targetQuantity?.toInt() ?? 1} ${h.unit ?? ''}' : '',
        };
      }).toList();

      final completedCount = widgetItems.where((i) => i['isDone'] == true).length;
      final totalCount = widgetItems.length;

      // Save summary data for widget
      await HomeWidget.saveWidgetData<String>(
        'widget_habits_json',
        jsonEncode(widgetItems),
      );
      await HomeWidget.saveWidgetData<int>('completed_count', completedCount);
      await HomeWidget.saveWidgetData<int>('total_count', totalCount);
      await HomeWidget.saveWidgetData<String>(
        'progress_text',
        '$completedCount of $totalCount done',
      );

      // Trigger native widget refresh
      await HomeWidget.updateWidget(
        name: androidWidgetName,
        iOSName: iosWidgetName,
      );
    } catch (e) {
      debugPrint('Error updating home screen widget: $e');
    }
  }
}
