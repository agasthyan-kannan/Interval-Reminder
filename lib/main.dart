// ============================================================================
// FILE: lib/main.dart
//
// WHAT THIS FILE DOES:
// This is the starting entry point of our entire Flutter application.
// When you start the app, Dart begins execution right here inside the main() function.
//
// WHY UI CODE IS NOT IN THIS FILE:
// Keeping main.dart clean and minimal is a Flutter best practice.
// main.dart should only be responsible for launching the app and initializing
// critical services. All visual styling, widgets, and navigation belong in
// dedicated files (like lib/app/app.dart).
// ============================================================================

import 'package:flutter/material.dart';
import 'app/app.dart';

// main() is a special function in Dart.
// It is the first function that the operating system runs when starting the program.
void main() {
  // runApp() is a built-in Flutter function from the Flutter framework.
  // It takes a Flutter widget and makes it the "root" (the very top) of the widget tree.
  // It attaches that widget to the device screen and manages rendering every frame.
  //
  // 'const' tells Dart that this widget is immutable and can be created at compile-time,
  // which optimizes performance by avoiding unnecessary rebuilds.
  runApp(const IntervalReminderApp());
}
