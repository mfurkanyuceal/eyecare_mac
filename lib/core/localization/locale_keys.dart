/// Translation keys for type-safe access
///
/// These keys match the JSON structure in assets/translations/
class LocaleKeys {
  LocaleKeys._();

  // App
  static const String appName = 'app.name';

  // Notifications
  static const String notificationBreakTitle = 'notification.breakTitle';
  static const String notificationBreakMessage = 'notification.breakMessage';
  static const String notificationBreakCompleteTitle =
      'notification.breakCompleteTitle';
  static const String notificationBreakCompleteMessage =
      'notification.breakCompleteMessage';

  // Menu
  static const String menuStart = 'menu.start';
  static const String menuStop = 'menu.stop';
  static const String menuExit = 'menu.exit';
  static const String menuRemaining = 'menu.remaining';

  // Status
  static const String statusIdle = 'status.idle';
  static const String statusWorking = 'status.working';
  static const String statusBreaking = 'status.breaking';
}
