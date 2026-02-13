import 'package:flutter/foundation.dart';

/// Application constants for EyeCare Mac
///
/// Based on the 20-20-20 rule:
/// Every 20 minutes, look at something 20 feet away for 20 seconds.
class AppConstants {
  AppConstants._();

  /// Work duration in seconds
  /// Debug: 10 seconds, Release: 20 minutes
  static const int workDurationSeconds = kDebugMode ? 10 : 20 * 60;

  /// Break duration in seconds
  /// Debug: 10 seconds, Release: 20 seconds
  static const int breakDurationSeconds = kDebugMode ? 10 : 20;

  /// App name
  static const String appName = 'EyeCare Mac';
}
