import 'package:flutter/services.dart';

class HapticUtils {
  static Future<void> lightTap() async {
    await HapticFeedback.lightImpact();
  }

  static Future<void> mediumTap() async {
    await HapticFeedback.mediumImpact();
  }

  static Future<void> heavyTap() async {
    await HapticFeedback.heavyImpact();
  }

  static Future<void> successBuzz() async {
    await HapticFeedback.mediumImpact();
  }

  static Future<void> tickTap() async {
    await HapticFeedback.selectionClick();
  }
}
