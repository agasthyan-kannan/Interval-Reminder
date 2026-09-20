// ============================================================================
// FILE: lib/features/tasks/presentation/screens/home_screen.dart
//
// WHAT THIS FILE DOES:
// This is the Home screen of the Interval Reminder app.
// It manages the list of reminders and now connects to a persistent
// ReminderRepository so that reminders survive application restarts!
//
// HOW PERSISTENCE WORKS ON THIS SCREEN:
// 1. When HomeScreen is first created, initState() calls _loadReminders().
// 2. While loading from local storage, a CircularProgressIndicator is displayed.
// 3. Once loaded, the reminders appear in the ListView.builder.
// 4. Whenever a reminder is ADDED, TOGGLED, or DELETED, we update both:
//    - The in-memory list (_reminders) via setState() for immediate UI update.
//    - The local storage via _repository.saveReminders() for persistence!
//
// WHY STORAGE CODE IS NOT DIRECTLY IN THIS WIDGET:
// Notice that this file has ZERO references to 'SharedPreferences' or 'jsonEncode'!
// The UI only knows about 'ReminderRepository'. If we change the storage engine
// from SharedPreferences to SQLite later, this screen will NOT need a single change!
// ============================================================================

import 'package:flutter/material.dart';
import '../../../reminders/domain/entities/reminder.dart';
import '../../../reminders/domain/repositories/reminder_repository.dart';
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
  // REPOSITORY INSTANCE
  // ---------------------------------------------------------------------------
  // We instantiate our repository implementation here.
  // HomeScreen interacts exclusively through the abstract ReminderRepository interface.
  final ReminderRepository _repository = ReminderRepositoryImpl();

  // In-memory list of reminders currently loaded in the UI
  final List<Reminder> _reminders = [];

  // ---------------------------------------------------------------------------
  // LOADING STATE
  // ---------------------------------------------------------------------------
  // Reading from local storage is asynchronous (takes time).
  // _isLoading starts as 'true' so we can show a CircularProgressIndicator
  // until the data has been read from disk.
  bool _isLoading = true;

  // ---------------------------------------------------------------------------
  // LIFECYCLE: initState()
  // ---------------------------------------------------------------------------
  // WHAT IS initState()?
  // initState() is called exactly once when this State object enters the widget tree.
  // It is the standard place to trigger initial data loading.
  //
  // WHY initState() CANNOT BE 'async':
  // Flutter's widget lifecycle requires initState() to execute synchronously
  // before the first build() call. Therefore, we call an asynchronous helper
  // function (_loadReminders()) from inside initState() without making initState() async!
  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  // ---------------------------------------------------------------------------
  // LOAD REMINDERS FROM STORAGE
  // ---------------------------------------------------------------------------
  // WHAT 'async' AND 'await' DO:
  // - Reading from disk takes time, so getReminders() returns a Future<List<Reminder>>.
  // - 'await' pauses execution until SharedPreferences reads and deserializes the data.
  // - Once finished, setState() stores the items and flips _isLoading to false.
  Future<void> _loadReminders() async {
    try {
      final loadedReminders = await _repository.getReminders();

      // Ensure the widget is still on screen before calling setState()
      if (!mounted) return;

      setState(() {
        _reminders.clear();
        _reminders.addAll(loadedReminders);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('HomeScreen: Error loading reminders: $e');
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
  // A centralized helper to persist the current _reminders list to storage.
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

      // Persist the updated list to local storage immediately!
      await _saveReminders();
    }
  }

  // ---------------------------------------------------------------------------
  // TOGGLING A REMINDER
  // ---------------------------------------------------------------------------
  void _toggleReminder(int index, bool isEnabled) async {
    setState(() {
      _reminders[index] = _reminders[index].copyWith(isEnabled: isEnabled);
    });

    // Save updated enabled status to storage
    await _saveReminders();
  }

  // ---------------------------------------------------------------------------
  // DELETING A REMINDER
  // ---------------------------------------------------------------------------
  void _deleteReminder(int index) async {
    setState(() {
      _reminders.removeAt(index);
    });

    // Save the list after deletion to ensure it stays deleted across restarts!
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

      // CONDITIONAL RENDERING:
      // 1. While loading from storage: Show CircularProgressIndicator.
      // 2. If finished and list is empty: Show empty state.
      // 3. If finished and list has items: Show ListView.builder!
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
