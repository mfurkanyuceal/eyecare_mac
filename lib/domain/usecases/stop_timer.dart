import '../repositories/timer_repository.dart';

/// Use case for stopping the active timer
///
/// This use case encapsulates the business logic for cancelling
/// an active countdown timer.
class StopTimerUseCase {
  final TimerRepository _timerRepository;

  StopTimerUseCase(this._timerRepository);

  /// Stops the currently active timer
  void call() {
    _timerRepository.cancelCountdown();
  }
}
