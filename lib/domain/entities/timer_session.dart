import 'package:equatable/equatable.dart';

/// Represents the current state of a timer session
enum TimerPhase {
  /// Timer is idle, not started
  idle,

  /// User is working, timer counting down to break
  working,

  /// Break time - user should rest eyes
  breaking,
}

/// Entity representing an eye care timer session
class TimerSession extends Equatable {
  /// Total work duration in seconds
  final int workDuration;

  /// Total break duration in seconds
  final int breakDuration;

  /// Remaining seconds in current phase
  final int remainingSeconds;

  /// Current phase of the timer
  final TimerPhase phase;

  const TimerSession({
    required this.workDuration,
    required this.breakDuration,
    required this.remainingSeconds,
    required this.phase,
  });

  /// Creates an initial idle session
  factory TimerSession.initial({
    required int workDuration,
    required int breakDuration,
  }) {
    return TimerSession(
      workDuration: workDuration,
      breakDuration: breakDuration,
      remainingSeconds: workDuration,
      phase: TimerPhase.idle,
    );
  }

  /// Creates a copy with updated values
  TimerSession copyWith({
    int? workDuration,
    int? breakDuration,
    int? remainingSeconds,
    TimerPhase? phase,
  }) {
    return TimerSession(
      workDuration: workDuration ?? this.workDuration,
      breakDuration: breakDuration ?? this.breakDuration,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      phase: phase ?? this.phase,
    );
  }

  /// Formats remaining seconds as MM:SS
  String get formattedTime {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Check if timer is running (working or breaking)
  bool get isRunning =>
      phase == TimerPhase.working || phase == TimerPhase.breaking;

  @override
  List<Object?> get props => [
    workDuration,
    breakDuration,
    remainingSeconds,
    phase,
  ];
}
