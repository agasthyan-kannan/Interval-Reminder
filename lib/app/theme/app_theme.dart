// ============================================================================
// FILE: lib/app/theme/app_theme.dart
//
// WHAT THIS FILE DOES:
// This file centralizes the visual design and theming configuration for the
// Interval Reminder application.
//
// WHAT A FLUTTER THEME IS:
// In Flutter, a 'ThemeData' object defines the colors, typography (fonts),
// button shapes, and component styles for your whole application.
//
// WHY HAVING A CENTRAL THEME IS USEFUL:
// 1. Consistency: Every button, app bar, card, and text field automatically
//    shares the same color scheme and styling without having to re-declare
//    colors on each individual widget.
// 2. Maintainability: If you want to change your app's brand color from blue
//    to teal, or adjust font sizes, you only update this single file!
// 3. Dark Mode Support: Centralizing themes makes it straightforward to
//    provide both a lightTheme and a darkTheme that toggle seamlessly.
// ============================================================================

import 'package:flutter/material.dart';

class AppTheme {
  // Private constructor prevents creating instances of this utility class.
  AppTheme._();

  // lightTheme defines the styling when the device is in Light Mode.
  static ThemeData get lightTheme {
    return ThemeData(
      // useMaterial3: true enables Google's latest Material Design 3 system,
      // which includes modern rounded corners, dynamic color palettes, and updated components.
      useMaterial3: true,

      // ColorScheme.fromSeed() automatically generates a complete, harmonious
      // color palette (primary, secondary, surfaces, error colors, etc.) based on
      // a single seed color (here, Colors.blue).
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.light,
      ),

      // AppBarTheme defines the default appearance of all AppBars in the app.
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
    );
  }

  // darkTheme defines the styling when the device is in Dark Mode.
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
    );
  }
}
