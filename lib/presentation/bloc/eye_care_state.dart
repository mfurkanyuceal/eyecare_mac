import 'package:equatable/equatable.dart';

import '../../domain/entities/timer_session.dart';

/// Base class for all EyeCare states
abstract class EyeCareState extends Equatable {
  final TimerSession session;

  const EyeCareState(this.session);

  @override
  List<Object?> get props => [session];
}

/// Initial state - timer not started
class EyeCareInitial extends EyeCareState {
  const EyeCareInitial(super.session);
}

/// Timer is running (working phase)
class EyeCareRunning extends EyeCareState {
  const EyeCareRunning(super.session);
}

/// Break time - user should rest eyes
class EyeCareBreakTime extends EyeCareState {
  const EyeCareBreakTime(super.session);
}

/// Timer has been stopped
class EyeCareStopped extends EyeCareState {
  const EyeCareStopped(super.session);
}
