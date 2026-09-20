# Interval Reminder

A clean, beginner-friendly Flutter application that allows users to create recurring interval reminders and receive local notifications at configured intervals.

---

## Features

- **Create Reminders**: Set a title, optional description, interval (hours and minutes), and starting time.
- **Edit Reminders**: Modify reminder details with seamless notification rescheduling while preserving the stable notification ID.
- **Delete Reminders**: Safely delete reminders with a confirmation dialog, automatically cancelling pending system alarms.
- **Enable / Disable Toggles**: Pause reminders without deleting them; re-enabling automatically calculates the next upcoming occurrence.
- **Custom Intervals**: Flexible interval configuration from 1 minute up to 7 days, with explicit boundary validation (0–59 minutes).
- **Start Time Specification**: Configure the initial anchor time from which recurring intervals are computed.
- **Local Scheduled Notifications**: Direct integration with device alarm and notification systems (`flutter_local_notifications`), waking up the device even when the app is backgrounded or closed.
- **Persistent Local Storage**: Complete offline persistence using `shared_preferences` with JSON serialization.
- **Notification Rescheduling & Startup Synchronization**: On app launch and resume from background, the app synchronizes all active reminders with the operating system notification queue to prevent drift or duplicate alerts.
- **Permission & Error Handling**: Graceful runtime permission requests (Android 13+), non-intrusive warning banners, and user-friendly SnackBar feedback without exposing technical stack traces.
- **Material 3 Theming**: Polished light and dark themes with accessible visual status indicators (Active vs. Paused badges).

---

## Technology Stack

The project relies strictly on fundamental Flutter and Dart packages without third-party state-management or backend frameworks:

- **Flutter SDK**: UI framework and widget tree engine (`sdk: flutter`).
- **Dart**: Programming language (`>=3.0.0 <4.0.0`).
- **shared_preferences (^2.3.2)**: Key-value local disk storage for reminder data persistence.
- **flutter_local_notifications (^17.2.3)**: Native platform channel wrapper for Android AlarmManager and notification channels.
- **timezone (^0.9.4)**: IANA timezone database for timezone-aware exact alarm scheduling (`tz.TZDateTime`).
- **cupertino_icons (^1.0.8)**: Directional icon assets.

---

## Project Architecture & Structure

The codebase follows **Clean Architecture** principles, maintaining strict separation between business logic, data persistence, and UI presentation:

```text
lib/
├── main.dart                                         # Application bootstrap entrypoint
├── app/
│   ├── app.dart                                      # Root MaterialApp widget & theme routing
│   └── theme/
│       └── app_theme.dart                            # Material 3 light and dark theme definitions
├── core/
│   ├── constants/
│   │   └── app_constants.dart                        # Centralized limits, names, and channel IDs
│   ├── services/
│   │   └── notification_service.dart                 # Platform notification & alarm wrapper
│   └── utils/
│       └── date_time_utils.dart                      # Pure date, time, and interval formatters
└── features/
    └── reminders/
        ├── data/
        │   ├── datasources/
        │   │   └── reminder_local_data_source.dart   # SharedPreferences JSON read/write operations
        │   └── repositories/
        │       └── reminder_repository_impl.dart     # Concrete implementation of ReminderRepository
        ├── domain/
        │   ├── entities/
        │   │   └── reminder.dart                     # Immutable domain entity with copyWith & JSON methods
        │   ├── repositories/
        │   │   └── reminder_repository.dart          # Abstract persistence contract
        │   └── services/
        │       ├── reminder_scheduler.dart           # Pure interval arithmetic for next trigger calculation
        │       └── reminder_sync_service.dart        # Synchronizes stored reminders with OS alarms
        └── presentation/
            ├── screens/
            │   ├── add_reminder_screen.dart          # Create & Edit form with validation & time picker
            │   └── home_screen.dart                  # Reminder list, empty state, dialogs & lifecycle observer
            └── widgets/
                └── reminder_card.dart                # Individual card with accessible toggle, edit & delete
```

### Architecture Data Flow

```text
                   ┌───────────────────────────────┐
                   │          HomeScreen           │
                   │      (Presentation / UI)      │
                   └───────┬───────────────┬───────┘
                           │               │
        User actions & data│               │Synchronization & alarms
                           ▼               ▼
        ┌───────────────────────┐    ┌───────────────────────────┐
        │  ReminderRepository   │    │    ReminderSyncService    │
        └──────────┬────────────┘    └──────┬─────────────┬──────┘
                   │                        │             │
                   ▼                        │             │
        ┌───────────────────────┐           ▼             ▼
        │ ReminderLocalData-    │    ┌──────────────┐ ┌───────────────────┐
        │ Source (SharedPrefs)  │    │  Scheduler   │ │NotificationService│
        └───────────────────────┘    │ (Next Time)  │ │ (AlarmManager)    │
                                     └──────────────┘ └─────────┬─────────┘
                                                                │
                                                                ▼
                                                    Operating System Alarms
```

---

## Getting Started

### Prerequisites

- Flutter SDK (version 3.0.0 or higher)
- Android SDK (API level 33+ recommended for notification permission testing)
- Physical Android device or Android Emulator

### Installation & Execution

1. **Clone the repository and install dependencies:**
   ```bash
   flutter pub get
   ```

2. **Run the application on a connected device:**
   ```bash
   flutter run
   ```

---

## Testing & Static Analysis

1. **Execute automated unit tests:**
   ```bash
   flutter test
   ```

2. **Run the Dart static analyzer:**
   ```bash
   flutter analyze
   ```

---

## Release Build

To generate an optimized release Android APK:

```bash
flutter build apk --release
```

The compiled release APK will be located at:
```text
build/app/outputs/flutter-apk/app-release.apk
```

---

## Android Notification & Background Execution Limitations

When developing and running interval reminders on Android, keep the following platform behaviors in mind:

1. **Notification Permissions (Android 13+ / API 33+)**:
   - Apps must explicitly request runtime `POST_NOTIFICATIONS` permission.
   - If denied by the user, the app continues to function and persist reminders, but visual status bar alerts will be suppressed by the operating system until re-enabled in Android system settings.

2. **Exact Alarms (`SCHEDULE_EXACT_ALARM` / `USE_EXACT_ALARM`)**:
   - Scheduled notifications use `androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle`.
   - On Android 12+ (API 31+), if the user explicitly revokes "Alarms & Reminders" permission for this app in device settings, the operating system may delay or batch alarms.

3. **Battery Optimization & Doze Mode**:
   - Aggressive manufacturer power management (e.g., Xiaomi MIUI, Samsung One UI, Huawei EMUI) may delay background alarms when the device is in deep Doze mode.
   - Users who need sub-minute precision while the device is sleeping should disable battery optimization ("Unrestricted battery usage") for this app in system settings.

4. **App Force-Stop (Killed via Settings)**:
   - If a user opens Android Settings and taps **Force Stop**, the Android OS cancels all pending alarms in AlarmManager and prevents the app from receiving intents (including `BOOT_COMPLETED`) until the user manually launches the app again.

5. **Device Reboot (`RECEIVE_BOOT_COMPLETED`)**:
   - The app declares `RECEIVE_BOOT_COMPLETED` and registers `com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver` to restore pending alarms when the device restarts.
   - Additionally, whenever the user opens the application, `HomeScreen` automatically re-evaluates all enabled reminders and synchronizes their next trigger times with the OS alarm queue.
