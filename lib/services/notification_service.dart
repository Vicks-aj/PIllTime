import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/medication_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Skip notification setup for web during development
    if (kIsWeb) {
      print('Notification service initialized (Web - limited functionality)');
      return;
    }

    try {
      // Initialize timezone
      tz.initializeTimeZones();

      // Android initialization
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization
      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notifications.initialize(
        settings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Request permissions
      await _requestPermissions();

      print('Notification service initialized (Mobile)');
    } catch (e) {
      print('Error initializing notifications: $e');
    }
  }

  Future<void> _requestPermissions() async {
    if (kIsWeb) return;

    try {
      await _notifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );

      await _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    } catch (e) {
      print('Error requesting permissions: $e');
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    print('Notification tapped: ${response.payload}');
  }

  Future<void> scheduleMedicationReminders(MedicationModel medication) async {
    if (kIsWeb) {
      print('📱 [WEB TEST] Scheduling reminders for: ${medication.name}');
      print('📱 [WEB TEST] Reminder times: ${medication.reminderTimes}');
      return;
    }

    try {
      // Cancel existing notifications for this medication
      await cancelMedicationReminders(medication.id);

      // Schedule notifications for the next 30 days
      final now = DateTime.now();
      int scheduledCount = 0;

      for (int day = 0; day < 30; day++) {
        final currentDate = now.add(Duration(days: day));

        // Skip if before medication start date
        if (currentDate.isBefore(medication.startDate)) continue;

        // Skip if after medication end date
        if (medication.endDate != null &&
            currentDate.isAfter(medication.endDate!)) break;

        // Schedule notification for each reminder time
        for (int timeIndex = 0;
            timeIndex < medication.reminderTimes.length;
            timeIndex++) {
          final timeString = medication.reminderTimes[timeIndex];
          final timeParts = timeString.split(':');
          final hour = int.parse(timeParts[0]);
          final minute = int.parse(timeParts[1]);

          final scheduledDateTime = DateTime(
            currentDate.year,
            currentDate.month,
            currentDate.day,
            hour,
            minute,
          );

          // Only schedule future notifications
          if (scheduledDateTime.isAfter(now)) {
            final notificationId =
                _generateNotificationId(medication.id, day, timeIndex);

            await _scheduleNotification(
              id: notificationId,
              title: 'Time to take your medication',
              body: '${medication.name} - ${medication.dosage}',
              scheduledDateTime: scheduledDateTime,
              payload: medication.id,
            );
            scheduledCount++;
          }
        }
      }

      print(
          '📱 Scheduled $scheduledCount notifications for: ${medication.name}');
    } catch (e) {
      print('Error scheduling reminders: $e');
    }
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDateTime,
    String? payload,
  }) async {
    if (kIsWeb) return;

    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'medication_reminders',
        'Medication Reminders',
        channelDescription: 'Notifications for medication reminders',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final tz.TZDateTime scheduledTZ =
          tz.TZDateTime.from(scheduledDateTime, tz.local);

      await _notifications.zonedSchedule(
        id,
        title,
        body,
        scheduledTZ,
        details,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: payload,
      );
    } catch (e) {
      print('Error scheduling notification: $e');
    }
  }

  Future<void> cancelMedicationReminders(String medicationId) async {
    if (kIsWeb) {
      print('📱 [WEB TEST] Cancelling reminders for: $medicationId');
      return;
    }

    try {
      final pendingNotifications =
          await _notifications.pendingNotificationRequests();

      for (final notification in pendingNotifications) {
        if (notification.payload == medicationId) {
          await _notifications.cancel(notification.id);
        }
      }

      print('📱 Cancelled reminders for: $medicationId');
    } catch (e) {
      print('Error cancelling reminders: $e');
    }
  }

  Future<void> cancelAllNotifications() async {
    if (kIsWeb) {
      print('📱 [WEB TEST] Cancelling all notifications');
      return;
    }

    try {
      await _notifications.cancelAll();
      print('📱 Cancelled all notifications');
    } catch (e) {
      print('Error cancelling all notifications: $e');
    }
  }

  int _generateNotificationId(String medicationId, int day, int timeIndex) {
    final hash = medicationId.hashCode;
    return (hash.abs() % 100000) + (day * 100) + timeIndex;
  }

  Future<void> showImmediateNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (kIsWeb) {
      print('📱 [WEB TEST] Showing notification: $title - $body');
      return;
    }

    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'immediate_notifications',
        'Immediate Notifications',
        channelDescription: 'Immediate notifications',
        importance: Importance.high,
        priority: Priority.high,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title,
        body,
        details,
        payload: payload,
      );
    } catch (e) {
      print('Error showing immediate notification: $e');
    }
  }
}
