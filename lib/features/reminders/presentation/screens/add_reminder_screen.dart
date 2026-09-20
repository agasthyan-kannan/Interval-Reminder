// ============================================================================
// FILE: lib/features/reminders/presentation/screens/add_reminder_screen.dart
//
// WHAT THIS FILE DOES:
// This screen allows the user to enter information to create a new reminder:
// - Title (required)
// - Description (optional, multi-line)
// - Interval in hours and minutes (must be greater than 0)
// - Start time (selected via Flutter's built-in showTimePicker)
//
// WHY A StatefulWidget IS USED HERE:
// In Flutter, widgets are divided into two main categories:
// 1. StatelessWidget: The UI never changes based on internal user interaction.
// 2. StatefulWidget: The screen contains mutable data (state) that can change
//    over time while the user interacts with it (e.g. typing text, picking a time).
//
// When the user picks a new time or types into inputs, the widget holds that
// temporary state, and calls setState() to refresh the UI on screen.
// ============================================================================

import 'package:flutter/material.dart';
import '../../domain/entities/reminder.dart';

class AddReminderScreen extends StatefulWidget {
  const AddReminderScreen({super.key});

  // createState() is required for every StatefulWidget.
  // It creates the companion State object (_AddReminderScreenState)
  // that holds the mutable data and the build() logic.
  @override
  State<AddReminderScreen> createState() => _AddReminderScreenState();
}

// WHAT IS A State CLASS?
// The State class represents the logic and internal data for a StatefulWidget.
// Unlike the widget itself (which Flutter can destroy and recreate frequently),
// the State object persists across rebuilds, keeping user inputs intact.
class _AddReminderScreenState extends State<AddReminderScreen> {
  // ---------------------------------------------------------------------------
  // GLOBAL KEY FOR FORM VALIDATION
  // ---------------------------------------------------------------------------
  // WHAT IS GlobalKey<FormState>?
  // A GlobalKey uniquely identifies the Form widget in Flutter's widget tree.
  // It gives us access to the FormState methods from outside the Form, such as:
  // - _formKey.currentState!.validate(): runs the validator functions of all
  //   TextFormField children.
  // - _formKey.currentState!.save(): saves the values of all fields.
  final _formKey = GlobalKey<FormState>();

  // ---------------------------------------------------------------------------
  // TEXT EDITING CONTROLLERS
  // ---------------------------------------------------------------------------
  // WHAT IS A TextEditingController?
  // A TextEditingController listens to and controls the text being edited
  // in a TextFormField or TextField.
  //
  // WHY IT IS USEFUL:
  // 1. You can read the current text at any time using: controller.text
  // 2. You can set initial or updated text programmatically.
  // 3. You can listen for changes as the user types.
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _hoursController;
  late final TextEditingController _minutesController;

  // ---------------------------------------------------------------------------
  // SCREEN STATE
  // ---------------------------------------------------------------------------
  // TimeOfDay represents a clock time (hour and minute) without a specific date.
  // We initialize it to the current time when the screen opens.
  TimeOfDay _selectedTime = TimeOfDay.now();

  // initState() is called exactly once when this State object is first created.
  // It is the ideal place to initialize controllers and load starting values.
  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();

