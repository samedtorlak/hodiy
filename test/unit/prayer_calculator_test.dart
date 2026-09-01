import 'package:adhan/adhan.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hodiy/features/prayer_times/domain/calc_defaults.dart';
import 'package:hodiy/features/prayer_times/domain/prayer_calculator.dart';

void main() {
  group('PrayerCalcDefaults', () {
    test('uses twilight angle for Kazakhstan', () {
      final params = PrayerCalcDefaults.defaultParamsFor('kz');

      expect(params.method, CalculationMethod.muslim_world_league);
      expect(params.madhab, Madhab.hanafi);
      expect(params.highLatitudeRule, HighLatitudeRule.twilight_angle);
    });

    test('uses the Turkey method for Turkey', () {
      final params = PrayerCalcDefaults.defaultParamsFor('TR');

      expect(params.method, CalculationMethod.turkey);
      expect(params.madhab, Madhab.hanafi);
    });

    test('uses the safe default for other countries', () {
      final params = PrayerCalcDefaults.defaultParamsFor('OTHER');

      expect(params.method, CalculationMethod.muslim_world_league);
      expect(params.madhab, Madhab.hanafi);
      expect(params.highLatitudeRule, HighLatitudeRule.middle_of_the_night);
    });
  });

  group('computeDayTimes', () {
    test('returns ordered UTC prayer times for Toshkent', () {
      final times = computeDayTimes(
        lat: 41.2995,
        lon: 69.2401,
        date: DateTime(2025, 3, 1),
        params: PrayerCalcDefaults.defaultParamsFor('UZ'),
      );

      expect(times.fajr.isBefore(times.sunrise), isTrue);
      expect(times.sunrise.isBefore(times.dhuhr), isTrue);
      expect(times.dhuhr.isBefore(times.asr), isTrue);
      expect(times.asr.isBefore(times.maghrib), isTrue);
      expect(times.maghrib.isBefore(times.isha), isTrue);
      expect(
        [
          times.imsak,
          times.fajr,
          times.sunrise,
          times.dhuhr,
          times.asr,
          times.maghrib,
          times.isha,
        ].every((time) => time.isUtc),
        isTrue,
      );
    });

    test('returns valid high-latitude times for Petropavl in summer', () {
      final params = PrayerCalcDefaults.defaultParamsFor('KZ');
      params.highLatitudeRule = HighLatitudeRule.twilight_angle;

      final times = computeDayTimes(
        lat: 54.8756,
        lon: 69.1628,
        date: DateTime(2025, 6, 21),
        params: params,
      );

      expect(times.fajr, isA<DateTime>());
      expect(times.isha, isA<DateTime>());
    });

    test('subtracts the imsak offset from fajr', () {
      final params = PrayerCalcDefaults.defaultParamsFor('UZ');

      final withoutOffset = computeDayTimes(
        lat: 41.2995,
        lon: 69.2401,
        date: DateTime(2025, 3, 1),
        params: params,
      );
      final withOffset = computeDayTimes(
        lat: 41.2995,
        lon: 69.2401,
        date: DateTime(2025, 3, 1),
        params: params,
        imsakOffsetMinutes: 10,
      );

      expect(
        withoutOffset.fajr.difference(withOffset.imsak),
        const Duration(minutes: 10),
      );
    });
  });

  test('nextPrayer returns tomorrow fajr after today isha', () {
    final params = PrayerCalcDefaults.defaultParamsFor('UZ');
    final today = computeDayTimes(
      lat: 41.2995,
      lon: 69.2401,
      date: DateTime(2025, 3, 1),
      params: params,
    );
    final tomorrow = computeDayTimes(
      lat: 41.2995,
      lon: 69.2401,
      date: DateTime(2025, 3, 2),
      params: params,
    );

    final next = nextPrayer(
      today,
      tomorrow,
      today.isha.add(const Duration(hours: 1)),
    );

    expect(next.key, 'fajr');
    expect(next.value, tomorrow.fajr);
  });
}
