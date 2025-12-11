import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  // Singleton pattern (optional)
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    // Initialize timezone package for scheduled notifications (optional but recommended)
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('UTC')); // choose appropriate zone or compute dynamically

    // Android initialization (if you support Android)
    const androidInitSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS / macOS initialization
    final iosInitSettings = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    // Windows initialization (required to use ffi implementation on Windows)
    // const windowsInitSettings = WindowsInitializationSettings(
    //   // You can provide appId for toast if needed, e.g. 'com.example.antidoom'
    //   // appId: 'com.example.antidoom',
    // );

    final initializationSettings = InitializationSettings(
      android: androidInitSettings,
      iOS: iosInitSettings,
      macOS: iosInitSettings,
      // windows: windowsInitSettings,
    );

    try {
      await _plugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (response) {
          // handle tap on notification (optional)
          debugPrint('Notification tapped: ${response.payload}');
        },
      );

      _initialized = true;
      debugPrint('NotificationService initialized successfully.');
    } catch (e, st) {
      debugPrint('NotificationService.init failed: $e\n$st');
      // Keep _initialized false so calls are guarded
    }
  }

  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String? payload,
  }) async {
    if (!_initialized) {
      debugPrint('NotificationService.scheduleDailyNotification called before init. Ignoring.');
      return;
    }
    try {
      final now = tz.TZDateTime.now(tz.local);
      var scheduled =
          tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
      if (scheduled.isBefore(now)) scheduled = scheduled.add(const Duration(days: 1));

      const platformDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder_channel',
          'Daily Reminders',
          channelDescription: 'Daily study reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      );

      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduled,
        platformDetails,
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint('NotificationService.scheduleDailyNotification error: $e');
    }
  }

  bool get isInitialized => _initialized;

  // Safe show
  Future<void> show({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_initialized) {
      debugPrint('NotificationService.show called before init. Ignoring.');
      return;
    }

    try {
      const androidDetails = AndroidNotificationDetails(
        'default_channel',
        'Default',
        channelDescription: 'General notifications',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      );

      const platformDetails = NotificationDetails(android: androidDetails);

      await _plugin.show(id, title, body, platformDetails, payload: payload);
    } catch (e) {
      debugPrint('NotificationService.show error: $e');
    }
  }

  Future<void> cancel(int id) async {
    if (!_initialized) {
      debugPrint('NotificationService.cancel called before init. Ignoring.');
      return;
    }
    try {
      await _plugin.cancel(id);
    } catch (e) {
      debugPrint('NotificationService.cancel error: $e');
    }
  }

  Future<void> cancelAll() async {
    if (!_initialized) {
      debugPrint('NotificationService.cancelAll called before init. Ignoring.');
      return;
    }
    try {
      await _plugin.cancelAll();
    } catch (e) {
      debugPrint('NotificationService.cancelAll error: $e');
    }
  }

  // Example scheduled notification (uses timezone package)
  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledAt,
    String? payload,
  }) async {
    if (!_initialized) {
      debugPrint('NotificationService.schedule called before init. Ignoring.');
      return;
    }
    try {
      final tzDate = tz.TZDateTime.from(scheduledAt, tz.local);

      const androidDetails = AndroidNotificationDetails(
        'default_channel',
        'Default',
        channelDescription: 'General notifications',
      );

      final platformDetails = NotificationDetails(android: androidDetails);

      await _plugin.zonedSchedule(
  id,
  title,
  body,
  tzDate,
  platformDetails,
  payload: payload,
  androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
  matchDateTimeComponents: DateTimeComponents.time,
);
    } catch (e) {
      debugPrint('NotificationService.schedule error: $e');
    }
  }
}
