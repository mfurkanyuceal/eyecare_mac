import 'dart:io';

import 'package:tray_manager/tray_manager.dart';

import '../../core/constants/app_constants.dart';
import '../../domain/entities/timer_session.dart';
import '../bloc/eye_care_bloc.dart';
import '../bloc/eye_care_event.dart';

/// Service for managing the system tray icon and menu
///
/// Handles tray icon setup, context menu creation, and menu interactions.
/// Listens to BLoC state changes to update the menu dynamically.
class TrayManagerService with TrayListener {
  final EyeCareBloc _bloc;

  static const String _menuIdStart = 'start';
  static const String _menuIdStop = 'stop';
  static const String _menuIdStatus = 'status';
  static const String _menuIdExit = 'exit';

  TrayManagerService(this._bloc);

  /// Initialize the tray icon and menu
  Future<void> init() async {
    // Set up tray listener
    trayManager.addListener(this);

    // Set the tray icon
    // Using a text-based icon approach since SF Symbols require native code
    // The icon will be set from assets
    await _setTrayIcon();

    // Set up initial menu
    await _updateMenu(_bloc.state.session);

    // Listen to BLoC state changes for menu updates
    _bloc.stream.listen((state) {
      _updateMenu(state.session);
    });
  }

  /// Sets the tray icon
  Future<void> _setTrayIcon() async {
    // Try to use a bundled icon, fallback to template icon
    try {
      // Use a simple approach - set icon from path
      // For macOS, we'll create a simple icon
      if (Platform.isMacOS) {
        // macOS supports template images (will auto-adapt to menu bar color)
        await trayManager.setIcon(
          'assets/icons/tray_icon.png',
          isTemplate: true,
        );
      }
    } catch (e) {
      // If icon loading fails, the tray will still work but without icon
      // In production, you'd want to handle this more gracefully
    }
  }

  /// Updates the tray context menu based on current state
  Future<void> _updateMenu(TimerSession session) async {
    final List<MenuItem> menuItems = [];

    // Status item (disabled, shows current state)
    String statusText;
    switch (session.phase) {
      case TimerPhase.idle:
        statusText = '⏸️ Beklemede';
        break;
      case TimerPhase.working:
        statusText = '💼 Çalışıyor: ${session.formattedTime}';
        break;
      case TimerPhase.breaking:
        statusText = '👁️ Mola: ${session.formattedTime}';
        break;
    }

    menuItems.add(
      MenuItem(key: _menuIdStatus, label: statusText, disabled: true),
    );

    menuItems.add(MenuItem.separator());

    // Start/Stop based on state
    if (session.phase == TimerPhase.idle) {
      menuItems.add(
        MenuItem(key: _menuIdStart, label: '▶️ ${AppConstants.menuStart}'),
      );
    } else {
      menuItems.add(
        MenuItem(key: _menuIdStop, label: '⏹️ ${AppConstants.menuStop}'),
      );
    }

    menuItems.add(MenuItem.separator());

    // Exit
    menuItems.add(
      MenuItem(key: _menuIdExit, label: '❌ ${AppConstants.menuExit}'),
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
    switch (menuItem.key) {
      case _menuIdStart:
        _bloc.add(const StartTimerEvent());
      case _menuIdStop:
        _bloc.add(const StopTimerEvent());
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
