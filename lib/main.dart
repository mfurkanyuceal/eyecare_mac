import 'package:flutter/material.dart';

import 'core/localization/localization_service.dart';
import 'injection_container.dart';
import 'presentation/bloc/eye_care_bloc.dart';
import 'presentation/tray/tray_manager_service.dart';

/// EyeCare Mac - A macOS menu bar app for eye strain prevention
///
/// Uses the 20-20-20 rule:
/// Every 20 minutes, look at something 20 feet away for 20 seconds.
void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependency injection
  await initDependencies();

  // Get the BLoC and localization service instances
  final eyeCareBloc = sl<EyeCareBloc>();
  final localizationService = sl<LocalizationService>();

  // Initialize tray manager
  final trayService = TrayManagerService(eyeCareBloc, localizationService);
  await trayService.init();

  // Run a minimal app (no visible UI, just tray)
  runApp(const EyeCareApp());
}

/// Minimal app widget - no visible UI
///
/// The app runs entirely in the system tray.
/// The window is hidden via MainFlutterWindow.swift
class EyeCareApp extends StatelessWidget {
  const EyeCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Return a minimal MaterialApp with no home widget
    // The app is entirely controlled via the system tray
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EyeCare Mac',
      theme: ThemeData.dark(),
      home: const SizedBox.shrink(), // Empty widget - no UI
    );
  }
}
