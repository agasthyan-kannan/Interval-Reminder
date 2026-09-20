// ============================================================================
// FILE: lib/core/services/notification_service.dart
// FOLDER: lib/core/services/
//
// WHAT THIS FILE DOES:
// This service wraps the 'flutter_local_notifications' plugin and manages all
// interactions with the device's native operating system notification engine:
// 1. Initializing the notification plugin and timezone database.
// 2. Checking and requesting runtime notification permissions.
// 3. Creating an Android notification channel.
// 4. Scheduling exact local notifications at specific future dates.
// 5. Cancelling notifications when reminders are disabled or deleted.
//
// SEPARATION OF CONCERNS:
// - NotificationService only knows HOW to talk to the operating system.
// - It does NOT decide WHEN reminders occur (ReminderScheduler does that).
// - It does NOT store reminder data (ReminderRepository does that).
// ============================================================================

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../constants/app_constants.dart';
import '../../features/reminders/domain/entities/reminder.dart';

class NotificationService {
  // Singleton pattern ensures only one instance of NotificationService exists
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // ---------------------------------------------------------------------------
  // ANDROID NOTIFICATION CHANNEL CONSTANTS
  // ---------------------------------------------------------------------------
  // Sourced from AppConstants for a single source of truth across the project.
  static const String _channelId = AppConstants.notificationChannelId;
  static const String _channelName = AppConstants.notificationChannelName;
  static const String _channelDescription = AppConstants.notificationChannelDescription;

  bool _isInitialized = false;

  // ---------------------------------------------------------------------------
  // 1. INITIALIZE NOTIFICATION SERVICE
  // ---------------------------------------------------------------------------
  // WHY INITIALIZATION ORDER MATTERS:
  // We must initialize the timezone database and notification channel BEFORE
  // attempting to schedule any notifications. If an alarm is registered before
  // the channel exists, Android will reject the notification!
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 1. Initialize the IANA Timezone database
      tz.initializeTimeZones();

      // 2. Android Initialization Settings
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // 3. iOS / Darwin Initialization Settings
      const DarwinInitializationSettings darwinSettings =
          DarwinInitializationSettings(
        requestAlertPermission: false, // Requested explicitly via requestPermissions()
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

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
      debugPrint('NotificationService: Initialized successfully.');
    } catch (e, stackTrace) {
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

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  // ---------------------------------------------------------------------------
  // 3. CHECK PERMISSION STATE
  // ---------------------------------------------------------------------------
  // DISTINCTION: INITIALIZATION vs PERMISSION:
  // - "Initialized" means the plugin code is ready to talk to the OS.
  // - "Permission Granted" means the user has allowed notifications on their phone.
  // The app can be fully initialized even if the user denied permission!
  Future<bool> areNotificationsGranted() async {
    try {
      final bool? androidGranted = await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.areNotificationsEnabled();

      if (androidGranted != null) {
        return androidGranted;
      }

      // On iOS or platforms where checking is unsupported, assume true or fallback
      return true;
    } catch (e) {
      debugPrint('NotificationService: Error checking notification permission: $e');
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // 4. REQUEST PERMISSIONS
  // ---------------------------------------------------------------------------
  // Requests runtime notification permission on Android 13+ (API 33+) and iOS.
  // Returns true if granted, false if denied.
  Future<bool> requestPermissions() async {
    try {
      final bool? androidGranted = await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();

      final bool? iosGranted = await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );

      final bool isGranted = (androidGranted ?? iosGranted) ?? true;
      debugPrint('NotificationService: Permission request result: $isGranted');
      return isGranted;
    } catch (e) {
      debugPrint('NotificationService: Error requesting permissions: $e');
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // 5. STABLE NOTIFICATION ID GENERATOR
  // ---------------------------------------------------------------------------
  // Derives a deterministic, stable 31-bit positive integer from reminder.id.
  // This ensures scheduling, rescheduling, and cancelling all target the exact same ID.
  int _getNotificationId(String reminderId) {
    return reminderId.hashCode.abs() % 2147483647;
  }

  // ---------------------------------------------------------------------------
  // 6. SCHEDULE A REMINDER
  // ---------------------------------------------------------------------------
  // Schedules an exact future alert with the device operating system.
  //
  // PREVENTING DUPLICATE NOTIFICATIONS:
  // Calling zonedSchedule with an existing notificationId OVERWRITES any
  // previously pending alarm for that ID in Android AlarmManager.
  // This guarantees: One Reminder = One Scheduled Alarm (no duplicates!).
  Future<void> scheduleReminder({
    required Reminder reminder,
    required DateTime scheduledTime,
  }) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      final int notificationId = _getNotificationId(reminder.id);

      // Convert DateTime to Timezone-aware TZDateTime
      tz.TZDateTime tzScheduledTime =
          tz.TZDateTime.from(scheduledTime, tz.local);

      // Defensive check: ensure the scheduled time is in the future
      final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
      if (tzScheduledTime.isBefore(now)) {
        tzScheduledTime = now.add(const Duration(seconds: 5));
      }

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

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

      await _notificationsPlugin.zonedSchedule(
        notificationId,
        reminder.title,
        reminder.description != null && reminder.description!.isNotEmpty
            ? reminder.description!
            : "It's time for your reminder.",
        tzScheduledTime,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: reminder.id,
      );

      debugPrint(
        'NotificationService: Scheduled [ID $notificationId] for "${reminder.title}" at $tzScheduledTime',
      );
    } catch (e, stackTrace) {
      debugPrint('NotificationService: Failed to schedule reminder ${reminder.id}: $e');
      debugPrint('$stackTrace');
      // Rethrow to let callers (like HomeScreen) know scheduling failed
      // so they can notify the user if necessary.
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // 7. CANCEL A REMINDER
  // ---------------------------------------------------------------------------
  Future<void> cancelReminder(String reminderId) async {
    try {
      final int notificationId = _getNotificationId(reminderId);
      await _notificationsPlugin.cancel(notificationId);
      debugPrint('NotificationService: Cancelled notification [ID $notificationId] for reminder $reminderId');
    } catch (e) {
      debugPrint('NotificationService: Failed to cancel reminder $reminderId: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // 8. CANCEL ALL REMINDERS
  // ---------------------------------------------------------------------------
  Future<void> cancelAllReminders() async {
    try {
      await _notificationsPlugin.cancelAll();
      debugPrint('NotificationService: Cancelled all scheduled notifications.');
    } catch (e) {
      debugPrint('NotificationService: Failed to cancel all notifications: $e');
    }
  }
}
