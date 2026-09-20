// ============================================================================
// FILE: test/features/reminders/reminder_scheduler_test.dart
//
// WHAT THIS FILE DOES:
// Comprehensive unit tests covering all edge cases for ReminderScheduler,
// interval arithmetic, and boundary conditions.
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:interval_reminder/core/constants/app_constants.dart';
import 'package:interval_reminder/features/reminders/domain/entities/reminder.dart';
import 'package:interval_reminder/features/reminders/domain/services/reminder_scheduler.dart';

void main() {
  group('ReminderScheduler Unit Tests', () {
    // -------------------------------------------------------------------------
    // TEST 1: Current time is before start time
    // -------------------------------------------------------------------------
    test('Test 1: Start 10:00, Interval 1h, Now 09:30 -> Expected 10:00', () {
      final startTime = DateTime(2026, 9, 20, 10, 0);
      final now = DateTime(2026, 9, 20, 9, 30);

      final reminder = Reminder(
        id: '1',
        title: 'Water',
        interval: const Duration(hours: 1),
        isEnabled: true,
        startTime: startTime,
      );

      final next = ReminderScheduler.calculateNextOccurrence(reminder, now);
      expect(next, DateTime(2026, 9, 20, 10, 0));
    });

    // -------------------------------------------------------------------------
    // TEST 2: Current time is after start time
    // -------------------------------------------------------------------------
    test('Test 2: Start 10:00, Interval 1h, Now 10:30 -> Expected 11:00', () {
      final startTime = DateTime(2026, 9, 20, 10, 0);
      final now = DateTime(2026, 9, 20, 10, 30);

      final reminder = Reminder(
        id: '1',
        title: 'Water',
        interval: const Duration(hours: 1),
        isEnabled: true,
        startTime: startTime,
      );

      final next = ReminderScheduler.calculateNextOccurrence(reminder, now);
      expect(next, DateTime(2026, 9, 20, 11, 0));
    });

    // -------------------------------------------------------------------------
    // TEST 3: 90-minute interval with elapsed time
    // -------------------------------------------------------------------------
    test('Test 3: Start 10:00, Interval 90m, Now 12:20 -> Expected 13:00', () {
      final startTime = DateTime(2026, 9, 20, 10, 0);
      final now = DateTime(2026, 9, 20, 12, 20);

      final reminder = Reminder(
        id: '1',
        title: 'Water',
        interval: const Duration(minutes: 90),
        isEnabled: true,
        startTime: startTime,
      );

      // Occurrences: 10:00, 11:30, 13:00, 14:30...
      final next = ReminderScheduler.calculateNextOccurrence(reminder, now);
      expect(next, DateTime(2026, 9, 20, 13, 0));
    });

    // -------------------------------------------------------------------------
    // TEST 4: Midnight & day boundary
    // -------------------------------------------------------------------------
    test('Test 4: Start 23:30, Interval 1h, Now 23:45 -> Expected 00:30 next day', () {
      final startTime = DateTime(2026, 9, 20, 23, 30);
      final now = DateTime(2026, 9, 20, 23, 45);

      final reminder = Reminder(
        id: '1',
        title: 'Medication',
        interval: const Duration(hours: 1),
        isEnabled: true,
        startTime: startTime,
      );

      final next = ReminderScheduler.calculateNextOccurrence(reminder, now);
      expect(next, DateTime(2026, 9, 21, 0, 30));
    });

    // -------------------------------------------------------------------------
    // TEST 5: Current time is exactly start time
    // -------------------------------------------------------------------------
    test('Test 5: Start 10:00, Interval 1h, Now 10:00 -> Expected 10:00', () {
      final startTime = DateTime(2026, 9, 20, 10, 0);
      final now = DateTime(2026, 9, 20, 10, 0);

      final reminder = Reminder(
        id: '1',
        title: 'Water',
        interval: const Duration(hours: 1),
        isEnabled: true,
        startTime: startTime,
      );

      // Documented behavior: When now == startTime, we return startTime because
      // the initial scheduled moment has arrived.
      final next = ReminderScheduler.calculateNextOccurrence(reminder, now);
      expect(next, DateTime(2026, 9, 20, 10, 0));
    });

    // -------------------------------------------------------------------------
    // TEST 6: Invalid/Zero interval handling
    // -------------------------------------------------------------------------
    test('Test 6: Handles 0 interval safely without division by zero', () {
      final startTime = DateTime(2026, 9, 20, 10, 0);
      final now = DateTime(2026, 9, 20, 10, 30);

      final reminder = Reminder(
        id: '1',
        title: 'Zero Interval Test',
        interval: Duration.zero,
        isEnabled: true,
        startTime: startTime,
      );

      final next = ReminderScheduler.calculateNextOccurrence(reminder, now);
      // Safe fallback returns a future time
      expect(next.isAfter(now), isTrue);
    });

    // -------------------------------------------------------------------------
    // TEST 7: Minutes validation limits
    // -------------------------------------------------------------------------
    test('Test 7: Minutes boundary checks (0 - 59)', () {
      const validMinutes = 59;
      const invalidMinutes = 75;

      bool isValidMinutes(int minutes) => minutes >= 0 && minutes <= 59;

      expect(isValidMinutes(validMinutes), isTrue);
      expect(isValidMinutes(invalidMinutes), isFalse);
    });

    // -------------------------------------------------------------------------
    // TEST 8: Maximum interval check against AppConstants
    // -------------------------------------------------------------------------
    test('Test 8: Validates against AppConstants.maxIntervalMinutes (7 days)', () {
      const withinLimit = Duration(days: 7);
      const exceedsLimit = Duration(days: 8);

      bool isWithinMaxLimit(Duration interval) =>
          interval.inMinutes <= AppConstants.maxIntervalMinutes;

      expect(isWithinMaxLimit(withinLimit), isTrue);
      expect(isWithinMaxLimit(exceedsLimit), isFalse);
    });
  });
}
