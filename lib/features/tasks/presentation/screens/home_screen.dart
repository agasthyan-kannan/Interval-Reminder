// ============================================================================
// FILE: lib/features/tasks/presentation/screens/home_screen.dart
//
// WHAT THIS FILE DOES:
// This is the Home screen of the Interval Reminder app.
// It manages:
// 1. In-memory and persistent storage of reminders via ReminderRepository.
// 2. Lifecycle observation (WidgetsBindingObserver) to check permissions and
//    synchronize notifications when the app returns to the foreground.
// 3. UI feedback if notification permissions are denied.
// 4. User actions: Add, Edit, Toggle, and Delete reminders.
//
// APP LIFECYCLE VS OPERATING SYSTEM NOTIFICATION SCHEDULING:
// - Flutter App Lifecycle: Governs the state of the Flutter Dart VM when the user
//   opens, minimizes, or closes the app (resumed, paused, detached).
// - OS Notification Scheduler: Android AlarmManager & iOS Notification Center run
//   independently of Flutter. Even when the app is completely CLOSED or killed,
//   the operating system kernel wakes up and displays the notification!
//
// WHY WE DO NOT USE Timer.periodic():
// A Dart Timer only runs while the Flutter app is alive in the foreground.
// Android terminates background apps to conserve battery, which immediately kills
// any active Dart timers. Scheduled OS notifications are the only reliable way.
// ============================================================================

