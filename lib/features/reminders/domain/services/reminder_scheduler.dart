// ============================================================================
// FILE: lib/features/reminders/domain/services/reminder_scheduler.dart
// FOLDER: lib/features/reminders/domain/services/
//
// WHAT THIS FILE DOES:
// This service contains pure mathematical scheduling logic for determining
// WHEN the next occurrence of a reminder should fire.
//
// WHY THIS IS SEPARATE FROM NOTIFICATION CODE:
// In Clean Architecture, business algorithms (like calculating time intervals)
// belong in the 'domain' layer. They should NOT depend on any device APIs
// or notification plugins. This makes the logic:
// 1. 100% testable using standard Dart unit tests.
// 2. Reusable across different presentation screens or background workers.
//
// WHY WE DO NOT USE Timer.periodic():
// A Dart Timer (Timer.periodic) only runs while the Flutter application process
// is actively running in the foreground or memory. When the user closes the app,
// locks the screen, or Android suspends the process to save battery, all Dart
// timers STOP completely!
//
// Instead of constantly running a timer in the background, we calculate the
// exact single DateTime of the next alert, and ask the operating system (Android/iOS)
// to wake up and alert the user at that exact moment.
// ============================================================================

import '../entities/reminder.dart';

class ReminderScheduler {
  ReminderScheduler._();

  // ---------------------------------------------------------------------------
  // CALCULATE NEXT OCCURRENCE
  // ---------------------------------------------------------------------------
  // Determines the next valid DateTime when this reminder should trigger.
  //
  // PARAMETERS:
  // - reminder: The reminder entity containing startTime and interval Duration.
  // - now: The reference current time (usually DateTime.now(), or a custom date in tests).
  //
  // SCHEDULING CASES HANDLED:
  //
  // Case 1: Current time is BEFORE the start time
  //   Example: Start = 10:00 AM, Current = 9:30 AM
  //   Result:  10:00 AM (the reminder cycle has not started yet).
  //
  // Case 2: Current time is EXACTLY the start time
  //   Example: Start = 10:00 AM, Current = 10:00 AM
  //   Result:  10:00 AM (this is the scheduled starting alert moment).
  //   Decision: If now == startTime, we return startTime because this moment has
  //   arrived. (When rescheduled later after firing, 'now' will be past 10:00 AM,
  //   moving it to the next interval cycle).
  //
  // Case 3: Current time is AFTER the start time
  //   Example: Start = 10:00 AM, Interval = 1 hour, Current = 12:20 PM
  //   - Time elapsed since start: 140 minutes
  //   - Intervals passed: 140 ~/ 60 = 2 full intervals (10:00 AM -> 11:00 AM -> 12:00 PM)
  //   - Next occurrence: Start + (2 + 1) * 1 hour = 1:00 PM!
  //
  // Case 4: Large intervals
  //   Example: Start = 8:00 AM, Interval = 6 hours, Current = 3:00 PM
  //   - Time elapsed: 7 hours
  //   - Intervals passed: 7 ~/ 6 = 1 full interval (8:00 AM -> 2:00 PM)
  //   - Next occurrence: Start + (1 + 1) * 6 hours = 8:00 PM!
  static DateTime calculateNextOccurrence(Reminder reminder, DateTime now) {
    // Case 1 & 2: If 'now' is before or exactly at the startTime,
    // the next occurrence is simply the startTime.
    if (!now.isAfter(reminder.startTime)) {
      return reminder.startTime;
    }

    final int intervalMillis = reminder.interval.inMilliseconds;

    // Safety guard against non-positive intervals to prevent division by zero:
    if (intervalMillis <= 0) {
      return now.add(const Duration(minutes: 1));
    }

    // Case 3 & 4: 'now' is in the future compared to startTime.
    // Calculate how many full interval periods have elapsed since startTime:
    final Duration timeElapsed = now.difference(reminder.startTime);

    // Integer division (~/) gives the number of fully completed intervals:
    final int completedIntervals = timeElapsed.inMilliseconds ~/ intervalMillis;

    // The next occurrence is the next interval boundary after 'now':
    // nextTrigger = startTime + (completedIntervals + 1) * interval
    final int nextIntervalNumber = completedIntervals + 1;
    final Duration timeUntilNext = Duration(
      milliseconds: nextIntervalNumber * intervalMillis,
    );

    return reminder.startTime.add(timeUntilNext);
  }
}
