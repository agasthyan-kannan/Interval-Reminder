// ============================================================================
// FILE: test/core/date_time_utils_test.dart
//
// WHAT THIS FILE DOES:
// Unit tests verifying interval duration formatting and time string formatting
// in DateTimeUtils.
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:interval_reminder/core/utils/date_time_utils.dart';

void main() {
  group('DateTimeUtils Unit Tests', () {
    // -------------------------------------------------------------------------
    // INTERVAL FORMATTING TESTS
    // -------------------------------------------------------------------------
    group('formatInterval()', () {
      test('Formats exact single hour correctly', () {
        expect(
          DateTimeUtils.formatInterval(const Duration(hours: 1)),
          'Every 1 hour',
        );
      });

      test('Formats multiple hours correctly', () {
        expect(
          DateTimeUtils.formatInterval(const Duration(hours: 3)),
          'Every 3 hours',
        );
      });

      test('Formats combined hours and minutes correctly', () {
        expect(
          DateTimeUtils.formatInterval(const Duration(hours: 1, minutes: 30)),
          'Every 1h 30m',
        );
        expect(
          DateTimeUtils.formatInterval(const Duration(hours: 2, minutes: 15)),
          'Every 2h 15m',
        );
      });

      test('Formats exact single minute correctly', () {
        expect(
          DateTimeUtils.formatInterval(const Duration(minutes: 1)),
          'Every 1 minute',
        );
      });

      test('Formats multiple minutes correctly', () {
        expect(
          DateTimeUtils.formatInterval(const Duration(minutes: 45)),
          'Every 45 minutes',
        );
      });
    });

    // -------------------------------------------------------------------------
    // TIME FORMATTING TESTS (12-hour AM/PM)
    // -------------------------------------------------------------------------
    group('formatTime()', () {
      test('Formats morning AM times correctly', () {
        final morning = DateTime(2026, 9, 20, 9, 5);
        expect(DateTimeUtils.formatTime(morning), '9:05 AM');

        final tenAm = DateTime(2026, 9, 20, 10, 0);
        expect(DateTimeUtils.formatTime(tenAm), '10:00 AM');
      });

      test('Formats noon and afternoon PM times correctly', () {
        final noon = DateTime(2026, 9, 20, 12, 0);
        expect(DateTimeUtils.formatTime(noon), '12:00 PM');

        final afternoon = DateTime(2026, 9, 20, 14, 30);
        expect(DateTimeUtils.formatTime(afternoon), '2:30 PM');

        final night = DateTime(2026, 9, 20, 23, 45);
        expect(DateTimeUtils.formatTime(night), '11:45 PM');
      });

      test('Formats midnight as 12:00 AM', () {
        final midnight = DateTime(2026, 9, 20, 0, 0);
        expect(DateTimeUtils.formatTime(midnight), '12:00 AM');

        final midnightThirty = DateTime(2026, 9, 20, 0, 30);
        expect(DateTimeUtils.formatTime(midnightThirty), '12:30 AM');
      });
    });
  });
}
