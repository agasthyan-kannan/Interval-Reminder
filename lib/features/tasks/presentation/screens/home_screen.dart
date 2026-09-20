// ============================================================================
// FILE: lib/features/tasks/presentation/screens/home_screen.dart
//
// WHAT THIS FILE DOES:
// This is the Home screen of the Interval Reminder app.
// It manages:
// 1. In-memory and persistent storage of reminders via ReminderRepository.
// 2. Scheduling, updating, and cancelling device notifications via
//    NotificationService and ReminderScheduler.
// 3. Navigation to AddReminderScreen for both CREATING and EDITING reminders.
// 4. Displaying either an empty state or a scrollable list of ReminderCards.
//
// NOTIFICATION RESCHEDULING DURING EDITING:
// When a user edits a reminder (e.g. changing interval from 1 hour to 2 hours):
// 1. We cancel the old scheduled notification using the reminder's stable ID.
// 2. We update the in-memory list and local storage.
// 3. If the reminder is enabled, we calculate the NEW next occurrence and
//    schedule the new notification with the operating system.
// Cancelling before rescheduling guarantees that no duplicate or orphaned
// alarms remain active in Android AlarmManager!
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
  // 1. CREATE REMINDER
  // ---------------------------------------------------------------------------
  Future<void> _navigateToAddReminder() async {
    // Opens AddReminderScreen in CREATE mode (reminderToEdit is null)
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

      // Persist to storage
      await _saveReminders();

      // Schedule notification with OS if enabled
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
  // 2. EDIT REMINDER
  // ---------------------------------------------------------------------------
  // WHAT THIS METHOD DOES:
  // Opens AddReminderScreen in EDIT mode by passing the existing reminder.
  // When the user saves their changes, it cancels the old notification,
  // updates the list, persists to disk, and reschedules if enabled.
  Future<void> _navigateToEditReminder(int index) async {
    final oldReminder = _reminders[index];

    final Reminder? updatedReminder = await Navigator.push<Reminder>(
      context,
      MaterialPageRoute(
        builder: (context) => AddReminderScreen(
          reminderToEdit: oldReminder,
        ),
      ),
    );

    if (updatedReminder != null) {
      // 1. CANCEL THE OLD NOTIFICATION:
      // The time or interval may have changed, so cancel the previous alarm first.
      await _notificationService.cancelReminder(oldReminder.id);

      // 2. UPDATE IN-MEMORY LIST:
      setState(() {
        _reminders[index] = updatedReminder;
      });

      // 3. PERSIST UPDATED LIST TO STORAGE:
      await _saveReminders();

      // 4. RESCHEDULE IF ENABLED:
      if (updatedReminder.isEnabled) {
        final nextOccurrence = ReminderScheduler.calculateNextOccurrence(
          updatedReminder,
          DateTime.now(),
        );

        await _notificationService.scheduleReminder(
          reminder: updatedReminder,
          scheduledTime: nextOccurrence,
        );
      }
    }
  }

  // ---------------------------------------------------------------------------
  // 3. TOGGLE REMINDER
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
  // 4. DELETE REMINDER
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
          onEdit: () => _navigateToEditReminder(index),
          onDelete: () => _deleteReminder(index),
        );
      },
    );
  }
}
