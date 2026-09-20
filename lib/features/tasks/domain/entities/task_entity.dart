// ============================================================================
// FILE: lib/features/tasks/domain/entities/task_entity.dart
// FOLDER: lib/features/tasks/domain/entities/
//
// WHY THIS FOLDER EXISTS:
// In Clean Architecture, the 'domain' layer contains the core business concept.
// The 'entities' folder contains plain Dart objects representing the fundamental
// data models of this feature, independent of databases, network, or Flutter UI.
//
// RESPONSIBILITY:
// This file represents the core 'Task' entity in the Interval Reminder app.
// A Task is something the user wants to be reminded to do at regular intervals
// (e.g., "Drink water" every 60 minutes).
//
// WHAT CODE WILL EVENTUALLY GO HERE:
// - A Dart class 'TaskEntity' with properties such as:
//   - id (unique identifier)
//   - title (name of the task, e.g. "Drink water")
//   - intervalMinutes (frequency of reminders)
//   - isActive (whether the reminder is currently enabled)
//   - createdAt (timestamp)
//
// HOW THIS RELATES TO THE REST OF THE APP:
// - Used by the TaskRepository to return task data to presentation controllers.
// - Converted to/from data models in 'lib/features/tasks/data/models/'.
// - Displayed by UI widgets in 'lib/features/tasks/presentation/'.
//
// CURRENT STATUS:
// This file is currently a skeleton placeholder defining the entity concept.
// Full fields, constructors, and immutability methods are not implemented yet.
// ============================================================================

class TaskEntity {
  // Placeholder class establishing the Task domain entity.
  // Future fields:
  // final String id;
  // final String title;
  // final int intervalMinutes;
  // final bool isActive;
}
