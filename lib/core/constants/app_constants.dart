/// Application constants for EyeCare Mac
///
/// Based on the 20-20-20 rule:
/// Every 20 minutes, look at something 20 feet away for 20 seconds.
class AppConstants {
  AppConstants._();

  /// Work duration in seconds (20 minutes)
  static const int workDurationSeconds = 20 * 60;

  /// Break duration in seconds (20 seconds)
  static const int breakDurationSeconds = 20;

  /// App name
  static const String appName = 'EyeCare Mac';

  /// Notification title
  static const String notificationTitle = 'Göz Molası Zamanı! 👁️';

  /// Notification message
  static const String notificationMessage =
      '20 saniye boyunca 6 metre uzağa bakın.';

  /// Break complete notification title
  static const String breakCompleteTitle = 'Mola Bitti!';

  /// Break complete notification message
  static const String breakCompleteMessage =
      'Yeni çalışma periyodu başladı. Gözlerinize iyi bakın!';

  /// Tray menu labels
  static const String menuStart = 'Başlat';
  static const String menuStop = 'Durdur';
  static const String menuExit = 'Çıkış';
  static const String menuRemaining = 'Kalan';
}
