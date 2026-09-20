// ============================================================================
// FILE: lib/core/constants/app_constants.dart
// FOLDER: lib/core/constants/
//
// WHY THIS FOLDER EXISTS:
// The 'core' directory contains code that is fundamental and independent of any
// single feature. The 'constants' subfolder stores global, unchanging values
// used throughout the application.
//
// RESPONSIBILITY:
// This file centralizes application-wide constant values so they are defined
// in one single place instead of being hardcoded into multiple files.
//
// WHAT CODE WILL EVENTUALLY GO HERE:
// - Application name and version string.
// - Default interval values (e.g., default reminder time in minutes or hours).
// - Input limits (e.g., maximum task title length, minimum interval allowed).
// - Storage keys (e.g., database table names or shared preferences keys).
//
// HOW THIS RELATES TO THE REST OF THE APP:
// - Features (tasks, reminders) import this file whenever they need
//   default limits, preset interval choices, or application labels.
//
// CURRENT STATUS:
// This file is currently a placeholder declaring structural sample constants.
// No business logic or feature-specific constraints are implemented yet.
// ============================================================================

class AppConstants {
  AppConstants._();

  // Application Identity
  static const String appName = 'Interval Reminder';

  // Placeholder default interval values (to be expanded later)
  static const int defaultIntervalMinutes = 60;
  static const int minIntervalMinutes = 5;
  static const int maxIntervalMinutes = 1440; // 24 hours
}
