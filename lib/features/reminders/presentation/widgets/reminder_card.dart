// ============================================================================
// FILE: lib/features/reminders/presentation/widgets/reminder_card.dart
//
// WHAT THIS FILE DOES:
// This file defines the ReminderCard widget, a reusable UI component that
// displays the details of a single Reminder (title, description, interval,
// start time, enabled switch, and delete button).
//
// WHY A SEPARATE REUSABLE WIDGET IS USEFUL:
// 1. Single Responsibility: HomeScreen focuses on managing the list of reminders
//    and navigation, while ReminderCard focuses purely on how an individual
//    reminder card looks and behaves.
// 2. Reusability: We can reuse ReminderCard anywhere reminders need to be displayed
//    (e.g., in a future "Active Reminders" tab or search results) without duplicating code.
// 3. Maintainability & Cleanliness: Small, focused widget files make our codebase
//    much easier to read, debug, and test.
// ============================================================================

import 'package:flutter/material.dart';
import '../../domain/entities/reminder.dart';

class ReminderCard extends StatelessWidget {
  // The reminder data to display
  final Reminder reminder;

  // CALLBACK FUNCTIONS:
  // Instead of handling state mutation inside this widget, ReminderCard notifies
  // its parent (HomeScreen) when the user wants to toggle or delete a reminder.
  // This pattern is called "Lifting State Up" in Flutter!
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;

  const ReminderCard({
    super.key,
    required this.reminder,
    required this.onToggle,
    required this.onDelete,
  });

  // Helper method to format interval duration into human-readable text
  String _formatInterval(Duration interval) {
    final int hours = interval.inHours;
    final int minutes = interval.inMinutes % 60;

    if (hours > 0 && minutes > 0) {
      return 'Every ${hours}h ${minutes}m';
    } else if (hours > 0) {
      return 'Every $hours ${hours == 1 ? "hour" : "hours"}';
    } else {
      return 'Every $minutes ${minutes == 1 ? "minute" : "minutes"}';
    }
  }

  // Helper method to format start time (e.g. "10:00 AM")
  String _formatTime(DateTime dateTime) {
    final int hour = dateTime.hour;
    final int minute = dateTime.minute;
    final String period = hour >= 12 ? 'PM' : 'AM';
    final int displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final String displayMinute = minute.toString().padLeft(2, '0');
    return '$displayHour:$displayMinute $period';
  }

  @override
  Widget build(BuildContext context) {
    // Card provides a Material Design elevated surface with rounded corners.
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TOP ROW: Title, Enabled Switch, and Delete Button
            Row(
              children: [
                // Icon indicating status
                Icon(
                  reminder.isEnabled ? Icons.alarm_on : Icons.alarm_off,
                  color: reminder.isEnabled
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(width: 12),

                // Reminder Title
                Expanded(
                  child: Text(
                    reminder.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          // Dim title text slightly if disabled
                          color: reminder.isEnabled
                              ? null
                              : Theme.of(context).colorScheme.outline,
                        ),
                  ),
                ),

                // Switch: Toggles reminder enabled/disabled
                Switch(
                  value: reminder.isEnabled,
                  onChanged: onToggle,
                ),

                // Delete Button
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.red.shade400,
                  tooltip: 'Delete reminder',
                  onPressed: onDelete,
                ),
              ],
            ),

            // OPTIONAL DESCRIPTION (if provided)
            if (reminder.description != null && reminder.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                reminder.description!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],

            const Divider(height: 20),

            // BOTTOM ROW: Interval and Start Time details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Interval display
                Row(
                  children: [
                    const Icon(Icons.repeat, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      _formatInterval(reminder.interval),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),

                // Start Time display
                Row(
                  children: [
                    const Icon(Icons.schedule, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      'Starts at ${_formatTime(reminder.startTime)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
