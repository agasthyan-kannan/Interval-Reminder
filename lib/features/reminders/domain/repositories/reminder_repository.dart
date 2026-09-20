// ============================================================================
// FILE: lib/features/reminders/domain/repositories/reminder_repository.dart
// FOLDER: lib/features/reminders/domain/repositories/
//
// WHY THIS FOLDER & FILE EXIST:
// In Clean Architecture, the domain layer defines 'contracts' (abstract classes
// or interfaces). The domain layer specifies WHAT operations the app can perform
// with data, but it intentionally does NOT care HOW or WHERE the data is stored
// (e.g. SharedPreferences, SQLite, Hive, or a remote server).
//
// WHY THIS ABSTRACTION IS USEFUL:
// 1. Decoupling: The UI (HomeScreen) only interacts with this abstract interface.
// 2. Flexibility: If we decide to migrate from SharedPreferences to SQLite or
//    Isar in the future, we only swap the data layer implementation without
//    rewriting a single line of UI code!
// 3. Testability: We can easily create a MockReminderRepository for unit testing.
// ============================================================================

import '../entities/reminder.dart';

abstract class ReminderRepository {
  // Retrieves all saved reminders from storage
  Future<List<Reminder>> getReminders();

  // Persists the complete list of reminders to storage
  Future<void> saveReminders(List<Reminder> reminders);
}
