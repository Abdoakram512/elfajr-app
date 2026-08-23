import 'package:flutter/services.dart';

class HapticHelper {
  HapticHelper._();

  /// Soft click feedback for buttons, chips, and tabs
  static void light() {
    try {
      HapticFeedback.lightImpact();
    } catch (_) {}
  }

  /// Medium feedback for dialog confirmations and scans
  static void medium() {
    try {
      HapticFeedback.mediumImpact();
    } catch (_) {}
  }

  /// Heavy feedback for critical actions
  static void heavy() {
    try {
      HapticFeedback.heavyImpact();
    } catch (_) {}
  }

  /// Feedback for selection change
  static void selection() {
    try {
      HapticFeedback.selectionClick();
    } catch (_) {}
  }

  /// Positive feedback on success (double vibrate or haptic)
  static void success() {
    try {
      HapticFeedback.mediumImpact();
    } catch (_) {}
  }
}
