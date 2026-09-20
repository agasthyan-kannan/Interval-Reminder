// ============================================================================
// FILE: lib/features/reminders/presentation/widgets/reminder_card.dart
//
// WHAT THIS FILE DOES:
// This file defines the ReminderCard widget, which renders an individual
// reminder card in the list with:
// - Status icon, title, optional description, interval, and start time.
// - An active/paused toggle Switch.
// - An Edit IconButton.
// - A Delete IconButton.
// - Clear visual distinction for Enabled vs Disabled states (including
//   a text status indicator for accessibility, rather than relying solely on color).
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
import '../../../../core/utils/date_time_utils.dart';
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isEnabled = reminder.isEnabled;

    // ACCESSIBILITY & VISUAL CLARITY:
    // When disabled, we reduce opacity and provide a clear textual status badge
    // ("Active" vs "Paused"). This ensures users with visual impairments or
    // color blindness can immediately determine reminder status without relying on color alone.
    return Opacity(
      opacity: isEnabled ? 1.0 : 0.65,
      child: Card(
        margin: const EdgeInsets.only(bottom: 12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------------------------------------------------------------
              // TOP ROW: Status Icon, Title, Status Badge, Switch, Edit, Delete
              // ---------------------------------------------------------------
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Status Icon (alarm_on vs alarm_off)
                  Icon(
                    isEnabled ? Icons.alarm_on : Icons.alarm_off,
                    color: isEnabled
                        ? colorScheme.primary
                        : colorScheme.outline,
                    size: 24,
                  ),
                  const SizedBox(width: 12),

                  // Reminder Title (with overflow protection)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reminder.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            decoration: isEnabled
                                ? null
                                : TextDecoration.lineThrough,
                            color: isEnabled
                                ? colorScheme.onSurface
                                : colorScheme.outline,
                          ),
                        ),
                        const SizedBox(height: 2),
                        // Non-color dependent status badge for accessibility
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6.0,
                            vertical: 2.0,
                          ),
                          decoration: BoxDecoration(
                            color: isEnabled
                                ? colorScheme.primaryContainer
                                : colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          child: Text(
                            isEnabled ? 'Active' : 'Paused',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isEnabled
                                  ? colorScheme.onPrimaryContainer
                                  : colorScheme.outline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Switch: Toggles reminder enabled/disabled
                  Switch(
                    value: isEnabled,
                    onChanged: onToggle,
                  ),

                  // Edit Button with semantic tooltip
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    tooltip: 'Edit reminder',
                    onPressed: onEdit,
                  ),

                  // Delete Button with semantic tooltip
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    color: Colors.red.shade400,
                    tooltip: 'Delete reminder',
                    onPressed: onDelete,
                  ),
                ],
              ),

              // ---------------------------------------------------------------
              // OPTIONAL DESCRIPTION (if provided)
              // ---------------------------------------------------------------
              if (reminder.description != null &&
                  reminder.description!.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  reminder.description!,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],

              const Divider(height: 24),

              // ---------------------------------------------------------------
              // BOTTOM ROW: Interval and Start Time details
              // ---------------------------------------------------------------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Interval display
                  Row(
                    children: [
                      Icon(
                        Icons.repeat,
                        size: 16,
                        color: isEnabled ? colorScheme.primary : colorScheme.outline,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        DateTimeUtils.formatInterval(reminder.interval),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isEnabled ? colorScheme.onSurface : colorScheme.outline,
                        ),
                      ),
                    ],
                  ),

                  // Start Time display
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 16,
                        color: isEnabled ? colorScheme.secondary : colorScheme.outline,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Starts at ${DateTimeUtils.formatTime(reminder.startTime)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
