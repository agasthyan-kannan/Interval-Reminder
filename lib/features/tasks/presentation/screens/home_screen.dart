// ============================================================================
// FILE: lib/features/tasks/presentation/screens/home_screen.dart
//
// WHAT THIS FILE DOES:
// This file defines the HomeScreen widget, which is the very first screen
// the user sees when opening the Interval Reminder application.
//
// HOW FLUTTER BUILDS UI USING WIDGETS:
// In Flutter, "everything is a widget".
// - Structural layout elements (like Scaffold, Center, Column) are widgets.
// - Visual elements (like Text, Icon, ElevatedButton) are widgets.
// - Even styling rules and padding are widgets!
// You build user interfaces by nesting widgets inside one another, forming a
// "Widget Tree".
// ============================================================================

import 'package:flutter/material.dart';

// HomeScreen extends StatelessWidget.
// A StatelessWidget is used when the screen's UI does not need to dynamically
// change its own state at this moment (e.g., it currently displays a static
// empty-state message).
class HomeScreen extends StatelessWidget {
  // The 'super.key' passes a unique key identifier to the parent Widget class,
  // which helps Flutter efficiently recognize and update widgets in the tree.
  const HomeScreen({super.key});

  // WHY build() EXISTS:
  // Flutter calls the build() method whenever it needs to render or repaint
  // this widget on the screen.
  //
  // build() returns a Widget (or a tree of widgets) describing what the UI
  // should look like.
  //
  // 'BuildContext context':
  // 'context' provides information about where this widget is located inside
  // Flutter's overall widget tree. It is used to look up themes, screen size,
  // navigation, and more.
  @override
  Widget build(BuildContext context) {
    // WHAT Scaffold DOES:
    // Scaffold provides the standard visual layout structure for a Material Design page.
    // It gives us ready-made slots for common mobile UI elements, such as:
    // - appBar (top bar)
    // - body (the main screen content)
    // - floatingActionButton (a prominent circular button)
    // - bottomNavigationBar (bottom tabs)
    return Scaffold(
      // WHAT AppBar DOES:
      // AppBar creates a toolbar at the top of the screen.
      // It typically displays the screen's title, navigation buttons (like a back arrow),
      // and quick-action icons.
      appBar: AppBar(
        // 'title' takes any widget, most commonly a Text widget with the screen name.
        title: const Text('Interval Reminder'),
      ),

      // WHAT Center DOES:
      // Center is a single-child layout widget that takes whatever widget is passed
      // to 'child' and centers it both horizontally and vertically within the available space.
      body: Center(
        // WHAT Column DOES:
        // Column is a layout widget that arranges its list of 'children' widgets
        // vertically in a single column from top to bottom.
        child: Column(
          // 'mainAxisAlignment' controls vertical alignment inside a Column.
          // MainAxisAlignment.center places the children in the middle of the vertical space.
          mainAxisAlignment: MainAxisAlignment.center,

          // 'children' takes a List<Widget> of widgets to display in order.
          children: [
            // Headline empty-state message
            Text(
              'No reminders yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            // SizedBox creates a fixed empty space between widgets.
            // Here, it adds 8 pixels of vertical breathing room.
            const SizedBox(height: 8),

            // Subtitle explanation text
            Text(
              'Create a reminder to get started.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),

            // Vertical spacing before the action button
            const SizedBox(height: 24),

            // Placeholder button for adding a reminder
            // IMPORTANT: This button's callback is intentionally a placeholder.
            // We are not implementing reminder creation yet in Step 2.
            ElevatedButton.icon(
              // 'onPressed' defines what happens when the user taps the button.
              // Passing an empty function () {} keeps the button visually active
              // while signaling that logic will be connected in an upcoming step.
              onPressed: () {
                // Placeholder callback - no action taken yet.
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Reminder'),
            ),
          ],
        ),
      ),
    );
  }
}
