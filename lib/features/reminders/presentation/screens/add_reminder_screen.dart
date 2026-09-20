// ============================================================================
// FILE: lib/features/reminders/presentation/screens/add_reminder_screen.dart
//
// WHAT THIS FILE DOES:
// This screen handles both CREATING a new reminder and EDITING an existing reminder:
// - If 'reminderToEdit == null': CREATE MODE ("Add Reminder", empty form).
// - If 'reminderToEdit != null': EDIT MODE ("Edit Reminder", pre-populated form).
//
// WHY REUSING A SINGLE SCREEN IS BETTER THAN CREATING TWO SCREENS:
// 1. Code Reusability: 95% of the UI (TextFormFields, validation logic, time picker)
//    is identical between creating and editing.
// 2. Maintainability: If we add a new field (like sound selection) in the future,
//    we only update it in this one file rather than maintaining two duplicate screens!
//
// WHY PRESERVING THE ID IS CRUCIAL IN EDIT MODE:
// When editing, we MUST retain the existing reminder.id!
// The notification ID is derived from the reminder's ID:
// reminder.id -> notificationId (31-bit integer).
// If we generated a new ID when editing, the old notification alarm would be
// orphaned in the Android system and could never be cancelled!
// ============================================================================

import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/reminder.dart';

class AddReminderScreen extends StatefulWidget {
  // Optional reminder passed when opening in Edit mode
  final Reminder? reminderToEdit;

  const AddReminderScreen({
    super.key,
    this.reminderToEdit,
  });

  @override
  State<AddReminderScreen> createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends State<AddReminderScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _hoursController;
  late final TextEditingController _minutesController;

  late TimeOfDay _selectedTime;

  // Convenience getter to check current mode
  bool get _isEditMode => widget.reminderToEdit != null;

  @override
  void initState() {
    super.initState();

    final existing = widget.reminderToEdit;

    // Pre-populate fields if editing; otherwise use default starting values
    if (existing != null) {
      _titleController = TextEditingController(text: existing.title);
      _descriptionController =
          TextEditingController(text: existing.description ?? '');

      final int hours = existing.interval.inHours;
      final int minutes = existing.interval.inMinutes % 60;
      _hoursController = TextEditingController(text: hours.toString());
      _minutesController = TextEditingController(text: minutes.toString());

      _selectedTime = TimeOfDay(
        hour: existing.startTime.hour,
        minute: existing.startTime.minute,
      );
    } else {
      _titleController = TextEditingController();
      _descriptionController = TextEditingController();

      _hoursController = TextEditingController(
        text: AppConstants.defaultIntervalHours.toString(),
      );
      _minutesController = TextEditingController(
        text: AppConstants.defaultIntervalMinutes.toString(),
      );

      _selectedTime = TimeOfDay.now();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _hoursController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  // Opens Flutter's built-in time picker
  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  // Validates form inputs and creates/updates the Reminder object
  void _saveReminder() {
    // 1. Validate form fields
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final int hours = int.tryParse(_hoursController.text.trim()) ?? 0;
    final int minutes = int.tryParse(_minutesController.text.trim()) ?? 0;
    final Duration interval = Duration(hours: hours, minutes: minutes);

    // 2. Validate total interval duration
    if (interval.inMinutes <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Interval must be greater than 0 minutes.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 3. Validate against maximum allowed interval (7 days)
    if (interval.inMinutes > AppConstants.maxIntervalMinutes) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Interval cannot exceed ${AppConstants.maxIntervalDays} days.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 4. Combine today's date with selected time
    final DateTime now = DateTime.now();
    final DateTime startDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    // 5. Construct updated or new Reminder object
    final Reminder reminderResult;
    if (_isEditMode) {
      // In EDIT MODE:
      // - Keep the original ID!
      // - Keep the original isEnabled state!
      reminderResult = widget.reminderToEdit!.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        interval: interval,
        startTime: startDateTime,
      );
    } else {
      // In CREATE MODE:
      // - Generate a brand new unique ID
      // - Defaults to enabled (true)
      reminderResult = Reminder(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        interval: interval,
        isEnabled: true,
        startTime: startDateTime,
      );
    }

    // Return the reminder to HomeScreen
    Navigator.pop<Reminder>(context, reminderResult);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Dynamic title based on mode
        title: Text(_isEditMode ? 'Edit Reminder' : 'Add Reminder'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ---------------------------------------------------------------
              // 1. TITLE FIELD
              // ---------------------------------------------------------------
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Reminder title *',
                  hintText: 'e.g., Drink Water',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a reminder title.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ---------------------------------------------------------------
              // 2. DESCRIPTION FIELD (OPTIONAL)
              // ---------------------------------------------------------------
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'e.g., Stay hydrated throughout the work day',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 24),

              // ---------------------------------------------------------------
              // 3. INTERVAL FIELDS (HOURS & MINUTES)
              // ---------------------------------------------------------------
              Text(
                'Reminder Interval',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hours input
                  Expanded(
                    child: TextFormField(
                      controller: _hoursController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Hours',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter hours';
                        }
                        final parsed = int.tryParse(value.trim());
                        if (parsed == null || parsed < 0) {
                          return 'Hours must be 0 or greater';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Minutes input (explicitly restricted to 0-59)
                  // WHY EXPLICIT VALIDATION IS PREFERRED OVER SILENT CONVERSION:
                  // If a user types '75', silently converting it to '1 hour 15 minutes'
                  // hides mistakes (the user might have meant '7' or '5'). Explicit
                  // validation educates the user and prevents unintended schedules.
                  Expanded(
                    child: TextFormField(
                      controller: _minutesController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Minutes',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter minutes';
                        }
                        final parsed = int.tryParse(value.trim());
                        if (parsed == null || parsed < 0 || parsed > 59) {
                          return 'Minutes must be between 0 and 59';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ---------------------------------------------------------------
              // 4. START TIME PICKER
              // ---------------------------------------------------------------
              Text(
                'Start Time',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickTime,
                borderRadius: BorderRadius.circular(8.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 14.0,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedTime.format(context),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const Icon(Icons.access_time),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // ---------------------------------------------------------------
              // 5. SAVE / UPDATE BUTTON
              // ---------------------------------------------------------------
              ElevatedButton(
                onPressed: _saveReminder,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
                child: Text(
                  _isEditMode ? 'Save Changes' : 'Create Reminder',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
