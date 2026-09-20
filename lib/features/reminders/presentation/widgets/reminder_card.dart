// ============================================================================
// FILE: lib/features/reminders/presentation/widgets/reminder_card.dart
//
// WHAT THIS FILE DOES:
// This file defines the ReminderCard widget, which renders an individual
// reminder card with:
// - Title, description, formatted interval, and start time.
// - An active/paused toggle Switch.
// - An Edit IconButton.
// - A Delete IconButton.
//
// LIFTING STATE UP:
// Notice that ReminderCard does NOT mutate the reminder directly.
// Instead, it exposes callback functions:
// - onToggle(bool)
// - onEdit()
// - onDelete()
// This allows the parent (HomeScreen) to coordinate state updates, persistence,
// and notification rescheduling in one central place!
// ============================================================================

import 'package:flutter/material.dart';
import '../../domain/entities/reminder.dart';

class ReminderCard extends StatelessWidget {
  final Reminder reminder;
  final ValueChanged<bool> onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ReminderCard({
    super.key,
    required this.reminder,
    required this.onToggle,
    required this.onEdit,
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
            // TOP ROW: Status Icon, Title, Switch, Edit Button, Delete Button
            Row(
              children: [
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

                // Edit Button
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Edit reminder',
                  onPressed: onEdit,
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
