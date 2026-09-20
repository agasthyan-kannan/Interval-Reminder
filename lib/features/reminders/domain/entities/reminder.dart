// ============================================================================
// FILE: lib/features/reminders/domain/entities/reminder.dart
//
// WHAT THIS FILE DOES:
// This file defines the core 'Reminder' data model (entity) for our app.
// It serves as the single source of truth for what information a reminder holds.
//
// WHAT IS A CLASS?
// A class is a blueprint or template for creating objects.
// In our application, the 'Reminder' class defines the structure, and each
// individual reminder created by the user (e.g. "Drink Water every 1 hour")
// will be an object created from this blueprint.
// ============================================================================

class Reminder {
  // ---------------------------------------------------------------------------
  // PROPERTIES (FIELDS)
  // ---------------------------------------------------------------------------

  // WHY 'final' IS USED:
  // In Dart, 'final' means that once a value is assigned to this variable,
  // it can NEVER be changed (it is immutable).
  //
  // In modern Flutter architecture, making data models immutable prevents
  // unexpected bugs where one part of the app accidentally modifies an object
  // while another part is reading or rendering it.

  // 1. id: Unique identifier
  // - What it represents: A unique string (like a UUID or timestamp) that
  //   distinguishes this specific reminder from all others.
  // - Why String: IDs often combine numbers, letters, or hyphens (e.g. "rem_101").
  final String id;

  // 2. title: The main reminder name
  // - What it represents: The short, user-visible name of the task
  //   (e.g., "Drink Water", "Take a Break", "Stretch").
  // - Why String: Represents textual information.
  final String title;

  // 3. description: Optional additional details
  // - What it represents: Extra context or notes the user may want to add
  //   (e.g., "Drink at least 250ml of cold water").
  // - Why String? (Nullable String):
  //   The '?' question mark after String means this property is NULLABLE.
  //   A reminder does not require a description; if the user leaves it blank,
  //   this value can safely be 'null' (no value).
  final String? description;

  // 4. interval: How often the reminder repeats
  // - What it represents: The time gap between consecutive alerts
  //   (e.g., every 45 minutes, every 2 hours).
  // - Why Duration:
  //   'Duration' is a built-in Dart type specifically designed to represent
  //   a span of time. Using Duration is much safer and more powerful than
  //   storing text like "45 minutes", because Duration allows us to perform
  //   math directly (e.g., nextAlert = lastAlert + interval) and easily convert
  //   between minutes, hours, and seconds.
  final Duration interval;

  // 5. isEnabled: Active or paused state
  // - What it represents: Whether this reminder is currently active and triggering
  //   notifications, or paused by the user.
  // - Why bool: A boolean can only be either 'true' (active) or 'false' (paused).
  final bool isEnabled;

  // 6. startTime: When the reminder cycle begins
  // - What it represents: The exact date and time when this reminder starts
  //   counting its intervals.
  // - Why DateTime:
  //   'DateTime' represents a specific point in time on the calendar and clock
  //   (e.g., 2026-09-20 09:00:00). This is different from 'Duration', which is
  //   a length of elapsed time (e.g., 1 hour).
  final DateTime startTime;

  // ---------------------------------------------------------------------------
  // CONSTRUCTOR
  // ---------------------------------------------------------------------------

  // WHAT IS A CONSTRUCTOR?
  // A constructor is a special function used to create and initialize an object
  // from a class blueprint.
  //
  // WHY WE NEED IT:
  // Because all our properties are declared as 'final', they do not have values
  // by default. The constructor allows us to pass in the values when creating
  // each new Reminder object.
  //
  // 'const':
  // Adding 'const' allows Flutter and Dart to allocate this object at compile-time
  // if all of its inputs are constant values, improving runtime performance.
  //
  // NAMED PARAMETERS ({ ... }):
  // The curly braces define "named parameters". Instead of passing values by position,
  // we pass them by name (e.g., Reminder(id: '1', title: 'Water', ...)).
  // This makes the code much easier to read and prevents accidentally mixing up
  // the order of arguments.
  //
  // 'required':
  // In Dart with null safety, named parameters are optional by default.
  // Adding 'required' tells the Dart compiler that the caller MUST provide this
  // parameter. If they forget, the code will not compile.
  //
  // Notice that 'this.description' does NOT have 'required'.
  // Because its type is 'String?', it is optional and defaults to null if omitted!
  const Reminder({
    required this.id,
    required this.title,
    this.description,
    required this.interval,
    required this.isEnabled,
    required this.startTime,
  });

  // ---------------------------------------------------------------------------
  // COPYWITH METHOD: IMMUTABLE STATE UPDATES
  // ---------------------------------------------------------------------------
  // WHAT IS copyWith()?
  // Since all properties of Reminder are 'final', we cannot directly modify them
  // (e.g., reminder.isEnabled = false is NOT allowed by Dart).
  //
  // Instead, copyWith() creates and returns a BRAND NEW Reminder object, copying
  // all the existing values while replacing only the specific properties you pass in!
  //
  // WHY IMMUTABLE OBJECTS ARE USEFUL:
  // 1. Predictability: An object's values never change behind your back.
  // 2. Thread-safety & UI integrity: Flutter widgets can safely render this object
  //    without fear that another part of the code mutates it mid-frame.
  // 3. Clear state transitions: In setState(), assigning a new object (_reminders[i] = ...)
  //    makes it explicit that state has changed to a new snapshot.
  //
  // HOW THE '??' (IF-NULL) OPERATOR WORKS:
  // 'isEnabled ?? this.isEnabled' means:
  // "If a new isEnabled value was provided, use it. Otherwise, keep the current value!"
  Reminder copyWith({
    String? id,
    String? title,
    String? description,
    Duration? interval,
    bool? isEnabled,
    DateTime? startTime,
  }) {
    return Reminder(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      interval: interval ?? this.interval,
      isEnabled: isEnabled ?? this.isEnabled,
      startTime: startTime ?? this.startTime,
    );
  }
}
