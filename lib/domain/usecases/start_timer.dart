import '../repositories/timer_repository.dart';

/// Use case for starting the timer countdown
///
/// This use case encapsulates the business logic for starting
/// a countdown timer. Returns a stream of remaining seconds.
class StartTimerUseCase {
  final TimerRepository _timerRepository;

  StartTimerUseCase(this._timerRepository);

  /// Starts a countdown from the given duration
  ///
  /// [durationSeconds] - Number of seconds to count down from
  ///
  /// Returns a stream that emits remaining seconds each tick
  Stream<int> call(int durationSeconds) {
    return _timerRepository.startCountdown(durationSeconds);
  }
}
