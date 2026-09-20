// ============================================================================
// FILE: lib/features/reminders/data/repositories/reminder_repository_impl.dart
// FOLDER: lib/features/reminders/data/repositories/
//
// WHAT THIS FILE DOES:
// This file is the concrete implementation of the abstract ReminderRepository
// contract defined in the domain layer.
//
// WHY WE USE THE REPOSITORY PATTERN:
// Consider this architecture flow:
//
//   HomeScreen (UI)
//        ↓
//   ReminderRepository (Domain Contract)
//        ↓
//   ReminderRepositoryImpl (Data Layer Implementation)
//        ↓
//   ReminderLocalDataSource (Low-level Storage Driver)
//        ↓
//   SharedPreferences (Operating System Storage)
//
// 1. Separation of Concerns:
//    HomeScreen only knows: "I can ask for reminders and save reminders."
//    It does NOT know whether the data comes from SharedPreferences, SQLite,
//    Hive, or a cloud server!
// 2. Flexibility:
//    Later, if our app grows and we want to replace SharedPreferences with SQLite
//    or Isar, we only modify or replace this repository implementation.
//    HomeScreen does not need to change a single line of code!
// 3. Testability:
//    In unit tests, we can test business logic by passing a fake or mock repository
//    without touching actual device disk storage.
// ============================================================================

import '../../domain/entities/reminder.dart';
import '../../domain/repositories/reminder_repository.dart';
import '../datasources/reminder_local_data_source.dart';

class ReminderRepositoryImpl implements ReminderRepository {
  // Reference to our local data source
  final ReminderLocalDataSource localDataSource;

  // Constructor with optional parameter:
  // Allows passing a custom/mock data source, defaulting to the real one.
  ReminderRepositoryImpl({ReminderLocalDataSource? localDataSource})
      : localDataSource = localDataSource ?? ReminderLocalDataSource();

  // Retrieves the list of reminders from the local data source
  @override
  Future<List<Reminder>> getReminders() {
    return localDataSource.getReminders();
  }

  // Persists the list of reminders using the local data source
  @override
  Future<void> saveReminders(List<Reminder> reminders) {
    return localDataSource.saveReminders(reminders);
  }
}
