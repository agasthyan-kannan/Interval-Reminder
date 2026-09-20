// ============================================================================
// FILE: lib/core/services/notification_service.dart
// FOLDER: lib/core/services/
//
// WHAT THIS FILE DOES:
// This service wraps the 'flutter_local_notifications' plugin and manages all
// interactions with the device's native operating system notification engine:
// 1. Initializing the notification plugin and timezone database.
// 2. Requesting runtime notification permissions from the user.
// 3. Creating an Android notification channel.
// 4. Scheduling exact local notifications at specific future dates.
// 5. Cancelling notifications when reminders are disabled or deleted.
//
// WHY A SEPARATE SERVICE IS REQUIRED:
// The Flutter UI should never contain low-level platform code, channel names,
// or notification ID hashing algorithms.
// By isolating device notification interactions in this service, the rest of
// the app stays clean, decoupled, and platform-agnostic.
// ============================================================================

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../../features/reminders/domain/entities/reminder.dart';

class NotificationService {
  // Singleton pattern ensures only one instance of NotificationService exists
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // The underlying flutter_local_notifications plugin instance
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // ---------------------------------------------------------------------------
  // ANDROID NOTIFICATION CHANNEL CONSTANTS
  // ---------------------------------------------------------------------------
  // WHAT IS AN ANDROID NOTIFICATION CHANNEL?
  // Starting with Android 8.0 (API 26), all notifications must belong to a "Channel".
  // Channels allow users to customize their notification preferences in system
  // settings (e.g. turning off sound for marketing channels while keeping
  // alarm channels enabled).
  //
  // IMPORTANCE:
  // Importance.high ensures the notification makes a sound and pops up as a
  // heads-up banner on top of whatever the user is doing.
  static const String _channelId = 'interval_reminder_channel';
  static const String _channelName = 'Interval Reminders';
  static const String _channelDescription =
      'Scheduled repeating interval reminders for your tasks';

  // Flag to avoid initializing multiple times
  bool _isInitialized = false;

  // ---------------------------------------------------------------------------
  // 1. INITIALIZE NOTIFICATION SERVICE
  // ---------------------------------------------------------------------------
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 1. Initialize the IANA Timezone database
      // The timezone package provides accurate time math and automatically
      // handles Daylight Saving Time (DST) transitions.
      tz.initializeTimeZones();

