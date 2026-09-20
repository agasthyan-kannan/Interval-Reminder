// ============================================================================
// FILE: lib/main.dart
//
// RESPONSIBILITY:
// This is the main entry point of the entire Flutter application.
// When you run the app on a physical device, simulator, or web browser,
// Flutter begins execution by calling the main() function defined here.
//
// WHAT CODE WILL EVENTUALLY GO HERE:
// - Initializing Flutter engine bindings (WidgetsFlutterBinding.ensureInitialized()).
// - Initializing essential core services before the UI loads (such as local
//   storage or notification services).
// - Calling runApp() and passing the root application widget (IntervalReminderApp).
//
// HOW THIS RELATES TO THE REST OF THE APP:
// - main.dart bootstraps the app and hands control over to the root widget
//   located in 'lib/app/app.dart'.
// - It keeps startup logic concise and delegates all UI and configuration
//   responsibilities to dedicated folders.
//
// CURRENT STATUS:
// This file contains only a minimal placeholder entry point to establish the
// project architecture. No actual initialization or business logic is run.
// ============================================================================

import 'package:flutter/material.dart';
import 'app/app.dart';

void main() {
  // runApp() takes our root widget and inflates it onto the screen.
  runApp(const IntervalReminderApp());
}
