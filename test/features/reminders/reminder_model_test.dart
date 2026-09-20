// ============================================================================
// FILE: test/features/reminders/reminder_model_test.dart
//
// WHAT THIS FILE DOES:
// Unit tests verifying serialization (toJson), deserialization (fromJson),
// and immutable copy-on-write (copyWith) behavior for the Reminder model.
// ============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:interval_reminder/features/reminders/domain/entities/reminder.dart';

void main() {
  group('Reminder Model Serialization & Immutability Tests', () {
    // -------------------------------------------------------------------------
    // TEST 1: Round-trip serialization (Reminder -> JSON Map -> Reminder)
    // -------------------------------------------------------------------------
    test('Round-trip toJson() and fromJson() preserves all properties', () {
      final original = Reminder(
        id: 'rem_123',
        title: 'Drink Water',
        description: 'Stay hydrated',
        interval: const Duration(hours: 1, minutes: 30),
        isEnabled: true,
        startTime: DateTime(2026, 9, 20, 10, 0),
      );

      // 1. Serialize to Map
      final jsonMap = original.toJson();

      expect(jsonMap['id'], 'rem_123');
      expect(jsonMap['title'], 'Drink Water');
      expect(jsonMap['description'], 'Stay hydrated');
      expect(jsonMap['intervalMinutes'], 90);
      expect(jsonMap['isEnabled'], isTrue);
      expect(jsonMap['startTime'], '2026-09-20T10:00:00.000');

      // 2. Deserialize back to Reminder object
      final reconstructed = Reminder.fromJson(jsonMap);

      expect(reconstructed.id, original.id);
      expect(reconstructed.title, original.title);
      expect(reconstructed.description, original.description);
      expect(reconstructed.interval, original.interval);
      expect(reconstructed.isEnabled, original.isEnabled);
      expect(reconstructed.startTime, original.startTime);
    });

    // -------------------------------------------------------------------------
    // TEST 2: Nullable description handling
    // -------------------------------------------------------------------------
    test('Handles null description correctly in toJson() and fromJson()', () {
      final original = Reminder(
        id: 'rem_456',
        title: 'Take Break',
        description: null, // Null description
        interval: const Duration(minutes: 45),
        isEnabled: false,
        startTime: DateTime(2026, 9, 20, 14, 0),
      );

      final jsonMap = original.toJson();
      expect(jsonMap['description'], isNull);

      final reconstructed = Reminder.fromJson(jsonMap);
      expect(reconstructed.description, isNull);
      expect(reconstructed.title, 'Take Break');
      expect(reconstructed.isEnabled, isFalse);
    });

    // -------------------------------------------------------------------------
    // TEST 3: copyWith() creates new object with modified values
    // -------------------------------------------------------------------------
    test('copyWith() returns new instance with updated properties', () {
      final original = Reminder(
        id: 'rem_789',
        title: 'Original Title',
        description: 'Original Description',
        interval: const Duration(hours: 1),
        isEnabled: true,
        startTime: DateTime(2026, 9, 20, 9, 0),
      );

      final updated = original.copyWith(
        title: 'Updated Title',
        isEnabled: false,
      );

      // Verify updated fields
      expect(updated.title, 'Updated Title');
      expect(updated.isEnabled, isFalse);

      // Verify untouched fields retained original values
      expect(updated.id, original.id);
      expect(updated.description, original.description);
      expect(updated.interval, original.interval);
      expect(updated.startTime, original.startTime);
    });
  });
}
