import 'dart:async';

import '../../domain/repositories/timer_repository.dart';

/// Implementation of TimerRepository using Dart streams
///
/// Provides a countdown timer using Stream.periodic.
/// Supports cancellation and status checking.
class TimerRepositoryImpl implements TimerRepository {
  StreamSubscription<int>? _subscription;
  StreamController<int>? _controller;

  @override
  bool get isActive => _subscription != null;

  @override
  Stream<int> startCountdown(int durationSeconds) {
    // Cancel any existing countdown
    cancelCountdown();

    // Create a new broadcast controller
    _controller = StreamController<int>.broadcast();

    int remaining = durationSeconds;

    // Create periodic timer that ticks every second
    final periodicStream = Stream.periodic(
      const Duration(seconds: 1),
      (tick) => durationSeconds - tick - 1,
    ).take(durationSeconds);

    // Emit initial value immediately
    _controller!.add(remaining);

    // Subscribe to periodic stream
    _subscription = periodicStream.listen(
      (value) {
        remaining = value;
        _controller!.add(value);
      },
      onDone: () {
        _controller!.close();
        _subscription = null;
        _controller = null;
      },
      onError: (error) {
        _controller!.addError(error);
      },
    );

    return _controller!.stream;
  }

  @override
  void cancelCountdown() {
    print(
      'DEBUG: cancelCountdown called, subscription=${_subscription != null}, controller=${_controller != null}',
    );
    _subscription?.cancel();
    _subscription = null;
    if (_controller != null && !_controller!.isClosed) {
      _controller!.close();
    }
    _controller = null;
    print('DEBUG: cancelCountdown done');
  }
}
