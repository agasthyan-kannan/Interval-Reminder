// ============================================================================
// FILE: lib/features/reminders/data/datasources/reminder_local_data_source.dart
// FOLDER: lib/features/reminders/data/datasources/
//
// WHAT THIS FILE DOES:
// This class is the "Local Data Source". Its single responsibility is reading
// and writing reminder data directly to the device's local storage using
// the 'shared_preferences' package.
//
// WHY THIS LAYER EXISTS:
// In Clean Architecture:
// - UI (HomeScreen) never talks directly to storage.
// - Repository coordinates data operations.
// - Data Source executes the low-level storage commands (SharedPreferences, SQLite, etc.).
// By isolating SharedPreferences code here, the rest of the application remains
// completely clean and free of platform-specific storage details.
//
// WHAT IS SharedPreferences?
// SharedPreferences is a lightweight key-value store provided by Android & iOS.
// It is designed for small pieces of data (settings, flags, small lists).
// It stores primitive types: String, int, double, bool, and List<String>.
//
// Because SharedPreferences cannot directly store complex Dart objects,
// we convert our List<Reminder> into a JSON String!
// ============================================================================

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/reminder.dart';

class ReminderLocalDataSource {
  // ---------------------------------------------------------------------------
  // CENTRAL STORAGE KEY
  // ---------------------------------------------------------------------------
  // WHY A CENTRAL CONSTANT KEY IS USEFUL:
  // SharedPreferences works like a dictionary: you save data under a 'key'
  // (e.g., prefs.setString('reminders', jsonString)) and read it using the same key.
  // Using a single constant prevents typos (e.g. 'reminder' vs 'reminders')
  // that would cause data to be silently lost!
  static const String _storageKey = 'reminders';

  // ---------------------------------------------------------------------------
  // GET REMINDERS (Storage -> JSON String -> List<Map> -> List<Reminder>)
  // ---------------------------------------------------------------------------
  // HOW LOADING WORKS:
  // 1. SharedPreferences.getInstance(): Asynchronously gets the storage instance.
  // 2. prefs.getString(_storageKey): Retrieves the raw JSON string.
  // 3. jsonDecode(jsonString): Converts the JSON text into a List of dynamic Maps.
  // 4. Reminder.fromJson(map): Converts each Map into a strongly-typed Reminder object.
  Future<List<Reminder>> getReminders() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_storageKey);

      // If no data has ever been saved yet, return an empty list.
      if (jsonString == null || jsonString.trim().isEmpty) {
        return [];
      }

      // jsonDecode() is from 'dart:convert'.
      // It parses raw JSON text into Dart lists and maps.
      final dynamic decoded = jsonDecode(jsonString);

      if (decoded is List) {
        return decoded
            .map((item) => Reminder.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e, stackTrace) {
      // BASIC ERROR HANDLING:
      // If the stored data was somehow corrupted or parsing failed, we catch
      // the error, print a helpful debug message, and return an empty list
      // rather than crashing the entire app!
      debugPrint('Error loading reminders from SharedPreferences: $e');
      debugPrint('$stackTrace');
      return [];
    }
  }

  // ---------------------------------------------------------------------------
  // SAVE REMINDERS (List<Reminder> -> List<Map> -> JSON String -> Storage)
  // ---------------------------------------------------------------------------
  // HOW SAVING WORKS:
  // 1. reminder.toJson(): Converts each Reminder into a Map<String, dynamic>.
  // 2. jsonEncode(mapList): Converts the List of Maps into a single JSON String.
  // 3. prefs.setString(_storageKey, jsonString): Writes the string to disk.
  Future<void> saveReminders(List<Reminder> reminders) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      // Convert each Reminder object to a JSON-compatible Map
      final List<Map<String, dynamic>> mapList =
          reminders.map((reminder) => reminder.toJson()).toList();

      // jsonEncode() turns Dart objects/maps into a serialized JSON text string
      final String jsonString = jsonEncode(mapList);

      // Save the JSON string under our constant key
      await prefs.setString(_storageKey, jsonString);
    } catch (e, stackTrace) {
      debugPrint('Error saving reminders to SharedPreferences: $e');
      debugPrint('$stackTrace');
    }
  }

  // ---------------------------------------------------------------------------
  // CLEAR REMINDERS (Helper for testing and resets)
  // ---------------------------------------------------------------------------
  Future<void> clearReminders() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
    } catch (e) {
      debugPrint('Error clearing reminders from SharedPreferences: $e');
    }
  }
}
