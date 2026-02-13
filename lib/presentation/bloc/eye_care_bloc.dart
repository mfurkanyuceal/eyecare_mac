import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_constants.dart';
import '../../domain/entities/timer_session.dart';
import '../../domain/usecases/send_break_notification.dart';
import '../../domain/usecases/start_timer.dart';
import '../../domain/usecases/stop_timer.dart';
import 'eye_care_event.dart';
import 'eye_care_state.dart';

/// BLoC for managing eye care timer state
///
/// Handles the 20-20-20 rule:
/// - Work for 20 minutes
/// - Take a 20 second break
/// - Look at something 20 feet away
class EyeCareBloc extends Bloc<EyeCareEvent, EyeCareState> {
  final StartTimerUseCase _startTimerUseCase;
  final StopTimerUseCase _stopTimerUseCase;
  final SendBreakNotificationUseCase _sendBreakNotificationUseCase;

  StreamSubscription<int>? _timerSubscription;

  EyeCareBloc({
    required StartTimerUseCase startTimerUseCase,
    required StopTimerUseCase stopTimerUseCase,
    required SendBreakNotificationUseCase sendBreakNotificationUseCase,
  }) : _startTimerUseCase = startTimerUseCase,
       _stopTimerUseCase = stopTimerUseCase,
       _sendBreakNotificationUseCase = sendBreakNotificationUseCase,
       super(
         EyeCareInitial(
           TimerSession.initial(
             workDuration: AppConstants.workDurationSeconds,
             breakDuration: AppConstants.breakDurationSeconds,
           ),
         ),
       ) {
    on<StartTimerEvent>(_onStartTimer);
    on<StopTimerEvent>(_onStopTimer);
    on<TimerTickEvent>(_onTimerTick);
    on<WorkCompleteEvent>(_onWorkComplete);
    on<BreakCompleteEvent>(_onBreakComplete);
  }

  /// Handles start timer event
  Future<void> _onStartTimer(
    StartTimerEvent event,
    Emitter<EyeCareState> emit,
  ) async {
    // Cancel any existing subscription
    await _timerSubscription?.cancel();

    // Create new session in working phase
    final newSession = state.session.copyWith(
      remainingSeconds: state.session.workDuration,
      phase: TimerPhase.working,
    );

    emit(EyeCareRunning(newSession));

    // Start the countdown
    _timerSubscription = _startTimerUseCase(state.session.workDuration).listen(
      (remaining) => add(TimerTickEvent(remaining)),
      onDone: () => add(const WorkCompleteEvent()),
    );
  }

  /// Handles stop timer event
  Future<void> _onStopTimer(
    StopTimerEvent event,
    Emitter<EyeCareState> emit,
  ) async {
    await _timerSubscription?.cancel();
    _timerSubscription = null;
    _stopTimerUseCase();

    final newSession = state.session.copyWith(
      remainingSeconds: state.session.workDuration,
      phase: TimerPhase.idle,
    );

    emit(EyeCareStopped(newSession));
  }

  /// Handles timer tick event
  void _onTimerTick(TimerTickEvent event, Emitter<EyeCareState> emit) {
    final newSession = state.session.copyWith(
      remainingSeconds: event.remainingSeconds,
    );

    if (state.session.phase == TimerPhase.working) {
      emit(EyeCareRunning(newSession));
    } else if (state.session.phase == TimerPhase.breaking) {
      emit(EyeCareBreakTime(newSession));
    }
  }

  /// Handles work complete event - time for a break
  Future<void> _onWorkComplete(
    WorkCompleteEvent event,
    Emitter<EyeCareState> emit,
  ) async {
    await _timerSubscription?.cancel();

    // Send break notification
    await _sendBreakNotificationUseCase(
      title: AppConstants.notificationTitle,
      message: AppConstants.notificationMessage,
    );

    // Start break timer
    final breakSession = state.session.copyWith(
      remainingSeconds: state.session.breakDuration,
      phase: TimerPhase.breaking,
    );

    emit(EyeCareBreakTime(breakSession));

    // Start break countdown
    _timerSubscription = _startTimerUseCase(state.session.breakDuration).listen(
      (remaining) => add(TimerTickEvent(remaining)),
      onDone: () => add(const BreakCompleteEvent()),
    );
  }

  /// Handles break complete event - restart work timer
  Future<void> _onBreakComplete(
    BreakCompleteEvent event,
    Emitter<EyeCareState> emit,
  ) async {
    await _timerSubscription?.cancel();

    // Notify user break is complete
    await _sendBreakNotificationUseCase(
      title: AppConstants.breakCompleteTitle,
      message: AppConstants.breakCompleteMessage,
    );

    // Restart work timer
    final workSession = state.session.copyWith(
      remainingSeconds: state.session.workDuration,
      phase: TimerPhase.working,
    );

    emit(EyeCareRunning(workSession));

    // Start work countdown
    _timerSubscription = _startTimerUseCase(state.session.workDuration).listen(
      (remaining) => add(TimerTickEvent(remaining)),
      onDone: () => add(const WorkCompleteEvent()),
    );
  }

  @override
  Future<void> close() {
    _timerSubscription?.cancel();
    return super.close();
  }
}
