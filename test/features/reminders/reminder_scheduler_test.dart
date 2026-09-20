// ============================================================================
// FILE: test/features/reminders/reminder_scheduler_test.dart
//
// WHAT THIS FILE DOES:
// Tests all 4 scheduling cases in ReminderScheduler to verify mathematical correctness.
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:interval_reminder/features/reminders/domain/entities/reminder.dart';
import 'package:interval_reminder/features/reminders/domain/services/reminder_scheduler.dart';

void main() {
  group('ReminderScheduler.calculateNextOccurrence', () {
    // Case 1: Current time is before start time
    test('Case 1: returns startTime when now is before startTime', () {
      final startTime = DateTime(2026, 9, 20, 10, 0); // 10:00 AM
      final now = DateTime(2026, 9, 20, 9, 30); // 9:30 AM

      final reminder = Reminder(
        id: '1',
        title: 'Water',
        interval: const Duration(hours: 1),
        isEnabled: true,
        startTime: startTime,
      );

      final next = ReminderScheduler.calculateNextOccurrence(reminder, now);
      expect(next, DateTime(2026, 9, 20, 10, 0)); // 10:00 AM
    });

    // Case 2: Current time is exactly start time
    test('Case 2: returns startTime when now is exactly startTime', () {
      final startTime = DateTime(2026, 9, 20, 10, 0); // 10:00 AM
      final now = DateTime(2026, 9, 20, 10, 0); // 10:00 AM

      final reminder = Reminder(
        id: '1',
        title: 'Water',
        interval: const Duration(hours: 1),
        isEnabled: true,
        startTime: startTime,
      );

      final next = ReminderScheduler.calculateNextOccurrence(reminder, now);
      expect(next, DateTime(2026, 9, 20, 10, 0)); // 10:00 AM
    });

    // Case 3: Current time is after start time with a 1-hour interval
    test('Case 3: returns next interval boundary when now is after startTime', () {
      final startTime = DateTime(2026, 9, 20, 10, 0); // 10:00 AM
      final now = DateTime(2026, 9, 20, 12, 20); // 12:20 PM

      final reminder = Reminder(
        id: '1',
        title: 'Water',
        interval: const Duration(hours: 1),
        isEnabled: true,
        startTime: startTime,
      );

      final next = ReminderScheduler.calculateNextOccurrence(reminder, now);
      expect(next, DateTime(2026, 9, 20, 13, 0)); // 1:00 PM
    });

    // Case 4: Large interval (6 hours)
    test('Case 4: handles large intervals correctly', () {
      final startTime = DateTime(2026, 9, 20, 8, 0); // 8:00 AM
      final now = DateTime(2026, 9, 20, 15, 0); // 3:00 PM

      final reminder = Reminder(
        id: '1',
        title: 'Stretch',
        interval: const Duration(hours: 6),
        isEnabled: true,
        startTime: startTime,
      );

      final next = ReminderScheduler.calculateNextOccurrence(reminder, now);
      expect(next, DateTime(2026, 9, 20, 20, 0)); // 8:00 PM
    });
  });
}
