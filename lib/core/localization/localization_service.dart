import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/services.dart';

/// Service for managing localization without requiring BuildContext
///
/// This service loads translations from JSON files and provides
/// context-free access to translated strings. Perfect for tray apps.
class LocalizationService {
  final Map<String, dynamic> _translations = {};
  Locale _currentLocale = const Locale('en');

  /// Supported locales
  static const List<Locale> supportedLocales = [Locale('en'), Locale('tr')];

  /// Default locale
  static const Locale defaultLocale = Locale('en');

  /// Current locale
  Locale get currentLocale => _currentLocale;

  /// Initialize the localization service
  ///
  /// Detects system locale and loads appropriate translations
  Future<void> init() async {
    // Get system locale
    final systemLocale = _getSystemLocale();

    // Check if system locale is supported, otherwise use default
    final localeToUse = supportedLocales.contains(systemLocale)
        ? systemLocale
        : defaultLocale;

    await setLocale(localeToUse);
  }

  /// Get system locale
  Locale _getSystemLocale() {
    try {
      // Get locale from platform
      final platformLocale = Platform.localeName;
      final parts = platformLocale.split('_');
      if (parts.isNotEmpty) {
        return Locale(parts[0]);
      }
    } catch (e) {
      // Fallback to default
    }
    return defaultLocale;
  }

  /// Set the current locale and load translations
  Future<void> setLocale(Locale locale) async {
    _currentLocale = locale;
    await _loadTranslations(locale.languageCode);
  }

  /// Load translations from JSON file
  Future<void> _loadTranslations(String languageCode) async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/translations/$languageCode.json',
      );
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      _translations.clear();
      _flattenMap(jsonMap, '', _translations);
    } catch (e) {
      // If loading fails, try to load default locale
      if (languageCode != defaultLocale.languageCode) {
        await _loadTranslations(defaultLocale.languageCode);
      }
    }
  }

  /// Flatten nested JSON map to dot-notation keys
  void _flattenMap(
    Map<String, dynamic> source,
    String prefix,
    Map<String, dynamic> target,
  ) {
    source.forEach((key, value) {
      final newKey = prefix.isEmpty ? key : '$prefix.$key';
      if (value is Map<String, dynamic>) {
        _flattenMap(value, newKey, target);
      } else {
        target[newKey] = value;
      }
    });
  }

  /// Get translated string by key
  ///
  /// [key] - Translation key (e.g., 'menu.start')
  /// [args] - Optional arguments for interpolation (e.g., {'time': '05:00'})
  String tr(String key, {Map<String, String>? args}) {
    String value = _translations[key]?.toString() ?? key;

    // Replace placeholders with args
    if (args != null) {
      args.forEach((argKey, argValue) {
        value = value.replaceAll('{$argKey}', argValue);
      });
    }

    return value;
  }

  /// Check if a translation key exists
  bool hasKey(String key) => _translations.containsKey(key);
}
