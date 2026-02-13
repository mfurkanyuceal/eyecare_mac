import '../../domain/repositories/notification_repository.dart';

/// macOS implementation of NotificationRepository
///
/// The actual break UI is shown via Flutter window (BreakScreen).
/// This repo just logs the notification for debugging.
class NotificationRepositoryImpl implements NotificationRepository {
  @override
  Future<bool> showNotification({
    required String title,
    required String message,
  }) async {
    // The break screen is now shown via Flutter UI in main.dart
    // This method is called for logging purposes
    print('Break notification triggered: $title - $message');
    return true;
  }
}
