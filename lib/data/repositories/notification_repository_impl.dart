import 'dart:io';

import '../../domain/repositories/notification_repository.dart';

/// macOS implementation of NotificationRepository
///
/// Uses osascript to display native macOS notifications.
/// No additional packages required - works with sandbox.
class NotificationRepositoryImpl implements NotificationRepository {
  @override
  Future<bool> showNotification({
    required String title,
    required String message,
  }) async {
    try {
      // Use osascript to display a native macOS notification
      // This approach works within the app sandbox and doesn't require
      // any additional entitlements or packages.
      final result = await Process.run('osascript', [
        '-e',
        'display notification "$message" with title "$title"',
      ]);

      // osascript returns 0 on success
      return result.exitCode == 0;
    } catch (e) {
      // If osascript fails, return false
      // In a production app, you might want to log this error
      return false;
    }
  }
}
