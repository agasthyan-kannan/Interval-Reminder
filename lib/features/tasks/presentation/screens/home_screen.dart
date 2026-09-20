// ============================================================================
// FILE: lib/features/tasks/presentation/screens/home_screen.dart
//
// WHAT THIS FILE DOES:
// This is the Home screen of the Interval Reminder app.
// It manages:
// 1. In-memory and persistent storage of reminders via ReminderRepository.
// 2. Scheduling and cancelling device notifications via NotificationService
//    and ReminderScheduler.
// 3. Displaying either an empty state or a scrollable list of ReminderCards.
//
// HOW THE SCHEDULING ARCHITECTURE WORKS ON THIS SCREEN:
// - On startup:
//   1. NotificationService initializes and requests permissions.
//   2. ReminderRepository loads all saved reminders from SharedPreferences.
//   3. For every ENABLED reminder, ReminderScheduler calculates the next occurrence,
//      and NotificationService schedules the notification with the operating system.
//   4. Any DISABLED reminder has its notification cancelled.
// - On adding a reminder:
//   If enabled, its next occurrence is calculated and scheduled.
// - On toggling a reminder:
//   If enabled -> calculate next occurrence & schedule.
//   If disabled -> cancel pending notification.
// - On deleting a reminder:
//   Immediately cancel its pending notification and remove it from storage.
//
// SEPARATION OF CONCERNS:
// Notice how clean this screen remains!
// - Calculation algorithm lives in ReminderScheduler (domain layer).
// - Notification mechanics live in NotificationService (core layer).
// - Storage lives in ReminderRepository (data layer).
// - HomeScreen merely coordinates these three services in response to user actions.
// ============================================================================

import 'package:flutter/material.dart';
import '../../../../core/services/notification_service.dart';
import '../../../reminders/domain/entities/reminder.dart';
import '../../../reminders/domain/repositories/reminder_repository.dart';
import '../../../reminders/domain/services/reminder_scheduler.dart';
import '../../../reminders/data/repositories/reminder_repository_impl.dart';
import '../../../reminders/presentation/screens/add_reminder_screen.dart';
import '../../../reminders/presentation/widgets/reminder_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ---------------------------------------------------------------------------
  // SERVICES
  // ---------------------------------------------------------------------------
  final ReminderRepository _repository = ReminderRepositoryImpl();
  final NotificationService _notificationService = NotificationService();

  // In-memory list of reminders currently loaded in the UI
  final List<Reminder> _reminders = [];

  // Loading state flag to display CircularProgressIndicator
  bool _isLoading = true;

  // ---------------------------------------------------------------------------
  // LIFECYCLE: initState()
  // ---------------------------------------------------------------------------
  @override
  void initState() {
    super.initState();
    _initializeAndLoad();
  }

  // ---------------------------------------------------------------------------
  // INITIALIZATION: RESTORE & SCHEDULE NOTIFICATIONS
  // ---------------------------------------------------------------------------
  // AVOIDING DUPLICATE NOTIFICATIONS ON STARTUP:
  // When the app starts, we iterate through all saved reminders.
  // Because NotificationService uses deterministic, stable notification IDs
  // derived from reminder.id, re-scheduling an existing reminder simply updates
  // or replaces any pending alarm for that ID instead of creating duplicates!
  Future<void> _initializeAndLoad() async {
    try {
      // 1. Initialize notification channel & timezone database
      await _notificationService.initialize();

      // 2. Request notification permissions (Android 13+ & iOS)
      await _notificationService.requestPermissions();

      // 3. Load saved reminders from local storage
      final loadedReminders = await _repository.getReminders();

      // 4. Synchronize notifications with the operating system
      final now = DateTime.now();
      for (final reminder in loadedReminders) {
        if (reminder.isEnabled) {
          final nextOccurrence =
              ReminderScheduler.calculateNextOccurrence(reminder, now);

          await _notificationService.scheduleReminder(
            reminder: reminder,
            scheduledTime: nextOccurrence,
          );
        } else {
          // If the reminder is disabled, make sure no old notification is pending
          await _notificationService.cancelReminder(reminder.id);
        }
      }

      if (!mounted) return;

      setState(() {
        _reminders.clear();
        _reminders.addAll(loadedReminders);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('HomeScreen: Error initializing and loading reminders: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ---------------------------------------------------------------------------
  // SAVE REMINDERS HELPER
  // ---------------------------------------------------------------------------
  Future<void> _saveReminders() async {
    try {
      await _repository.saveReminders(_reminders);
    } catch (e) {
      debugPrint('HomeScreen: Error saving reminders: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // NAVIGATION & ADDING A REMINDER
  // ---------------------------------------------------------------------------
  Future<void> _navigateToAddReminder() async {
    final Reminder? reminder = await Navigator.push<Reminder>(
      context,
      MaterialPageRoute(
        builder: (context) => const AddReminderScreen(),
      ),
    );

    if (reminder != null) {
      setState(() {
        _reminders.add(reminder);
      });

      // 1. Persist to storage
      await _saveReminders();

      // 2. Schedule notification with OS if enabled
      if (reminder.isEnabled) {
        final nextOccurrence = ReminderScheduler.calculateNextOccurrence(
          reminder,
          DateTime.now(),
        );

        await _notificationService.scheduleReminder(
          reminder: reminder,
          scheduledTime: nextOccurrence,
        );
      }
    }
  }

  // ---------------------------------------------------------------------------
  // TOGGLING A REMINDER
  // ---------------------------------------------------------------------------
  void _toggleReminder(int index, bool isEnabled) async {
    final updatedReminder = _reminders[index].copyWith(isEnabled: isEnabled);

    setState(() {
      _reminders[index] = updatedReminder;
    });

    // 1. Update storage
    await _saveReminders();

    // 2. Update OS scheduled notifications
    if (isEnabled) {
      // Calculate when the next reminder should occur and schedule it
      final nextOccurrence = ReminderScheduler.calculateNextOccurrence(
        updatedReminder,
        DateTime.now(),
      );

      await _notificationService.scheduleReminder(
        reminder: updatedReminder,
        scheduledTime: nextOccurrence,
      );
    } else {
      // Cancel the pending notification from the OS queue
      await _notificationService.cancelReminder(updatedReminder.id);
    }
  }

  // ---------------------------------------------------------------------------
  // DELETING A REMINDER
  // ---------------------------------------------------------------------------
  void _deleteReminder(int index) async {
    final reminderToDelete = _reminders[index];

    // 1. Cancel the notification from the OS queue first
    await _notificationService.cancelReminder(reminderToDelete.id);

    // 2. Remove from in-memory list
    setState(() {
      _reminders.removeAt(index);
    });

    // 3. Persist the updated list to storage
    await _saveReminders();
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

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reminders.isEmpty
              ? _buildEmptyState()
              : _buildRemindersList(),

      floatingActionButton: (!_isLoading && _reminders.isNotEmpty)
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
  Widget _buildRemindersList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _reminders.length,
      itemBuilder: (context, index) {
        final reminder = _reminders[index];

        return ReminderCard(
          reminder: reminder,
          onToggle: (isEnabled) => _toggleReminder(index, isEnabled),
          onDelete: () => _deleteReminder(index),
        );
      },
    );
  }
}
