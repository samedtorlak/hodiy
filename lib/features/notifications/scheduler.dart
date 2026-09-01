import 'package:hodiy/features/notifications/notification_service.dart';
import 'package:hodiy/features/prayer_times/domain/prayer_calculator.dart';
import 'package:hodiy/features/settings/state/settings_controller.dart';

class Scheduler {
  const Scheduler(this.notificationService);

  final NotificationServiceBase notificationService;

  Future<void> reschedule({
    required SettingsController settings,
    required DayTimes Function(DateTime date) computeForDate,
  }) async {
    await notificationService.cancelAll();
    final exact = await notificationService.canScheduleExact();
    final now = DateTime.now().toUtc();
    final channelId = settings.soundType == 'adhan'
        ? 'prayer_adhan'
        : 'prayer_default';

    for (var day = 0; day < 10; day++) {
      final date = now.add(Duration(days: day));
      final times = computeForDate(DateTime(date.year, date.month, date.day));
      final prayers = <MapEntry<String, DateTime>>[
        MapEntry('imsak', times.imsak),
        MapEntry('fajr', times.fajr),
        MapEntry('sunrise', times.sunrise),
        MapEntry('dhuhr', times.dhuhr),
        MapEntry('asr', times.asr),
        MapEntry('maghrib', times.maghrib),
        MapEntry('isha', times.isha),
      ];

      for (var prayerIndex = 0; prayerIndex < prayers.length; prayerIndex++) {
        final prayer = prayers[prayerIndex];
        if (settings.notificationsEnabled[prayer.key] != true ||
            prayer.value.isBefore(now)) {
          continue;
        }
        await notificationService.scheduleAt(
          id: day * 10 + prayerIndex,
          channelId: channelId,
          title: 'Prayer time',
          body: prayer.key,
          whenUtc: prayer.value,
          exact: exact,
        );
      }

      if (day == 9) {
        await notificationService.scheduleAt(
          id: 999,
          channelId: 'prayer_default',
          title: 'Prayer times need an update',
          body: 'Open the app to keep prayer times up to date',
          whenUtc: times.dhuhr,
          exact: exact,
        );
      }
    }
  }
}
