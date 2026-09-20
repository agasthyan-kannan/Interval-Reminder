// ============================================================================
// FILE: lib/features/tasks/presentation/screens/home_screen.dart
//
// WHAT THIS FILE DOES:
// This is the Home screen of the Interval Reminder app.
// It manages an in-memory list of reminders created by the user and displays:
// 1. An empty-state message if no reminders exist yet.
// 2. A scrollable list of ReminderCard widgets once reminders are created.
//
// WHY HomeScreen MUST BE A StatefulWidget:
// A StatelessWidget is immutable and cannot hold mutable data that changes over time.
//
// In our app, the user can create, toggle, and delete reminders while the app is
// running! The HomeScreen needs to maintain a list of reminders (_reminders).
// When an item is added, toggled, or deleted, we call setState() so that Flutter
// knows to trigger a rebuild and repaint the UI on screen.
//
// WHY THE LIST BELONGS IN State:
// In Flutter's architecture, state belongs to the widget that is directly responsible
// for displaying and manipulating that data. Since HomeScreen displays the list,
// it owns the list.
//
// PASSING DATA BETWEEN SCREENS WITHOUT PACKAGES:
// Notice how clean the data flow is:
// 1. HomeScreen opens AddReminderScreen with 'await Navigator.push()'.
// 2. AddReminderScreen creates the Reminder object and sends it back via
//    'Navigator.pop(context, reminder)'.
// 3. HomeScreen receives that Reminder object directly and adds it to its state!
// No external state-management package is required for this fundamental flow.
// ============================================================================

import 'package:flutter/material.dart';
import '../../../reminders/domain/entities/reminder.dart';
import '../../../reminders/presentation/screens/add_reminder_screen.dart';
import '../../../reminders/presentation/widgets/reminder_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ---------------------------------------------------------------------------
  // IN-MEMORY DATA STORAGE
  // ---------------------------------------------------------------------------
  // The list belongs to the Home Screen because the Home Screen is currently
  // responsible for displaying the reminders.
  //
  // Later, when our application becomes larger, we may move this responsibility
  // into a dedicated state-management layer or database. For now, keeping it here
  // makes the data flow easy to understand and learn.
  //
  // NOTE: Because this list is stored in RAM (in-memory), restarting the app
  // will reset this list to empty. This is expected until we add persistence!
  final List<Reminder> _reminders = [];

  // ---------------------------------------------------------------------------
  // NAVIGATION & RECEIVING RETURNED DATA
  // ---------------------------------------------------------------------------
  // WHAT 'Future', 'async', AND 'await' DO:
  // - Navigating to a new screen is an asynchronous action that takes time.
  // - Navigator.push() returns a Future<Reminder?>. A Future represents a value
  //   that will be available sometime in the future.
  // - 'await' pauses the execution of this method until the user closes
  //   AddReminderScreen and returns a result.
  //
  // WHAT NULLABLE 'Reminder?' MEANS:
  // - If the user tapped "Save Reminder", AddReminderScreen calls:
  //   Navigator.pop(context, newReminder) -> returns a valid Reminder object.
  // - If the user pressed the back button or cancelled, AddReminderScreen calls:
  //   Navigator.pop(context) -> returns null!
  // The '?' question mark handles both cases safely without runtime errors.
  Future<void> _navigateToAddReminder() async {
    final Reminder? reminder = await Navigator.push<Reminder>(
      context,
      MaterialPageRoute(
        builder: (context) => const AddReminderScreen(),
      ),
    );

    // If a reminder was returned, add it to our list inside setState()
    if (reminder != null) {
      // WHY setState() IS REQUIRED:
      // Modifying _reminders alone (_reminders.add(reminder)) updates the Dart list
      // in memory, but DOES NOT update the screen!
      //
      // Calling setState() tells Flutter:
      // "The state has changed! Please call build() again to repaint the UI."
      setState(() {
        _reminders.add(reminder);
      });
    }
  }

  // ---------------------------------------------------------------------------
  // TOGGLE REMINDER ENABLED / DISABLED
  // ---------------------------------------------------------------------------
  // WHY copyWith() IS USED HERE:
  // The Reminder class is IMMUTABLE (all its fields are 'final').
  // We cannot write: _reminders[index].isEnabled = isEnabled; (compile error).
  //
  // Instead, we use copyWith() to create a NEW Reminder object with the updated
  // isEnabled boolean, and replace the old object in the list inside setState().
  void _toggleReminder(int index, bool isEnabled) {
    setState(() {
      _reminders[index] = _reminders[index].copyWith(isEnabled: isEnabled);
    });
  }

  // ---------------------------------------------------------------------------
  // DELETE REMINDER
  // ---------------------------------------------------------------------------
  void _deleteReminder(int index) {
    setState(() {
      _reminders.removeAt(index);
    });
  }

  // ---------------------------------------------------------------------------
  // BUILD METHOD
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Interval Reminder'),
      ),

      // CONDITIONAL RENDERING:
      // Flutter lets you use standard Dart ternary operators (condition ? A : B)
      // to render completely different widget trees depending on current state:
      // - If _reminders.isEmpty: show the empty-state instructions.
      // - If _reminders.isNotEmpty: show the scrollable list of cards!
      body: _reminders.isEmpty ? _buildEmptyState() : _buildRemindersList(),

      // FloatingActionButton allows adding more reminders once the list has items
      floatingActionButton: _reminders.isNotEmpty
          ? FloatingActionButton(
              onPressed: _navigateToAddReminder,
              tooltip: 'Add Reminder',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  // ---------------------------------------------------------------------------
  // WIDGET BUILDER: EMPTY STATE
  // ---------------------------------------------------------------------------
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'No reminders yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create a reminder to get started.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _navigateToAddReminder,
            icon: const Icon(Icons.add),
            label: const Text('Add Reminder'),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // WIDGET BUILDER: REMINDERS LIST
  // ---------------------------------------------------------------------------
  // HOW ListView.builder() WORKS:
  // Rather than instantiating all widgets upfront, ListView.builder only creates
  // widgets that are currently visible on the screen.
  //
  // - 'itemCount': Tells Flutter how many total rows exist.
  // - 'itemBuilder': A factory callback that Flutter calls for each visible index (0, 1, 2...).
  Widget _buildRemindersList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _reminders.length,
      itemBuilder: (context, index) {
        final reminder = _reminders[index];

        // Pass the reminder and action callbacks to the reusable ReminderCard
        return ReminderCard(
          reminder: reminder,
          onToggle: (isEnabled) => _toggleReminder(index, isEnabled),
          onDelete: () => _deleteReminder(index),
        );
      },
    );
  }
}
