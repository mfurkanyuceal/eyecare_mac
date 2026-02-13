/// Abstract repository for timer operations
///
/// This interface defines the contract for timer functionality.
/// Implementations handle the actual timer logic.
abstract class TimerRepository {
  /// Creates a countdown stream that emits remaining seconds
  ///
  /// [durationSeconds] - Total duration to count down from
  ///
  /// Returns a stream of remaining seconds, ending when count reaches 0
  Stream<int> startCountdown(int durationSeconds);

  /// Cancels any active countdown
  void cancelCountdown();

  /// Check if a countdown is currently active
  bool get isActive;
}
