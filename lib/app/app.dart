// ============================================================================
// FILE: lib/app/app.dart
//
// WHAT THIS FILE DOES:
// This file defines the root widget of our application: IntervalReminderApp.
// It wraps the entire application in a MaterialApp and configures the app title,
// global theme, and the starting Home screen.
//
// WHAT A StatelessWidget MEANS:
// A 'StatelessWidget' is a widget that does NOT hold or change its own internal state
// over time. Once Flutter builds it, its configuration remains constant unless its
// parent rebuilds it with new data. Because our root app configuration (title, theme,
// home screen) doesn't need to change dynamically on its own, a StatelessWidget is
// the perfect, lightweight choice.
//
// WHAT MaterialApp DOES:
// 'MaterialApp' is a powerful convenience widget provided by the Flutter framework.
// It sets up the core infrastructure required for Material Design applications:
// 1. Navigation & Routing (managing screens and history).
// 2. Theming (injecting ThemeData into the widget tree).
// 3. Localization & Text Direction (supporting languages and LTR/RTL layouts).
// 4. Global Overlay and Dialog systems (for Snackbars, BottomSheets, and Alerts).
//
// WHY THE APPLICATION WIDGET IS SEPARATED FROM main.dart:
// 1. Single Responsibility Principle: main.dart only cares about launching the app;
//    app.dart cares about configuring the app.
// 2. Testability: Having IntervalReminderApp in its own file makes it easy to write
//    widget tests that pump the whole app without re-running main() bootstrap code.
// 3. Cleanliness: Keeps the entrypoint tidy as the app grows.
// ============================================================================

import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import '../features/tasks/presentation/screens/home_screen.dart';

class IntervalReminderApp extends StatelessWidget {
  const IntervalReminderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // The title of the application, used by the device OS (e.g. in the app switcher).
      title: 'Interval Reminder',

      // Hides the small "DEBUG" banner in the top-right corner during development.
      debugShowCheckedModeBanner: false,

      // Apply our custom light and dark themes from AppTheme.
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,

      // 'home' defines the default screen displayed when the app launches.
      // Here, it points directly to our HomeScreen.
      home: const HomeScreen(),
    );
  }
}
