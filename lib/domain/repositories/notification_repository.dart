/// Abstract repository for sending notifications
///
/// This interface defines the contract for notification operations.
/// Implementations can use native macOS notifications, osascript, etc.
abstract class NotificationRepository {
  /// Sends a notification with the given title and message
  ///
  /// [title] - The notification title
  /// [message] - The notification body text
  ///
  /// Returns true if notification was sent successfully
  Future<bool> showNotification({
    required String title,
    required String message,
  });
}
