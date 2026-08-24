import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_flow/app.dart';
import 'package:habit_flow/services/widget_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Hive.initFlutter();
  } catch (e) {
    debugPrint('Hive.initFlutter error: $e');
  }
  
  try {
    await WidgetService.initialize();
  } catch (e) {
    debugPrint('WidgetService.initialize error: $e');
  }
  
  runApp(
    const ProviderScope(
      child: HabitFlowApp(),
    ),
  );
}
