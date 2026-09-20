// ============================================================================
// FILE: lib/features/tasks/domain/repositories/task_repository.dart
// FOLDER: lib/features/tasks/domain/repositories/
//
// WHY THIS FOLDER EXISTS:
// In Clean Architecture, the domain layer defines 'contracts' (interfaces or
// abstract classes) for data operations. The domain layer doesn't care whether
// data comes from SQLite, Hive, SharedPreferences, or an API. It only defines
// WHAT operations are possible.
//
// RESPONSIBILITY:
// This file declares the abstract contract for Task data operations
// (fetching tasks, creating a task, updating a task, deleting a task).
//
// WHAT CODE WILL EVENTUALLY GO HERE:
// - Abstract methods such as:
//   - Future<List<TaskEntity>> getTasks();
//   - Future<void> saveTask(TaskEntity task);
//   - Future<void> deleteTask(String id);
//   - Future<void> toggleTaskStatus(String id, bool isActive);
//
// HOW THIS RELATES TO THE REST OF THE APP:
// - Implemented by 'lib/features/tasks/data/repositories/task_repository_impl.dart'.
// - Consumed by presentation controllers ('tasks_controller.dart') to perform
//   operations without depending directly on database code.
//
// CURRENT STATUS:
// This file is currently an abstract placeholder defining the repository contract.
// No data operations or queries are implemented yet.
// ============================================================================

import '../entities/task_entity.dart';

abstract class TaskRepository {
  // Placeholder methods to be implemented in the future:
  // Future<List<TaskEntity>> getAllTasks();
  // Future<void> addTask(TaskEntity task);
  // Future<void> deleteTask(String id);
}
