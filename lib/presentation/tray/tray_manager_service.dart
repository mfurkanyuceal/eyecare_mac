import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:tray_manager/tray_manager.dart';

import '../../core/localization/locale_keys.dart';
import '../../core/localization/localization_service.dart';
import '../../domain/entities/timer_session.dart';
import '../../main.dart';
import '../bloc/eye_care_bloc.dart';
import '../bloc/eye_care_event.dart';

/// Service for managing the system tray icon and menu
///
/// Handles tray icon setup, context menu creation, and menu interactions.
/// Listens to BLoC state changes to update the menu dynamically.
class TrayManagerService with TrayListener {
  final EyeCareBloc _bloc;
  final LocalizationService _localizationService;

  static const String _menuIdStart = 'start';
  static const String _menuIdStop = 'stop';
  static const String _menuIdSettings = 'settings';
  static const String _menuIdExit = 'exit';

  TimerPhase _lastPhase = TimerPhase.idle;

  TrayManagerService(this._bloc, this._localizationService);

  /// Initialize the tray icon and menu
  Future<void> init() async {
    // Set up tray listener
    trayManager.addListener(this);

    // Set the tray icon
    // Using a text-based icon approach since SF Symbols require native code
    // The icon will be set from assets
    await _setTrayIcon();

    // Set up initial menu
    await _rebuildMenu(_bloc.state.session);

    // Listen to BLoC state changes
    _bloc.stream.listen((state) {
      final session = state.session;
      // Always update the tray title (every tick)
      _updateTitle(session);
      // Only rebuild the menu when the phase changes (idle<->working<->breaking)
      if (session.phase != _lastPhase) {
        _lastPhase = session.phase;
        _rebuildMenu(session);
      }
    });
  }

  /// Sets the tray icon
  Future<void> _setTrayIcon() async {
    if (Platform.isMacOS) {
      // Get the app bundle path for macOS
      final executable = Platform.resolvedExecutable;
      // Remove /Contents/MacOS/eyecare_mac or /Contents/MacOS/Runner
      final bundlePath = executable.substring(
        0,
        executable.lastIndexOf('/Contents/MacOS/'),
      );
      final iconPath =
          '$bundlePath/Contents/Frameworks/App.framework/Resources/flutter_assets/assets/icons/tray_icon.png';

      print('DEBUG: Icon path = $iconPath');
      print('DEBUG: File exists = ${await File(iconPath).exists()}');

      if (await File(iconPath).exists()) {
        await trayManager.setIcon(iconPath, isTemplate: true);
        print('DEBUG: Icon set successfully');
      } else {
        // Fallback to emoji
        await trayManager.setTitle('👁');
        print('DEBUG: Using emoji fallback');
      }
    }
  }

  /// Updates only the tray title text (called every tick)
  Future<void> _updateTitle(TimerSession session) async {
    // Check if counter should be shown
    final prefs = await SharedPreferences.getInstance();
    final showCounter = prefs.getBool('show_counter') ?? true;

    if (!showCounter) {
      await trayManager.setTitle('');
      return;
    }

    switch (session.phase) {
      case TimerPhase.idle:
        await trayManager.setTitle('');
        break;
      case TimerPhase.working:
        await trayManager.setTitle('⏱ ${session.formattedTime}');
        break;
      case TimerPhase.breaking:
        await trayManager.setTitle('😌 ${session.formattedTime}');
        break;
    }
  }

  /// Rebuilds the tray context menu (called only when phase changes)
  Future<void> _rebuildMenu(TimerSession session) async {
    final List<MenuItem> menuItems = [];

    // Update title too
    await _updateTitle(session);

    // Start/Stop based on state
    if (session.phase == TimerPhase.idle) {
      menuItems.add(
        MenuItem(
          key: _menuIdStart,
          label: '▶️ ${_localizationService.tr(LocaleKeys.menuStart)}',
        ),
      );
    } else {
      menuItems.add(
        MenuItem(
          key: _menuIdStop,
          label: '⏹️ ${_localizationService.tr(LocaleKeys.menuStop)}',
        ),
      );
    }

    menuItems.add(MenuItem.separator());

    // Settings
    menuItems.add(MenuItem(key: _menuIdSettings, label: '⚙️ Settings'));

    menuItems.add(MenuItem.separator());

    // Exit
    menuItems.add(
      MenuItem(
        key: _menuIdExit,
        label: '❌ ${_localizationService.tr(LocaleKeys.menuExit)}',
      ),
    );

    final menu = Menu(items: menuItems);
    await trayManager.setContextMenu(menu);
  }

  @override
  void onTrayIconMouseDown() {
    // Show menu on left click
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayIconRightMouseDown() {
    // Show menu on right click
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    print('DEBUG: Menu item clicked: ${menuItem.key}');
    switch (menuItem.key) {
      case _menuIdStart:
        _bloc.add(const StartTimerEvent());
      case _menuIdStop:
        print('DEBUG: Adding StopTimerEvent to BLoC');
        _bloc.add(const StopTimerEvent());
      case _menuIdSettings:
        showSettingsCallback?.call();
      case _menuIdExit:
        _dispose();
        exit(0);
    }
  }

  /// Dispose resources
  void _dispose() {
    trayManager.removeListener(this);
    trayManager.destroy();
  }
}
