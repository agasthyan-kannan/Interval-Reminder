// ============================================================================
// FILE: lib/core/utils/date_time_utils.dart
// FOLDER: lib/core/utils/
//
// WHAT THIS FILE DOES:
// This file provides reusable utility functions for formatting dates, times,
// and interval durations into human-readable text.
//
// WHY CENTRALIZING FORMATTING IS A BEST PRACTICE:
// 1. Single Responsibility: UI widgets should only be responsible for layout
//    and user interaction, not string parsing and duration formatting algorithms.
// 2. Consistency: Ensures that "1 hour" vs "1h 30m" is displayed identically
//    across cards, detail views, and notifications.
// 3. Testability: Because these functions are pure (deterministic, with no UI
//    or device dependencies), they can be thoroughly tested with fast unit tests!
// ============================================================================

class DateTimeUtils {
  // Private constructor prevents creating instances of this utility class.
  DateTimeUtils._();

  // ---------------------------------------------------------------------------
  // FORMAT INTERVAL
  // ---------------------------------------------------------------------------
  // Converts a Duration into clean, friendly text:
  // - 1h 30m -> "Every 1h 30m"
  // - 1h 0m  -> "Every 1 hour"
  // - 2h 0m  -> "Every 2 hours"
  // - 15m    -> "Every 15 minutes"
  // - 1m     -> "Every 1 minute"
  static String formatInterval(Duration interval) {
    final int hours = interval.inHours;
    final int minutes = interval.inMinutes % 60;

    if (hours > 0 && minutes > 0) {
      return 'Every ${hours}h ${minutes}m';
    } else if (hours > 0) {
      return 'Every $hours ${hours == 1 ? "hour" : "hours"}';
    } else {
      return 'Every $minutes ${minutes == 1 ? "minute" : "minutes"}';
    }
  }

  // ---------------------------------------------------------------------------
  // FORMAT TIME
  // ---------------------------------------------------------------------------
  // Formats a DateTime object into 12-hour AM/PM format (e.g., "10:00 AM", "02:30 PM").
  // Automatically handles midnight (12:00 AM) and noon (12:00 PM).
  static String formatTime(DateTime dateTime) {
    final int hour = dateTime.hour;
    final int minute = dateTime.minute;
    final String period = hour >= 12 ? 'PM' : 'AM';
    final int displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final String displayMinute = minute.toString().padLeft(2, '0');
    return '$displayHour:$displayMinute $period';
  }
}
