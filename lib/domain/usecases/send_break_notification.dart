import '../repositories/notification_repository.dart';

/// Use case for sending break notification
///
/// This use case is responsible for notifying the user when it's time
/// to take a break. It follows the single responsibility principle.
class SendBreakNotificationUseCase {
  final NotificationRepository _notificationRepository;

  SendBreakNotificationUseCase(this._notificationRepository);

  /// Sends a break notification with the given title and message
  ///
  /// Returns true if the notification was sent successfully
  Future<bool> call({required String title, required String message}) async {
    return await _notificationRepository.showNotification(
      title: title,
      message: message,
    );
  }
}