import 'package:flutter/material.dart';
import '../../../../core/services/notification_service.dart';
import '../../../reminders/domain/entities/reminder.dart';
import '../../../reminders/domain/repositories/reminder_repository.dart';
import '../../../reminders/domain/services/reminder_scheduler.dart';
import '../../../reminders/domain/services/reminder_sync_service.dart';
import '../../../reminders/data/repositories/reminder_repository_impl.dart';
import '../../../reminders/presentation/screens/add_reminder_screen.dart';
import '../../../reminders/presentation/widgets/reminder_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// WidgetsBindingObserver allows this State object to listen for operating system
// lifecycle events (e.g. app minimized, app resumed to foreground).
class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  // ---------------------------------------------------------------------------
  // SERVICES
  // ---------------------------------------------------------------------------
  final ReminderRepository _repository = ReminderRepositoryImpl();
  final NotificationService _notificationService = NotificationService();
  late final ReminderSyncService _syncService;

  // In-memory list of reminders currently displayed
  final List<Reminder> _reminders = [];

  // Loading state flag to display CircularProgressIndicator during initial read
  bool _isLoading = true;

  // Tracks whether notification permission is currently granted by the user
  bool _hasNotificationPermission = true;

  // ---------------------------------------------------------------------------
  // LIFECYCLE: initState & dispose
  // ---------------------------------------------------------------------------
  @override
  void initState() {
    super.initState();
    // Register this State object as a lifecycle observer
    WidgetsBinding.instance.addObserver(this);

    _syncService = ReminderSyncService(
      notificationService: _notificationService,
    );

    _initializeAndLoad();
  }

  @override
  void dispose() {
    // Unregister observer to prevent memory leaks when widget is destroyed
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // APP LIFECYCLE STATE CHANGES
  // ---------------------------------------------------------------------------
  // WHAT AppLifecycleState MEANS:
  // - resumed: App is visible and responding to user input.
  // - inactive: App is in an inactive state (e.g. phone call, system dialog).
  // - paused: App is running in the background (user pressed Home button).
  // - detached: App is detached from Flutter host engine (closing).
  // - hidden: App is minimized/hidden.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // When the user returns to the app from the background or phone settings:
    if (state == AppLifecycleState.resumed) {
      debugPrint('HomeScreen: App resumed. Checking permissions and resyncing...');
      _checkPermissionsAndResync();
    }
  }

  // ---------------------------------------------------------------------------
  // INITIALIZATION: STARTUP FLOW
  // ---------------------------------------------------------------------------
  // STARTUP FLOW:
  // 1. Initialize NotificationService (channels, timezone DB).
  // 2. Request runtime notification permissions.
  // 3. Load saved reminders from SharedPreferences.
  // 4. Synchronize all enabled reminders via ReminderSyncService.
  // 5. Update UI state.
  Future<void> _initializeAndLoad() async {
    try {
      await _notificationService.initialize();
      final bool permissionGranted =
          await _notificationService.requestPermissions();

      final loadedReminders = await _repository.getReminders();

      // Synchronize alarms with the operating system
      await _syncService.syncAllReminders(loadedReminders);

      if (!mounted) return;

      setState(() {
        _hasNotificationPermission = permissionGranted;
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

  // Checks permission and synchronizes when returning from device settings
  Future<void> _checkPermissionsAndResync() async {
    final bool permissionGranted =
        await _notificationService.areNotificationsGranted();

    if (mounted) {
      setState(() {
        _hasNotificationPermission = permissionGranted;
      });
    }

    if (permissionGranted) {
      await _syncService.syncAllReminders(_reminders);
    }
  }

  // Centralized helper to save the current _reminders list to SharedPreferences
  Future<void> _saveReminders() async {
    try {
      await _repository.saveReminders(_reminders);
    } catch (e) {
      debugPrint('HomeScreen: Error saving reminders to storage: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to save reminders. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ---------------------------------------------------------------------------
  // 1. CREATE REMINDER
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

      // 2. Schedule notification if enabled
      if (reminder.isEnabled) {
        try {
          final nextOccurrence = ReminderScheduler.calculateNextOccurrence(
            reminder,
            DateTime.now(),
          );

          await _notificationService.scheduleReminder(
            reminder: reminder,
            scheduledTime: nextOccurrence,
          );
        } catch (e) {
          debugPrint('HomeScreen: Failed to schedule reminder ${reminder.id}: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Reminder was saved, but notification scheduling failed. Please check notification permissions.',
                ),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      }
    }
  }

  // ---------------------------------------------------------------------------
  // 2. EDIT REMINDER
  // ---------------------------------------------------------------------------
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
      // 1. Cancel the old notification first
      await _notificationService.cancelReminder(oldReminder.id);

      // 2. Update list in state
      setState(() {
        _reminders[index] = updatedReminder;
      });

      // 3. Persist updated list to storage
      await _saveReminders();

      // 4. Reschedule if enabled
      if (updatedReminder.isEnabled) {
        try {
          final nextOccurrence = ReminderScheduler.calculateNextOccurrence(
            updatedReminder,
            DateTime.now(),
          );

          await _notificationService.scheduleReminder(
            reminder: updatedReminder,
            scheduledTime: nextOccurrence,
          );
        } catch (e) {
          debugPrint('HomeScreen: Failed to reschedule reminder ${updatedReminder.id}: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Reminder was updated, but notification scheduling failed. Please check notification permissions.',
                ),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
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

    await _saveReminders();

    if (isEnabled) {
      try {
        final nextOccurrence = ReminderScheduler.calculateNextOccurrence(
          updatedReminder,
          DateTime.now(),
        );

        await _notificationService.scheduleReminder(
          reminder: updatedReminder,
          scheduledTime: nextOccurrence,
        );
      } catch (e) {
        debugPrint('HomeScreen: Error enabling reminder notification: $e');
      }
    } else {
      await _notificationService.cancelReminder(updatedReminder.id);
    }
  }

  // ---------------------------------------------------------------------------
  // 4. DELETE REMINDER
  // ---------------------------------------------------------------------------
  void _deleteReminder(int index) async {
    final reminderToDelete = _reminders[index];

    // 1. Cancel the notification from the OS queue
    await _notificationService.cancelReminder(reminderToDelete.id);

    // 2. Remove from in-memory list
    setState(() {
      _reminders.removeAt(index);
    });

    // 3. Persist updated list to storage
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

      body: Column(
        children: [
          // USER-FRIENDLY PERMISSION WARNING BANNER:
          // If the user denied notification permission, display a non-intrusive warning
          if (!_hasNotificationPermission) _buildPermissionWarningBanner(),

          // Main body content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _reminders.isEmpty
                    ? _buildEmptyState()
                    : _buildRemindersList(),
          ),
        ],
      ),

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
  // WIDGET BUILDER: PERMISSION WARNING BANNER
  // ---------------------------------------------------------------------------
  Widget _buildPermissionWarningBanner() {
    return Container(
      color: Colors.amber.shade100,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange.shade800),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Notifications are disabled. Enable notification permission in device settings to receive interval reminders.',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
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
