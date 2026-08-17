import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../../features/inventory/models/medication_model.dart';

class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Initialize local notifications and timezone DB
  static Future<void> initialize() async {
    // 1. Initialize timezone DB
    tz.initializeTimeZones();
    // Default fallback to Manila timezone, can be made dynamic
    try {
      tz.setLocalLocation(tz.getLocation('Asia/Manila'));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }

    // 2. Initialize settings for Android and iOS
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await _notificationsPlugin.initialize(settings: initializationSettings);

    // Request permissions for Android 13+
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  /// Helper to generate a unique 32-bit integer ID from String
  static int _getNotificationId(String medId, int dayIndex) {
    // Combine medId hash and day index to ensure unique IDs for multiple days of same med
    return (medId.hashCode + dayIndex) & 0x7FFFFFFF;
  }

  /// Schedule daily/weekly notifications for a specific medication
  static Future<void> scheduleMedicationReminder(MedicationModel med) async {
    if (med.id == null || med.reminderTime == null) return;

    // First cancel any existing scheduled reminders for this medicine
    await cancelMedicationReminder(med.id!);

    // If notifications are disabled or no days are selected, do not schedule
    if (med.frequency == null || med.frequency!.isEmpty) return;

    const androidDetails = AndroidNotificationDetails(
      'medication_reminders_channel',
      'Medication Reminders',
      channelDescription: 'Notifications to remind you to take your medicine.',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final now = tz.TZDateTime.now(tz.local);
    final reminderTime = med.reminderTime!;

    // Resolve days of week to schedule weekly repeating notifications
    // 0 = Monday, 1 = Tuesday, 2 = Wednesday, 3 = Thursday, 4 = Friday, 5 = Saturday, 6 = Sunday
    final List<int> activeDays = [];
    if (med.frequency == 'Daily') {
      activeDays.addAll([1, 2, 3, 4, 5, 6, 7]); // standard ISO days for repeating
    } else {
      const dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      final days = med.frequency!.split(',');
      for (final d in days) {
        // Map Mon-Sun label to ISO day of week index (1-7)
        final label = d.trim();
        final idx = dayLabels.indexOf(label);
        if (idx != -1) {
          activeDays.add(idx + 1); // 1 = Mon, 7 = Sun
        }
      }
    }

    for (final day in activeDays) {
      // Build timezone scheduled time
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        reminderTime.hour,
        reminderTime.minute,
      );

      // If scheduled time is in past, move it forward
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      // Find the next occurrence of that specific weekday if not Daily
      if (med.frequency != 'Daily') {
        while (scheduledDate.weekday != day) {
          scheduledDate = scheduledDate.add(const Duration(days: 1));
        }
      }

      final notificationId = _getNotificationId(med.id!, day);

      await _notificationsPlugin.zonedSchedule(
        id: notificationId,
        title: 'Medication Reminder 💊',
        body: 'Time to take your ${med.name} (${med.dosage ?? ""})',
        scheduledDate: scheduledDate,
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: med.frequency == 'Daily'
            ? DateTimeComponents.time
            : DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  /// Cancel all scheduled reminders for a specific medication ID
  static Future<void> cancelMedicationReminder(String medId) async {
    // Cancel all possible days of week (1 to 7)
    for (int day = 1; day <= 7; day++) {
      final notificationId = _getNotificationId(medId, day);
      await _notificationsPlugin.cancel(id: notificationId);
    }
  }
}
