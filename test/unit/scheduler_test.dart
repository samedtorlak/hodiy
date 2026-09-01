import 'package:flutter_test/flutter_test.dart';
import 'package:hodiy/features/notifications/notification_service.dart';
import 'package:hodiy/features/notifications/scheduler.dart';
import 'package:hodiy/features/prayer_times/domain/prayer_calculator.dart';
import 'package:hodiy/features/settings/state/settings_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test(
    'schedules seventy prayer notifications and one renewal reminder',
    () async {
      final fake = FakeNotificationService();
      final settings = SettingsController();
      await _setAllPrayerNotifications(settings, enabled: true);

      await Scheduler(fake)
          .reschedule(settings: settings, computeForDate: _futureDayTimes);

      expect(fake.scheduledCalls, hasLength(71));
    },
  );

  test('uses a unique id for every scheduled notification', () async {
    final fake = FakeNotificationService();
    final settings = SettingsController();
    await _setAllPrayerNotifications(settings, enabled: true);

    await Scheduler(fake)
        .reschedule(settings: settings, computeForDate: _futureDayTimes);

    final ids = fake.scheduledCalls.map((call) => call.id).toSet();
    expect(ids, hasLength(fake.scheduledCalls.length));
  });

  test('does not schedule imsak or sunrise by default', () async {
    final fake = FakeNotificationService();

    await Scheduler(fake).reschedule(
      settings: SettingsController(),
      computeForDate: _futureDayTimes,
    );

    final prayerCalls = fake.scheduledCalls.where((call) => call.id != 999);
    expect(
      prayerCalls,
      everyElement(
        predicate<ScheduledCall>(
          (call) => call.id % 10 != 0 && call.id % 10 != 2,
        ),
      ),
    );
  });

  test(
    'keeps only the renewal reminder when every prayer is disabled',
    () async {
      final fake = FakeNotificationService();
      final settings = SettingsController();
      await _setAllPrayerNotifications(settings, enabled: false);

      await Scheduler(fake)
          .reschedule(settings: settings, computeForDate: _futureDayTimes);

      expect(fake.scheduledCalls, hasLength(1));
      expect(fake.scheduledCalls.single.id, 999);
    },
  );
}

Future<void> _setAllPrayerNotifications(
  SettingsController settings, {
  required bool enabled,
}) async {
  for (final prayer in SettingsController.prayerNames) {
    await settings.setNotificationEnabled(prayer, enabled);
  }
}

DayTimes _futureDayTimes(DateTime date) {
  final now = DateTime.now().toUtc();
  final today = DateTime.utc(now.year, now.month, now.day);
  final requestedDay = DateTime.utc(date.year, date.month, date.day);
  final dayOffset = requestedDay.difference(today).inDays;
  final firstPrayer = now.add(Duration(days: dayOffset, hours: 1));

  return DayTimes(
    imsak: firstPrayer,
    fajr: firstPrayer.add(const Duration(minutes: 1)),
    sunrise: firstPrayer.add(const Duration(minutes: 2)),
    dhuhr: firstPrayer.add(const Duration(minutes: 3)),
    asr: firstPrayer.add(const Duration(minutes: 4)),
    maghrib: firstPrayer.add(const Duration(minutes: 5)),
    isha: firstPrayer.add(const Duration(minutes: 6)),
  );
}

class ScheduledCall {
  const ScheduledCall({
    required this.id,
    required this.channelId,
    required this.title,
    required this.body,
    required this.whenUtc,
    required this.exact,
  });

  final int id;
  final String channelId;
  final String title;
  final String body;
  final DateTime whenUtc;
  final bool exact;
}

class FakeNotificationService implements NotificationServiceBase {
  final List<ScheduledCall> scheduledCalls = [];

  @override
  Future<bool> canScheduleExact() async => true;

  @override
  Future<void> cancelAll() async {}

  @override
  Future<void> init() async {}

  @override
  Future<bool> requestExactAlarmPermission() async => true;

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<void> scheduleAt({
    required int id,
    required String channelId,
    required String title,
    required String body,
    required DateTime whenUtc,
    required bool exact,
  }) async {
    scheduledCalls.add(
      ScheduledCall(
        id: id,
        channelId: channelId,
        title: title,
        body: body,
        whenUtc: whenUtc,
        exact: exact,
      ),
    );
  }

  @override
  Future<void> showNow({
    required int id,
    required String title,
    required String body,
  }) async {}
}
