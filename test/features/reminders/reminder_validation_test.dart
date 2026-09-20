// ============================================================================
// FILE: test/features/reminders/reminder_validation_test.dart
//
// WHAT THIS FILE DOES:
// Unit tests verifying user input validation rules for creating and editing reminders.
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:interval_reminder/core/constants/app_constants.dart';

void main() {
  group('Reminder Form Validation Logic Tests', () {
    // -------------------------------------------------------------------------
    // TITLE VALIDATION
    // -------------------------------------------------------------------------
    String? validateTitle(String? value) {
      if (value == null || value.trim().isEmpty) {
        return 'Please enter a reminder title.';
      }
      return null;
    }

    test('Rejects empty or whitespace-only title', () {
      expect(validateTitle(''), 'Please enter a reminder title.');
      expect(validateTitle('   '), 'Please enter a reminder title.');
      expect(validateTitle(null), 'Please enter a reminder title.');
    });

    test('Accepts valid title', () {
      expect(validateTitle('Drink Water'), isNull);
      expect(validateTitle('Stretch'), isNull);
    });

    // -------------------------------------------------------------------------
    // MINUTES VALIDATION (0 - 59)
    // -------------------------------------------------------------------------
    String? validateMinutes(String? value) {
      if (value == null || value.trim().isEmpty) {
        return 'Enter minutes';
      }
      final parsed = int.tryParse(value.trim());
      if (parsed == null || parsed < 0 || parsed > 59) {
        return 'Minutes must be between 0 and 59';
      }
      return null;
    }

    test('Rejects minutes outside 0 - 59 range or non-numeric input', () {
      expect(validateMinutes('60'), 'Minutes must be between 0 and 59');
      expect(validateMinutes('75'), 'Minutes must be between 0 and 59');
      expect(validateMinutes('-5'), 'Minutes must be between 0 and 59');
      expect(validateMinutes('abc'), 'Minutes must be between 0 and 59');
      expect(validateMinutes(''), 'Enter minutes');
    });

    test('Accepts valid minutes (0 - 59)', () {
      expect(validateMinutes('0'), isNull);
      expect(validateMinutes('30'), isNull);
      expect(validateMinutes('59'), isNull);
    });

    // -------------------------------------------------------------------------
    // TOTAL INTERVAL VALIDATION (> 0 and <= Max Limit)
    // -------------------------------------------------------------------------
    String? validateInterval(int hours, int minutes) {
      final duration = Duration(hours: hours, minutes: minutes);
      if (duration.inMinutes <= 0) {
        return 'Interval must be greater than 0 minutes.';
      }
      if (duration.inMinutes > AppConstants.maxIntervalMinutes) {
        return 'Interval cannot exceed ${AppConstants.maxIntervalDays} days.';
      }
      return null;
    }

    test('Rejects 0 hours 0 minutes', () {
      expect(validateInterval(0, 0), 'Interval must be greater than 0 minutes.');
    });

    test('Rejects interval exceeding max limit (7 days)', () {
      expect(
        validateInterval(8 * 24, 0), // 8 days
        'Interval cannot exceed 7 days.',
      );
    });

    test('Accepts valid interval combinations', () {
      expect(validateInterval(0, 1), isNull); // 1 minute
      expect(validateInterval(1, 0), isNull); // 1 hour
      expect(validateInterval(1, 30), isNull); // 1 hour 30 mins
      expect(validateInterval(7 * 24, 0), isNull); // exactly 7 days
    });
  });
}
