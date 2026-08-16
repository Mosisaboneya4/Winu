import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  static final NotificationService instance = NotificationService._init();
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  NotificationService._init();

  Future<void> initialize() async {
    tz_data.initializeTimeZones();

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

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    // Request permissions for Android 13+
    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  void _onNotificationResponse(NotificationResponse response) {
    debugPrint('Notification response: ${response.payload}');
    // Handle notification tap
  }

  // Schedule pill reminder
  Future<void> schedulePillReminder({
    required String id,
    required String pillName,
    required DateTime scheduledTime,
    required String? notes,
  }) async {
    final scheduledTZ = tz.TZDateTime.from(scheduledTime, tz.local);
    final now = tz.TZDateTime.now(tz.local);

    if (scheduledTZ.isBefore(now)) {
      // Schedule for next day if time has passed
      scheduledTZ.add(const Duration(days: 1));
    }

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'pill_reminders',
      'Pill Reminders',
      channelDescription: 'Notifications for birth control pill reminders',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id.hashCode,
      'Time to take your pill',
      'It\'s time to take your $pillName${notes != null ? '. Note: $notes' : ''}',
      scheduledTZ,
      platformDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // Schedule appointment reminder
  Future<void> scheduleAppointmentReminder({
    required String id,
    required String doctorName,
    required String specialization,
    required DateTime appointmentDate,
    required TimeOfDay appointmentTime,
    Duration? reminderBefore,
  }) async {
    final reminderTime = reminderBefore ?? const Duration(hours: 1);
    final scheduledDateTime = DateTime(
      appointmentDate.year,
      appointmentDate.month,
      appointmentDate.day,
      appointmentTime.hour,
      appointmentTime.minute,
    ).subtract(reminderTime);

    final scheduledTZ = tz.TZDateTime.from(scheduledDateTime, tz.local);

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'appointment_reminders',
      'Appointment Reminders',
      channelDescription: 'Notifications for doctor appointments',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id.hashCode,
      'Upcoming Appointment',
      'Appointment with $doctorName ($specialization) in ${reminderTime.inHours} hour${reminderTime.inHours > 1 ? 's' : ''}',
      scheduledTZ,
      platformDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // Schedule period prediction reminder
  Future<void> schedulePeriodReminder({
    required String id,
    required DateTime predictedDate,
  }) async {
    final scheduledTZ = tz.TZDateTime.from(predictedDate, tz.local);

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'period_reminders',
      'Period Reminders',
      channelDescription: 'Notifications for period predictions',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id.hashCode,
      'Period Reminder',
      'Your period is predicted to start today',
      scheduledTZ,
      platformDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // Cancel specific notification
  Future<void> cancelNotification(String id) async {
    await _notifications.cancel(id.hashCode);
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // Cancel pill reminders
  Future<void> cancelPillReminders() async {
    await _notifications.cancel(0); // Pill reminder channel
  }

  // Cancel appointment reminders
  Future<void> cancelAppointmentReminders() async {
    await _notifications.cancel(1); // Appointment reminder channel
  }

  // Show immediate notification (for testing or urgent alerts)
  Future<void> showImmediateNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'immediate_notifications',
      'Immediate Notifications',
      channelDescription: 'Immediate notifications',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      platformDetails,
      payload: payload,
    );
  }

  // Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  // Check notification permissions
  Future<bool> areNotificationsEnabled() async {
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidPlugin != null) {
      final bool? granted = await androidPlugin.areNotificationsEnabled();
      return granted ?? false;
    }
    
    return true; // iOS handles permissions differently
  }

  // Request notification permissions
  Future<bool> requestPermissions() async {
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidPlugin != null) {
      final bool? granted = await androidPlugin.requestNotificationsPermission();
      return granted ?? false;
    }
    
    return true;
  }
}
