import 'package:equatable/equatable.dart';

/// Base class for all EyeCare events
abstract class EyeCareEvent extends Equatable {
  const EyeCareEvent();

  @override
  List<Object?> get props => [];
}

/// Event to start the eye care timer
class StartTimerEvent extends EyeCareEvent {
  const StartTimerEvent();
}

/// Event to stop the eye care timer
class StopTimerEvent extends EyeCareEvent {
  const StopTimerEvent();
}

/// Event emitted on each timer tick
class TimerTickEvent extends EyeCareEvent {
  final int remainingSeconds;

  const TimerTickEvent(this.remainingSeconds);

  @override
  List<Object?> get props => [remainingSeconds];
}

/// Event when work timer completes (time for break)
class WorkCompleteEvent extends EyeCareEvent {
  const WorkCompleteEvent();
}

/// Event when break timer completes
class BreakCompleteEvent extends EyeCareEvent {
  const BreakCompleteEvent();
}