      // 2. Android Initialization Settings
      // Uses the default application icon as the notification icon.
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // 3. iOS / Darwin Initialization Settings
      const DarwinInitializationSettings darwinSettings =
          DarwinInitializationSettings(
        requestAlertPermission: false, // We request permissions explicitly
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      // Combine platform settings
      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
      );

      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint('Notification clicked with payload: ${response.payload}');
        },
      );

      // 4. Create the Android notification channel
      await _createNotificationChannel();

      _isInitialized = true;
      debugPrint('NotificationService initialized successfully.');
    } catch (e, stackTrace) {
      // Graceful error handling: log error without crashing the app
      debugPrint('NotificationService: Failed to initialize: $e');
      debugPrint('$stackTrace');
    }
  }

  // ---------------------------------------------------------------------------
  // 2. CREATE ANDROID NOTIFICATION CHANNEL
  // ---------------------------------------------------------------------------
  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    // Register channel with the Android operating system
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  // ---------------------------------------------------------------------------
  // 3. REQUEST PERMISSIONS
  // ---------------------------------------------------------------------------
  // WHAT ARE NOTIFICATION PERMISSIONS?
  // Starting with Android 13 (API 33) and on all iOS versions, apps MUST explicitly
  // ask the user for permission before they can display notifications.
  Future<void> requestPermissions() async {
    try {
      // Request Android 13+ permission
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();

      // Request iOS permission
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } catch (e) {
      debugPrint('NotificationService: Error requesting permissions: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // 4. STABLE NOTIFICATION ID GENERATOR
  // ---------------------------------------------------------------------------
  // WHY NOTIFICATION IDS MUST BE STABLE & PREDICTABLE:
  // Both Android and iOS identify scheduled notifications by an integer ID.
  // If we randomly generated a new ID every time, we would have NO WAY to find
  // and cancel that notification later when the user deletes or toggles the reminder!
  //
  // By hashing the reminder's unique String ID into a deterministic 31-bit integer,
  // the ID is always identical for the same reminder:
  // reminder.id -> _getNotificationId(reminder.id) -> constant integer
  int _getNotificationId(String reminderId) {
    // 0x7FFFFFFF is the maximum 32-bit positive integer (2,147,483,647).
    // Using modulo ensures the resulting ID is always positive and within limits.
    return reminderId.hashCode.abs() % 2147483647;
  }

  // ---------------------------------------------------------------------------
  // 5. SCHEDULE A REMINDER
  // ---------------------------------------------------------------------------
  // WHAT THIS METHOD DOES:
  // Hands off a single scheduled alert to the Android/iOS operating system alarm manager.
  //
  // WHY OS SCHEDULING (NOT DART TIMERS):
  // When the app is closed, Flutter's Dart engine stops executing.
  // But because we scheduled this notification with the OS, Android/iOS will
  // wake up at [scheduledTime] and show the alert even if the app is completely closed!
  Future<void> scheduleReminder({
    required Reminder reminder,
    required DateTime scheduledTime,
  }) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      final int notificationId = _getNotificationId(reminder.id);

      // Convert standard DateTime to a Timezone-aware TZDateTime
      tz.TZDateTime tzScheduledTime =
          tz.TZDateTime.from(scheduledTime, tz.local);

      // If the scheduled time is slightly in the past (e.g. within the same second),
      // adjust it to 5 seconds in the future so the OS alarm does not drop it.
      final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
      if (tzScheduledTime.isBefore(now)) {
        tzScheduledTime = now.add(const Duration(seconds: 5));
      }

      // Android-specific notification presentation settings
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      // iOS-specific notification presentation settings
      const DarwinNotificationDetails darwinDetails =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
      );

      // zonedSchedule registers the alarm with the device OS
      await _notificationsPlugin.zonedSchedule(
        notificationId,
        reminder.title,
        reminder.description != null && reminder.description!.isNotEmpty
            ? reminder.description!
            : "It's time for your reminder.",
        tzScheduledTime,
        details,
        // exactAllowWhileIdle ensures the alarm fires even in Android Doze / battery-saver mode
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: reminder.id,
      );

      debugPrint(
        'Scheduled notification [ID $notificationId] for "${reminder.title}" at $tzScheduledTime',
      );
    } catch (e, stackTrace) {
      debugPrint('NotificationService: Failed to schedule reminder: $e');
      debugPrint('$stackTrace');
    }
  }

  // ---------------------------------------------------------------------------
  // 6. CANCEL A REMINDER
  // ---------------------------------------------------------------------------
  // WHAT THIS METHOD DOES:
  // Cancels any pending scheduled notification for this specific reminder.
  // Called when a reminder is toggled OFF or DELETED.
  Future<void> cancelReminder(String reminderId) async {
    try {
      final int notificationId = _getNotificationId(reminderId);
      await _notificationsPlugin.cancel(notificationId);
      debugPrint('Cancelled notification [ID $notificationId] for reminder $reminderId');
    } catch (e) {
      debugPrint('NotificationService: Failed to cancel reminder: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // 7. CANCEL ALL REMINDERS
  // ---------------------------------------------------------------------------
  // Removes all pending notifications from the operating system queue.
  Future<void> cancelAllReminders() async {
    try {
      await _notificationsPlugin.cancelAll();
      debugPrint('Cancelled all scheduled notifications.');
    } catch (e) {
      debugPrint('NotificationService: Failed to cancel all notifications: $e');
    }
  }
}
