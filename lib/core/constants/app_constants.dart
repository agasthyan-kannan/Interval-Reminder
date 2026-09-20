// ============================================================================
// FILE: lib/core/constants/app_constants.dart
// FOLDER: lib/core/constants/
//
// WHAT THIS FILE DOES:
// This file centralizes application-wide constant values, such as the app title
// and interval limits.
//
// WHY APPLICATION-WIDE LIMITS BELONG IN CONSTANTS:
// 1. Single Source of Truth: If we decide to change the maximum interval limit
//    from 7 days to 14 days, we only change it in this file. The validation logic
//    and UI hint text update automatically everywhere.
// 2. Eliminates "Magic Numbers": Writing '10080' or '59' directly across multiple
//    files is error-prone. Giving values descriptive names (e.g. maxIntervalMinutes)
//    makes the code self-explanatory.
// ============================================================================

class AppConstants {
  AppConstants._();

  // Application Identity
  static const String appName = 'Interval Reminder';

  // ---------------------------------------------------------------------------
  // INTERVAL CONSTRAINTS
  // ---------------------------------------------------------------------------
  // Default interval when opening the Add Reminder form
  static const int defaultIntervalHours = 1;
  static const int defaultIntervalMinutes = 0;

  // The minimum interval allowed (1 minute)
  static const int minIntervalMinutes = 1;

  // The maximum interval allowed for a repeating reminder (7 days)
  static const int maxIntervalDays = 7;
  static const int maxIntervalHours = maxIntervalDays * 24; // 168 hours
  static const int maxIntervalMinutes = maxIntervalHours * 60; // 10,080 minutes
  // ---------------------------------------------------------------------------
  // NOTIFICATION CHANNEL CONFIGURATION
  // ---------------------------------------------------------------------------
  // Android notification channels allow users to customize notification settings
  // (sound, vibration, importance) per category in Android system settings.
  static const String notificationChannelId = 'interval_reminder_channel';
  static const String notificationChannelName = 'Reminder Notifications';
  static const String notificationChannelDescription =
      'Scheduled repeating interval reminders for your tasks';
}
