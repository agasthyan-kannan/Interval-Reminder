// ============================================================================
// FILE: test/features/reminders/reminder_test.dart
//
// WHAT THIS FILE DOES:
// This file contains a basic unit test to verify that our 'Reminder' model
// can be instantiated correctly with expected property values.
//
// WHAT IS A UNIT TEST?
// A unit test is an automated test that checks a small, isolated piece ("unit")
// of code—such as a single function, method, or class—to ensure it behaves as intended.
// Unit tests run very fast and give developers confidence that changes won't break
// existing features.
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:interval_reminder/features/reminders/domain/entities/reminder.dart';

void main() {
  // WHAT test() DOES:
  // test() is a function provided by the 'flutter_test' package.
  // It defines an individual test case with two main arguments:
  // 1. A descriptive title string ("should create a valid Reminder instance").
  // 2. A callback function containing the actual test code and assertions.
  test('should create a valid Reminder instance with expected values', () {
    // 1. ARRANGE: Set up the test data
    final now = DateTime(2026, 9, 20, 9, 0);
    const oneHour = Duration(hours: 1);

    // 2. ACT: Create an instance of the Reminder class
    final reminder = Reminder(
      id: 'rem_1',
      title: 'Drink Water',
      description: 'Drink a glass of water',
      interval: oneHour,
      isEnabled: true,
      startTime: now,
    );

    // 3. ASSERT: Verify the results using expect()
    //
    // WHAT expect() DOES:
    // expect() compares the actual value (the first argument) to an expected
    // matcher (the second argument). If they match, the test passes!
    // If they do not match, expect() throws an error and marks the test as failed.
    expect(reminder.id, 'rem_1');
    expect(reminder.title, 'Drink Water');
    expect(reminder.description, 'Drink a glass of water');
    expect(reminder.interval, const Duration(minutes: 60));
    expect(reminder.isEnabled, isTrue);
    expect(reminder.startTime, now);
  });
}
