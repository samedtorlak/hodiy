import 'package:adhan/adhan.dart';

class DayTimes {
  const DayTimes({
    required this.imsak,
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });

  final DateTime imsak;
  final DateTime fajr;
  final DateTime sunrise;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;
}

DayTimes computeDayTimes({
  required double lat,
  required double lon,
  required DateTime date,
  required CalculationParameters params,
  int imsakOffsetMinutes = 0,
}) {
  final coordinates = Coordinates(lat, lon);
  final dateComponents = DateComponents(date.year, date.month, date.day);
  final prayerTimes = PrayerTimes.utc(coordinates, dateComponents, params);
  final fajr = prayerTimes.fajr;

  return DayTimes(
    imsak: fajr.subtract(Duration(minutes: imsakOffsetMinutes)),
    fajr: fajr,
    sunrise: prayerTimes.sunrise,
    dhuhr: prayerTimes.dhuhr,
    asr: prayerTimes.asr,
    maghrib: prayerTimes.maghrib,
    isha: prayerTimes.isha,
  );
}

MapEntry<String, DateTime> nextPrayer(
  DayTimes today,
  DayTimes tomorrow,
  DateTime now,
) {
  final todayPrayers = <MapEntry<String, DateTime>>[
    MapEntry('fajr', today.fajr),
    MapEntry('sunrise', today.sunrise),
    MapEntry('dhuhr', today.dhuhr),
    MapEntry('asr', today.asr),
    MapEntry('maghrib', today.maghrib),
    MapEntry('isha', today.isha),
  ];

  for (final prayer in todayPrayers) {
    if (prayer.value.isAfter(now)) {
      return prayer;
    }
  }

  return MapEntry('fajr', tomorrow.fajr);
}
