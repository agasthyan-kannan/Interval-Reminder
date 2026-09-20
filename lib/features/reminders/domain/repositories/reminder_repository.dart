// ============================================================================
// FILE: lib/features/reminders/domain/repositories/reminder_repository.dart
// FOLDER: lib/features/reminders/domain/repositories/
//
// WHY THIS FOLDER EXISTS:
// In Clean Architecture, the domain layer defines contracts (interfaces)
// for storing and querying reminder records without binding to a specific
// database or local storage mechanism.
//
// RESPONSIBILITY:
// This file declares the abstract contract for operations related to reminders
// (retrieving active reminders, saving reminder schedules, updating trigger times).
//
// WHAT CODE WILL EVENTUALLY GO HERE:
// - Abstract methods such as:
//   - Future<List<Reminder>> getActiveReminders();
//   - Future<void> saveReminder(Reminder reminder);
//   - Future<void> updateNextTrigger(String reminderId, DateTime nextTrigger);
//   - Future<void> deleteReminder(String id);
//
// HOW THIS RELATES TO THE REST OF THE APP:
// - Implemented by 'lib/features/reminders/data/repositories/reminder_repository_impl.dart'.
// - Used by the reminders controller and notification scheduler to manage alerts.
//
// CURRENT STATUS:
// This file is currently an abstract placeholder defining the repository interface.
// No data methods or storage logic are implemented yet.
// ============================================================================

import '../entities/reminder.dart';

abstract class ReminderRepository {
  // Placeholder repository contract for reminders.
}
