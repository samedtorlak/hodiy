import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

abstract class NotificationServiceBase {
  Future<void> init();

  Future<bool> requestPermission();

  Future<bool> canScheduleExact();

  Future<bool> requestExactAlarmPermission();

  Future<void> scheduleAt({
    required int id,
    required String channelId,
    required String title,
    required String body,
    required DateTime whenUtc,
    required bool exact,
  });

  Future<void> cancelAll();

  Future<void> showNow({
    required int id,
    required String title,
    required String body,
  });
}

class NotificationService implements NotificationServiceBase {
  late final FlutterLocalNotificationsPlugin _plugin;

  @override
  Future<void> init() async {
    _plugin = FlutterLocalNotificationsPlugin();
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    await _plugin.initialize(
      const InitializationSettings(android: androidSettings),
    );

    const defaultChannel = AndroidNotificationChannel(
      'prayer_default',
      'Prayer reminders',
      importance: Importance.high,
    );
    const adhanChannel = AndroidNotificationChannel(
      'prayer_adhan',
      'Prayer reminders (adhan)',
      importance: Importance.high,
    );
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.createNotificationChannel(defaultChannel);
    await androidPlugin?.createNotificationChannel(adhanChannel);

    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.UTC);
  }

  @override
  Future<bool> requestPermission() async {
    return await _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.requestNotificationsPermission() ??
        false;
  }

  @override
  Future<bool> canScheduleExact() async {
    return await _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.canScheduleExactNotifications() ??
        false;
  }

  @override
  Future<bool> requestExactAlarmPermission() async {
    return await _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.requestExactAlarmsPermission() ??
        false;
  }

  @override
  Future<void> scheduleAt({
    required int id,
    required String channelId,
    required String title,
    required String body,
    required DateTime whenUtc,
    required bool exact,
  }) {
    final channelName = channelId == 'prayer_adhan'
        ? 'Prayer reminders (adhan)'
        : 'Prayer reminders';
    return _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(whenUtc, tz.UTC),
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: exact
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  @override
  Future<void> cancelAll() => _plugin.cancelAll();

  @override
  Future<void> showNow({
    required int id,
    required String title,
    required String body,
  }) {
    return _plugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'prayer_default',
          'Prayer reminders',
        ),
      ),
    );
  }
}
