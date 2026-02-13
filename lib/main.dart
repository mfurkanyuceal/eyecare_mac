import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

import 'core/localization/localization_service.dart';
import 'core/services/window_service.dart';
import 'domain/entities/timer_session.dart';
import 'injection_container.dart';
import 'presentation/bloc/eye_care_bloc.dart';
import 'presentation/bloc/eye_care_event.dart';
import 'presentation/screens/break_screen.dart';
import 'presentation/screens/settings_screen.dart';
import 'presentation/tray/tray_manager_service.dart';

/// Global navigator key for context-free access in tray
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Global callback for showing settings
VoidCallback? showSettingsCallback;

/// EyeCare Mac - A macOS menu bar app for eye strain prevention
///
/// Uses the 20-20-20 rule:
/// Every 20 minutes, look at something 20 feet away for 20 seconds.
void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize easy_localization
  await EasyLocalization.ensureInitialized();

  // Initialize dependency injection
  await initDependencies();

  // Initialize window service (hides window on startup)
  final windowService = sl<WindowService>();
  await windowService.ensureInitialized();

  // Get the BLoC and localization service instances
  final eyeCareBloc = sl<EyeCareBloc>();
  final localizationService = sl<LocalizationService>();

  // Initialize tray manager
  final trayService = TrayManagerService(eyeCareBloc, localizationService);
  await trayService.init();

  // Run app with EasyLocalization
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('tr')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const EyeCareApp(),
    ),
  );
}

/// Main app widget that shows break screen when needed
class EyeCareApp extends StatefulWidget {
  const EyeCareApp({super.key});

  @override
  State<EyeCareApp> createState() => _EyeCareAppState();
}

class _EyeCareAppState extends State<EyeCareApp> with WindowListener {
  late final EyeCareBloc _bloc;
  late final WindowService _windowService;
  bool _isShowingBreakScreen = false;
  bool _isShowingSettings = false;
  TimerPhase _lastPhase = TimerPhase.idle;

  @override
  void initState() {
    super.initState();
    _bloc = sl<EyeCareBloc>();
    _windowService = sl<WindowService>();

    // Listen to window events
    windowManager.addListener(this);

    // Set up global settings callback
    showSettingsCallback = _showSettings;

    // Listen to bloc state changes
    _bloc.stream.listen((state) {
      final currentPhase = state.session.phase;

      // Show break screen when entering break phase
      if (currentPhase == TimerPhase.breaking &&
          _lastPhase != TimerPhase.breaking) {
        _showBreakScreen();
      }

      _lastPhase = currentPhase;
    });
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  /// When window loses focus or is hidden externally, reset flags
  @override
  void onWindowBlur() {
    // Window lost focus — if it gets hidden, we need to reset state
    Future.delayed(const Duration(milliseconds: 300), () async {
      final isVisible = await windowManager.isVisible();
      if (!isVisible) {
        _resetScreenFlags();
      }
    });
  }

  void _resetScreenFlags() {
    if (_isShowingSettings) {
      print('DEBUG: Resetting _isShowingSettings flag');
      _isShowingSettings = false;
      // Pop if possible
      if (navigatorKey.currentState != null &&
          navigatorKey.currentState!.canPop()) {
        navigatorKey.currentState!.pop();
      }
    }
    if (_isShowingBreakScreen) {
      print('DEBUG: Resetting _isShowingBreakScreen flag');
      _isShowingBreakScreen = false;
      if (navigatorKey.currentState != null &&
          navigatorKey.currentState!.canPop()) {
        navigatorKey.currentState!.pop();
      }
    }
  }

  Future<int> _getBreakDuration() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('break_seconds') ?? 20;
  }

  void _showBreakScreen() async {
    print(
      'DEBUG: _showBreakScreen called, isShowingBreak=$_isShowingBreakScreen, isShowingSettings=$_isShowingSettings',
    );
    if (_isShowingBreakScreen) return;

    // Force close settings if open
    if (_isShowingSettings) {
      _isShowingSettings = false;
      if (navigatorKey.currentState != null &&
          navigatorKey.currentState!.canPop()) {
        navigatorKey.currentState!.pop();
      }
    }

    _isShowingBreakScreen = true;

    // Get break duration from settings
    final breakDuration = await _getBreakDuration();

    // Play sound
    await _windowService.playSound();

    // Show window
    await _windowService.showWindow();

    // Navigate to break screen
    if (navigatorKey.currentState != null) {
      navigatorKey.currentState!.push(
        MaterialPageRoute(
          builder: (_) => BreakScreen(
            breakDurationSeconds: breakDuration,
            onBreakComplete: _onBreakComplete,
            onStop: _onStopTimer,
          ),
        ),
      );
    }
  }

  void _showSettings() async {
    print(
      'DEBUG: _showSettings called, isShowingBreak=$_isShowingBreakScreen, isShowingSettings=$_isShowingSettings',
    );
    if (_isShowingBreakScreen || _isShowingSettings) return;

    _isShowingSettings = true;

    // Show window
    await _windowService.showWindow();

    // Navigate to settings screen
    if (navigatorKey.currentState != null) {
      navigatorKey.currentState!.push(
        MaterialPageRoute(
          builder: (_) => SettingsScreen(
            onClose: ({required bool durationChanged}) {
              _onCloseSettings(durationChanged: durationChanged);
            },
          ),
        ),
      );
    }
  }

  void _onCloseSettings({required bool durationChanged}) async {
    _isShowingSettings = false;

    // Pop the settings screen
    if (navigatorKey.currentState != null &&
        navigatorKey.currentState!.canPop()) {
      navigatorKey.currentState!.pop();
    }

    // Hide window
    await _windowService.hideWindow();

    // Restart timer if duration changed and timer is running
    if (durationChanged) {
      final phase = _bloc.state.session.phase;
      if (phase == TimerPhase.working || phase == TimerPhase.breaking) {
        print('DEBUG: Duration changed, restarting timer');
        _bloc.add(const StopTimerEvent());
        // Small delay to ensure stop completes before restart
        await Future.delayed(const Duration(milliseconds: 100));
        _bloc.add(const StartTimerEvent());
      }
    }
  }

  void _onBreakComplete() async {
    _isShowingBreakScreen = false;

    // Pop the break screen
    if (navigatorKey.currentState != null &&
        navigatorKey.currentState!.canPop()) {
      navigatorKey.currentState!.pop();
    }

    // Hide window
    await _windowService.hideWindow();
  }

  void _onStopTimer() async {
    _isShowingBreakScreen = false;

    // Stop the timer completely
    _bloc.add(const StopTimerEvent());

    // Pop the break screen
    if (navigatorKey.currentState != null &&
        navigatorKey.currentState!.canPop()) {
      navigatorKey.currentState!.pop();
    }

    // Hide window
    await _windowService.hideWindow();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'EyeCare Mac',
      theme: ThemeData.dark(),
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      home: const Scaffold(
        backgroundColor: Colors.transparent,
        body: SizedBox.shrink(),
      ),
    );
  }
}
