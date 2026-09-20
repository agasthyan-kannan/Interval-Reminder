// ============================================================================
// FILE: lib/app/theme/app_theme.dart
// FOLDER: lib/app/theme/
//
// WHY THIS FOLDER EXISTS:
// The 'theme' folder houses styling, colors, typography, and widget themes.
// Grouping theme data here keeps visual appearance uniform across all screens
// and makes it easy to modify colors or add Dark Mode later.
//
// RESPONSIBILITY:
// This file configures ThemeData for light mode (and eventually dark mode),
// including primary colors, card styles, app bar appearance, and text themes.
//
// WHAT CODE WILL EVENTUALLY GO HERE:
// - ThemeData lightTheme definition.
// - ThemeData darkTheme definition.
// - Color palette definitions (e.g., primary, accent, background colors).
// - Reusable button and input decoration styles.
//
// HOW THIS RELATES TO THE REST OF THE APP:
// - Provided to MaterialApp in 'lib/app/app.dart'.
// - Automatically applied to every Flutter widget (Text, Card, AppBar, Buttons)
//   across all features.
//
// CURRENT STATUS:
// This file is currently a placeholder containing basic theme definitions.
// No custom styling or color palettes are implemented yet.
// ============================================================================

import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // Basic light theme configuration placeholder
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.light,
      ),
    );
  }

  // Basic dark theme configuration placeholder
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.dark,
      ),
    );
  }
}
