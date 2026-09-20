// ============================================================================
// FILE: lib/app/app.dart
// FOLDER: lib/app/
//
// WHY THIS FOLDER EXISTS:
// The 'app' folder contains top-level configurations that wrap the whole
// application. This includes the root widget, application routes, and visual themes.
//
// RESPONSIBILITY:
// This file defines the root widget of the application: IntervalReminderApp.
// It configures MaterialApp, setting up global styling, title, localization,
// and routing.
//
// WHAT CODE WILL EVENTUALLY GO HERE:
// - A MaterialApp (or MaterialApp.router) widget.
// - References to our theme defined in 'lib/app/theme/app_theme.dart'.
// - Initial route or home screen definition (pointing to our Tasks screen).
// - Route configuration referencing 'lib/app/routes/app_routes.dart'.
//
// HOW THIS RELATES TO THE REST OF THE APP:
// - Created and launched directly by 'lib/main.dart'.
// - Pulls visual styling from 'lib/app/theme/app_theme.dart'.
// - Uses routing definitions from 'lib/app/routes/app_routes.dart'.
// - Displays our initial feature screens from 'lib/features/'.
//
// CURRENT STATUS:
// This is a placeholder widget providing a minimal MaterialApp shell.
// No full UI, navigation, or state management is implemented yet.
// ============================================================================

import 'package:flutter/material.dart';

class IntervalReminderApp extends StatelessWidget {
  const IntervalReminderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Interval Reminder',
      debugShowCheckedModeBanner: false,
      home: const Scaffold(
        body: Center(
          child: Text('Interval Reminder Skeleton'),
        ),
      ),
    );
  }
}
