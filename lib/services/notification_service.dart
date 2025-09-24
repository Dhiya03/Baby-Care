import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;

import '../utils/constants.dart';

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  // Initialize notification service
  static Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings(
      '@drawable/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
  }

  // Handle notification taps
  static void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;

    if (payload == 'start_feeding') {
      // TODO: Trigger feeding start from notification
      // This would need to communicate with the app state
    }
  }

  // Request notification permissions
  static Future<bool> requestPermissions() async {
    if (await Permission.notification.isDenied) {
      final status = await Permission.notification.request();
      return status == PermissionStatus.granted;
    }
    return true;
  }

  // Schedule feeding reminder
  static Future<void> scheduleReminder({
    required DateTime scheduledTime,
    required String title,
    required String body,
    int id = AppConstants.reminderNotificationId,
    bool isUrgent = false,
  }) async {
    if (!_initialized) await initialize();

    final androidDetails = AndroidNotificationDetails(
      'feeding_reminders',
      'Feeding Reminders',
      channelDescription: 'Notifications to remind you about feeding times',
      importance: isUrgent ? Importance.high : Importance.defaultImportance,
      priority: isUrgent ? Priority.high : Priority.defaultPriority,
      actions: [
        const AndroidNotificationAction(
          'start_feeding',
          'Start Feeding',
          icon: DrawableResourceAndroidBitmap('@drawable/ic_launcher'),
        ),
        const AndroidNotificationAction('ignore', 'Ignore'),
      ],
    );

    const iosDetails = DarwinNotificationDetails(
      categoryIdentifier: 'feeding_reminder',
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'feeding_reminder',
    );
  }

  // Schedule both reminder notifications after feeding
  static Future<void> scheduleFeedingReminders(DateTime lastFeedingEnd) async {
    // Cancel any existing reminders
    await cancelAllReminders();

    final reminderTime = lastFeedingEnd.add(
      const Duration(hours: AppConstants.defaultReminderHours),
    );
    final urgentTime = lastFeedingEnd.add(
      const Duration(hours: AppConstants.urgentReminderHours),
    );

    // Schedule regular reminder
    if (reminderTime.isAfter(DateTime.now())) {
      await scheduleReminder(
        scheduledTime: reminderTime,
        title: '🍼 Feeding Time',
        body:
            'It\'s been ${AppConstants.defaultReminderHours} hours since the last feeding',
        id: AppConstants.reminderNotificationId,
      );
    }

    // Schedule urgent reminder
    if (urgentTime.isAfter(DateTime.now())) {
      await scheduleReminder(
        scheduledTime: urgentTime,
        title: '🍼 Feeding Overdue!',
        body:
            'It\'s been ${AppConstants.urgentReminderHours} hours since the last feeding',
        id: AppConstants.urgentReminderNotificationId,
        isUrgent: true,
      );
    }
  }

  // Cancel specific reminder
  static Future<void> cancelReminder(int id) async {
    await _notifications.cancel(id);
  }

  // Cancel all reminders
  static Future<void> cancelAllReminders() async {
    await _notifications.cancel(AppConstants.reminderNotificationId);
    await _notifications.cancel(AppConstants.urgentReminderNotificationId);
  }

  // Show feeding timer notification (persistent during feeding)
  static Future<void> showFeedingTimerNotification({
    required String duration,
  }) async {
    if (!_initialized) await initialize();

    const androidDetails = AndroidNotificationDetails(
      'feeding_timer',
      'Feeding Timer',
      channelDescription: 'Shows active feeding session',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      autoCancel: false,
      showWhen: false,
      actions: [
        AndroidNotificationAction(
          'stop_feeding',
          'Stop Feeding',
          icon: DrawableResourceAndroidBitmap('@drawable/ic_launcher'),
        ),
      ],
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: false,
      presentBadge: false,
      presentSound: false,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      999, // Special ID for feeding timer
      '🍼 Feeding in Progress',
      'Duration: $duration',
      details,
      payload: 'feeding_timer',
    );
  }

  // Hide feeding timer notification
  static Future<void> hideFeedingTimerNotification() async {
    await _notifications.cancel(999);
  }

  // Show instant log confirmation
  static Future<void> showLogConfirmation({
    required String type,
    required String message,
  }) async {
    if (!_initialized) await initialize();

    const androidDetails = AndroidNotificationDetails(
      'log_confirmations',
      'Log Confirmations',
      channelDescription: 'Confirms when events are logged',
      importance: Importance.low,
      priority: Priority.low,
      timeoutAfter: 3000, // Auto-dismiss after 3 seconds
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: false,
      presentSound: false,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch % 1000, // Unique ID
      type,
      message,
      details,
    );
  }

  // Get pending notifications (for debugging)
  static Future<List<PendingNotificationRequest>>
      getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
}
