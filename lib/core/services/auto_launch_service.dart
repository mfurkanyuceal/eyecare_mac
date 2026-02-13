import 'dart:io';

/// Service to manage macOS Login Items using AppleScript
///
/// Adds/removes the app from System Preferences > Login Items
class AutoLaunchService {
  static const _appName = 'eyecare_mac';

  /// Check if the app is in login items
  static Future<bool> isEnabled() async {
    try {
      final result = await Process.run('osascript', [
        '-e',
        'tell application "System Events" to get the name of every login item',
      ]);
      final output = result.stdout.toString();
      return output.contains(_appName);
    } catch (e) {
      return false;
    }
  }

  /// Add the app to login items
  static Future<bool> enable() async {
    try {
      final appPath = _getAppBundlePath();
      if (appPath == null) return false;

      final result = await Process.run('osascript', [
        '-e',
        'tell application "System Events" to make login item at end with properties {path:"$appPath", hidden:true}',
      ]);
      return result.exitCode == 0;
    } catch (e) {
      return false;
    }
  }

  /// Remove the app from login items
  static Future<bool> disable() async {
    try {
      final result = await Process.run('osascript', [
        '-e',
        'tell application "System Events" to delete login item "$_appName"',
      ]);
      return result.exitCode == 0;
    } catch (e) {
      return false;
    }
  }

  /// Get the .app bundle path from the resolved executable
  static String? _getAppBundlePath() {
    final executable = Platform.resolvedExecutable;
    final idx = executable.lastIndexOf('/Contents/MacOS/');
    if (idx == -1) return null;
    return executable.substring(0, idx);
  }
}
