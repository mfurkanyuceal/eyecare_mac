/// Base failure class for error handling
abstract class Failure {
  final String message;

  const Failure(this.message);

  @override
  String toString() => 'Failure: $message';
}

/// Failure when notification cannot be sent
class NotificationFailure extends Failure {
  const NotificationFailure(super.message);
}

/// Failure when timer operation fails
class TimerFailure extends Failure {
  const TimerFailure(super.message);
}
