// ============================================================================
// FILE: lib/app/routes/app_routes.dart
// FOLDER: lib/app/routes/
//
// WHY THIS FOLDER EXISTS:
// The 'routes' folder centralizes screen navigation paths and routing logic.
// Keeping routes in one place prevents hardcoded screen string names scattered
// across different files and makes navigation predictable.
//
// RESPONSIBILITY:
// This file declares constant route names (like home, task details, add task)
// and handles routing logic or route maps for navigating between screens.
//
// WHAT CODE WILL EVENTUALLY GO HERE:
// - Static constants for route names (e.g., static const String tasks = '/tasks';).
// - A map of routes or onGenerateRoute function connecting route names
//   to their corresponding screen widgets from 'lib/features/'.
//
// HOW THIS RELATES TO THE REST OF THE APP:
// - Referenced by 'lib/app/app.dart' to inform MaterialApp about available screens.
// - Used by feature screens and widgets (such as buttons) when navigating
//   (e.g., Navigator.pushNamed(context, AppRoutes.createTask)).
//
// CURRENT STATUS:
// This file is currently a placeholder declaring route name constants.
// No navigation logic or screen transitions are implemented yet.
// ============================================================================

class AppRoutes {
  // Private constructor prevents this utility class from being instantiated.
  AppRoutes._();

  // Route name constants
  static const String initial = '/';
  static const String tasks = '/tasks';
  static const String createTask = '/tasks/create';
  static const String reminders = '/reminders';
}
