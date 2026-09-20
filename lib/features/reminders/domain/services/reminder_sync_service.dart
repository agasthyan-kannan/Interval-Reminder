// ============================================================================
// FILE: lib/features/reminders/domain/services/reminder_sync_service.dart
// FOLDER: lib/features/reminders/domain/services/
//
// WHAT THIS FILE DOES:
// This coordinator service synchronizes the persistent reminder list with the
// device's native notification scheduler:
// - For every ENABLED reminder: calculates the next occurrence and schedules the alarm.
// - For every DISABLED reminder: cancels any pending alarms.
//
// WHY A SEPARATE COORDINATOR SERVICE EXISTS:
// In Clean Architecture, synchronizing business models with device services
// should NOT be written directly inside UI widgets (like HomeScreen).
// Having this coordinator service:
// 1. Keeps HomeScreen free of coordination loops.
// 2. Can be called on application startup, lifecycle resume, or background tasks.
// 3. Allows unit testing synchronization logic independently.
// ============================================================================

import 'package:flutter/foundation.dart';
import '../../../../core/services/notification_service.dart';
import '../entities/reminder.dart';
import 'reminder_scheduler.dart';

class ReminderSyncService {
  final NotificationService _notificationService;

  ReminderSyncService({NotificationService? notificationService})
      : _notificationService = notificationService ?? NotificationService();

  // ---------------------------------------------------------------------------
  // SYNCHRONIZE ALL REMINDERS WITH THE OPERATING SYSTEM
  // ---------------------------------------------------------------------------
  // Loops through all reminders and ensures only enabled reminders have
  // active scheduled notifications with the OS.
  Future<void> syncAllReminders(List<Reminder> reminders) async {
    final DateTime now = DateTime.now();
    debugPrint('ReminderSyncService: Starting synchronization for ${reminders.length} reminders...');

    for (final reminder in reminders) {
      try {
        if (reminder.isEnabled) {
          final DateTime nextOccurrence =
              ReminderScheduler.calculateNextOccurrence(reminder, now);

          await _notificationService.scheduleReminder(
            reminder: reminder,
            scheduledTime: nextOccurrence,
          );
        } else {
          // If disabled, ensure any previous alarm is cancelled
          await _notificationService.cancelReminder(reminder.id);
        }
      } catch (e) {
        // Individual error handling: one failed schedule does not abort the rest!
        debugPrint('ReminderSyncService: Failed to sync reminder ${reminder.id} (${reminder.title}): $e');
      }
    }

    debugPrint('ReminderSyncService: Synchronization complete.');
  }
}
