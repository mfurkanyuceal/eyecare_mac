import 'package:get_it/get_it.dart';

import 'core/localization/localization_service.dart';
import 'core/services/window_service.dart';
import 'data/repositories/notification_repository_impl.dart';
import 'data/repositories/timer_repository_impl.dart';
import 'domain/repositories/notification_repository.dart';
import 'domain/repositories/timer_repository.dart';
import 'domain/usecases/send_break_notification.dart';
import 'domain/usecases/start_timer.dart';
import 'domain/usecases/stop_timer.dart';
import 'presentation/bloc/eye_care_bloc.dart';

/// Global service locator instance
final sl = GetIt.instance;

/// Initialize all dependencies
///
/// This function registers all dependencies in the correct order:
/// 1. External dependencies
/// 2. Data sources
/// 3. Repositories
/// 4. Use cases
/// 5. BLoCs
Future<void> initDependencies() async {
  // ==================== Core Services ====================

  // Localization Service
  final localizationService = LocalizationService();
  await localizationService.init();
  sl.registerLazySingleton<LocalizationService>(() => localizationService);

  // Window Service
  sl.registerLazySingleton<WindowService>(() => WindowService());

  // ==================== Repositories ====================

  // Notification Repository
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(),
  );

  // Timer Repository
  sl.registerLazySingleton<TimerRepository>(() => TimerRepositoryImpl());

  // ==================== Use Cases ====================

  sl.registerFactory(
    () => SendBreakNotificationUseCase(sl<NotificationRepository>()),
  );

  sl.registerFactory(() => StartTimerUseCase(sl<TimerRepository>()));

  sl.registerFactory(() => StopTimerUseCase(sl<TimerRepository>()));

  // ==================== BLoCs ====================

  sl.registerLazySingleton(
    () => EyeCareBloc(
      startTimerUseCase: sl<StartTimerUseCase>(),
      stopTimerUseCase: sl<StopTimerUseCase>(),
      sendBreakNotificationUseCase: sl<SendBreakNotificationUseCase>(),
      localizationService: sl<LocalizationService>(),
    ),
  );
}
