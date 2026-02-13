import 'dart:io';
import 'dart:ui';

import 'package:window_manager/window_manager.dart';

/// Service to manage the macOS window visibility
///
/// Handles showing and hiding the app window for break reminders.
class WindowService {
  bool _isInitialized = false;

  /// Initialize the window manager
  Future<void> ensureInitialized() async {
    if (_isInitialized) return;

    await windowManager.ensureInitialized();

    const windowOptions = WindowOptions(
      size: Size(500, 600),
      center: true,
      skipTaskbar: true,
      titleBarStyle: TitleBarStyle.hidden,
      alwaysOnTop: true,
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      // Start hidden
      await windowManager.hide();
    });

    _isInitialized = true;
  }

  /// Show the app window and bring to front
  Future<void> showWindow() async {
    await ensureInitialized();
    await windowManager.setAlwaysOnTop(true);
    await windowManager.show();
    await windowManager.focus();
  }

  /// Hide the app window
  Future<void> hideWindow() async {
    await ensureInitialized();
    await windowManager.hide();
  }

  /// Play notification sound
  Future<void> playSound() async {
    if (Platform.isMacOS) {
      Process.run('afplay', ['/System/Library/Sounds/Glass.aiff']);
    }
  }
}
