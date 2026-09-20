// ============================================================================
// FILE: lib/app/routes/app_routes.dart
//
// WHAT THIS FILE DOES:
// This file is reserved for defining application-wide navigation routes and screen paths.
//
// WHY NAVIGATION IS NOT IMPLEMENTED YET:
// At this stage (Step 2), we are focusing strictly on learning the foundational
// single-screen structure of a Flutter app (main.dart -> app.dart -> home_screen.dart).
//
// When we later add multi-screen features (such as a "Create Reminder" form screen
// or "Settings" screen), we will define named routes or a routing table here so that
// screens can navigate between each other cleanly using:
// Navigator.pushNamed(context, AppRoutes.createReminder);
//
// CURRENT STATUS:
// This file is currently an architectural placeholder.
// ============================================================================

class AppRoutes {
  AppRoutes._();

  // Route path constants for future steps:
  static const String home = '/';
  static const String createReminder = '/create-reminder';
}