    // Set default interval values: 1 hour 0 minutes
    _hoursController = TextEditingController(text: '1');
    _minutesController = TextEditingController(text: '0');
  }

  // ---------------------------------------------------------------------------
  // DISPOSE: PREVENTING MEMORY LEAKS
  // ---------------------------------------------------------------------------
  // WHY dispose() IS NECESSARY:
  // TextEditingControllers allocate resources and register listeners in Flutter's
  // engine. If you do not dispose them when this screen is closed (popped),
  // those resources stay in memory, causing a "memory leak".
  //
  // dispose() is called automatically by Flutter when this screen is permanently
  // removed from the widget tree.
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _hoursController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // TIME PICKER DIALOG
  // ---------------------------------------------------------------------------
  // WHAT showTimePicker() DOES:
  // showTimePicker is a built-in Flutter function that displays a Material Design
  // clock dialog allowing the user to select an hour and minute.
  //
  // It returns a Future<TimeOfDay?>, which resolves when the user taps "OK"
  // (returning the selected TimeOfDay) or "Cancel" (returning null).
  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    // If the user picked a time (didn't cancel) and it's different from the current one:
    if (picked != null && picked != _selectedTime) {
      // WHY setState() IS NECESSARY:
      // In a StatefulWidget, simply changing a variable (_selectedTime = picked)
      // will NOT update what is shown on the screen!
      //
      // Calling setState() notifies Flutter: "My internal data has changed! Please
      // call build() again to repaint the screen with the new values."
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  // ---------------------------------------------------------------------------
  // SAVE REMINDER ACTION
  // ---------------------------------------------------------------------------
  void _saveReminder() {
    // WHAT _formKey.currentState!.validate() DOES:
    // It triggers the 'validator' callback on every TextFormField inside the Form.
    // - If any validator returns an error String, validate() returns false,
    //   and the error messages automatically appear in red under the invalid fields.
    // - If all validators return null, validate() returns true!
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Safely parse numeric input for interval hours and minutes.
    // int.tryParse() safely returns null instead of crashing if the input is invalid.
    final int hours = int.tryParse(_hoursController.text.trim()) ?? 0;
    final int minutes = int.tryParse(_minutesController.text.trim()) ?? 0;

    // INTERVAL VALIDATION:
    // The combined interval must be strictly greater than 0 minutes.
    final Duration interval = Duration(hours: hours, minutes: minutes);
    if (interval.inMinutes <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Interval must be greater than 0 minutes.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Combine today's calendar date with the chosen TimeOfDay to form a DateTime.
    final DateTime now = DateTime.now();
    final DateTime startDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    // CREATE THE REMINDER OBJECT:
    // We use the immutable Reminder model created in Step 3.
    final Reminder newReminder = Reminder(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      interval: interval,
      isEnabled: true,
      startTime: startDateTime,
    );

    // DEBUG OUTPUT:
    // Print the created reminder to the debug console as requested for Step 4.
    debugPrint('==============================================');
    debugPrint('Reminder created successfully:');
    debugPrint('ID:          ${newReminder.id}');
    debugPrint('Title:       ${newReminder.title}');
    debugPrint('Description: ${newReminder.description ?? "(none)"}');
    debugPrint('Interval:    ${newReminder.interval.inHours}h ${newReminder.interval.inMinutes % 60}m');
    debugPrint('Start Time:  ${_selectedTime.format(context)} ($startDateTime)');
    debugPrint('Enabled:     ${newReminder.isEnabled}');
    debugPrint('==============================================');

    // WHAT Navigator.pop() DOES:
    // Flutter manages screens using a stack of routes (like a stack of playing cards).
    // Navigator.pop(context) removes the top screen from the stack and returns
    // the user to the previous screen (the Home screen).
    Navigator.pop(context);
  }

  // ---------------------------------------------------------------------------
  // BUILD METHOD: CREATING THE UI
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Reminder'),
      ),
      // SingleChildScrollView ensures that when the on-screen keyboard appears,
      // the user can scroll down and the UI will not overflow.
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        // WHAT Form DOES:
        // Form is a container widget that groups multiple FormFields together
        // and enables unified validation via a GlobalKey.
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ---------------------------------------------------------------
              // 1. REMINDER TITLE
              // ---------------------------------------------------------------
              // WHAT TextFormField DOES:
              // TextFormField combines a TextField with Form integration.
              // It includes a 'validator' callback to check user input.
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Reminder title *',
                  hintText: 'e.g., Drink Water',
                  border: OutlineInputBorder(),
                ),
                // WHAT validator DOES:
                // The validator function receives the current text value.
                // - Returning a String displays that error message in red.
                // - Returning null tells Flutter the input is completely valid!
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a reminder title.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ---------------------------------------------------------------
              // 2. DESCRIPTION (OPTIONAL)
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
              // 3. INTERVAL (HOURS & MINUTES)
              // ---------------------------------------------------------------
              Text(
                'Reminder Interval',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Row(
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
                          return 'Invalid number';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Minutes input
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
                          return '0 - 59 mins';
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
              // InkWell makes any widget clickable with a Material ripple effect.
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
              // 5. SAVE BUTTON
              // ---------------------------------------------------------------
              ElevatedButton(
                onPressed: _saveReminder,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
                child: const Text(
                  'Save Reminder',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
