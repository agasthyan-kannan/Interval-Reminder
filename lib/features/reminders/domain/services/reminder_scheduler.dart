// ============================================================================
// FILE: lib/features/reminders/domain/services/reminder_scheduler.dart
// FOLDER: lib/features/reminders/domain/services/
//
// WHAT THIS FILE DOES:
// This service contains pure mathematical scheduling logic for determining
// the exact next DateTime when an interval reminder should fire.
//
// SCHEDULING MATHEMATICS EXPLAINED (HOW IT WORKS):
// Suppose a user configures:
//   Start Time: 10:00 AM
//   Interval:   90 minutes (1h 30m)
//   Current:    12:20 PM
//
// The complete recurring sequence is:
//   1st alert: 10:00 AM
//   2nd alert: 11:30 AM (10:00 AM + 90 mins)
//   3rd alert: 1:00 PM  (11:30 AM + 90 mins)
//   4th alert: 2:30 PM  (1:00 PM  + 90 mins)
//
// To find the next occurrence from 12:20 PM without looping:
// 1. Calculate elapsed time:
//    elapsed = now.difference(startTime)
//    12:20 PM - 10:00 AM = 140 minutes elapsed.
//
// 2. Determine how many full intervals have already passed using integer division (~/):
//    intervalsPassed = 140 ~/ 90 = 1 (meaning the 10:00 and 11:30 alerts have passed).
//
// 3. The next occurrence is (intervalsPassed + 1) intervals from startTime:
//    nextOccurrence = startTime + (1 + 1) * 90 minutes
//                   = 10:00 AM + 180 minutes
//                   = 1:00 PM (13:00)!
//
// MIDNIGHT, MONTH, AND YEAR BOUNDARIES:
// Dart's built-in DateTime and Duration handle all calendar math automatically.
// For example, 11:30 PM + 1 hour automatically becomes 12:30 AM of the next day,
// properly incrementing the day, month, leap year, and year without manual string logic.
// ============================================================================

import '../entities/reminder.dart';

class ReminderScheduler {
  ReminderScheduler._();

  // ---------------------------------------------------------------------------
  // CALCULATE NEXT OCCURRENCE
  // ---------------------------------------------------------------------------
  // Returns the first DateTime >= now (or strictly in the future) when this
  // reminder should fire.
  //
  // PARAMETERS:
  // - reminder: The reminder entity containing startTime and interval Duration.
  // - now: The current reference time (usually DateTime.now()).
  static DateTime calculateNextOccurrence(Reminder reminder, DateTime now) {
    // -------------------------------------------------------------------------
    // CASE 1: Current time is BEFORE the start time
    // Example: Start = 10:00 AM, Now = 9:30 AM
    // The reminder cycle has not started yet. The first occurrence is startTime.
    // -------------------------------------------------------------------------
    if (now.isBefore(reminder.startTime)) {
      return reminder.startTime;
    }

    // -------------------------------------------------------------------------
    // CASE 2: Current time is EXACTLY the start time
    // Example: Start = 10:00 AM, Now = 10:00 AM
    // CHOSEN BEHAVIOR: We return startTime because this exact moment has arrived!
    // When the reminder is rescheduled after firing, 'now' will be past 10:00 AM,
    // which then moves to the subsequent interval.
    // -------------------------------------------------------------------------
    if (now.isAtSameMomentAs(reminder.startTime)) {
      return reminder.startTime;
    }

    final int intervalMillis = reminder.interval.inMilliseconds;

    // Safety guard against zero or negative intervals:
    if (intervalMillis <= 0) {
      return now.add(const Duration(minutes: 1));
    }

    // -------------------------------------------------------------------------
    // CASE 3 & 4: Current time is AFTER the start time
    // Example A: Start = 10:00 AM, Interval = 60m, Now = 12:20 PM -> Next = 1:00 PM
    // Example B: Start = 10:00 AM, Interval = 90m, Now = 12:20 PM -> Next = 1:00 PM
    // Example C: Start = 8:00 AM, Interval = 6h, Now = 3:00 PM   -> Next = 8:00 PM
    // -------------------------------------------------------------------------
    final Duration timeElapsed = now.difference(reminder.startTime);
    final int completedIntervals = timeElapsed.inMilliseconds ~/ intervalMillis;

    DateTime next = reminder.startTime.add(
      Duration(milliseconds: (completedIntervals + 1) * intervalMillis),
    );

    // -------------------------------------------------------------------------
    // DEFENSIVE CHECK: NEVER SCHEDULE IN THE PAST
    // Guarantee that the returned occurrence is strictly in the future (> now).
    // If due to execution latency 'next' is still <= now, advance by one interval.
    // -------------------------------------------------------------------------
    while (!next.isAfter(now)) {
      next = next.add(reminder.interval);
    }

    return next;
  }
}
