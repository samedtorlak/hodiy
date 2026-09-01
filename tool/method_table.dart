import 'package:adhan/adhan.dart';

const _cities = <_City>[
  _City('Toshkent', 41.2995, 69.2401),
  _City('Almaty', 43.2220, 76.8512),
  _City('Bishkek', 42.8746, 74.5698),
  _City('Dushanbe', 38.5598, 68.7870),
  _City('Petropavl', 54.8756, 69.1628),
];

const _methods = <_Method>[
  _Method('Muslim World League', CalculationMethod.muslim_world_league),
  _Method('Karachi', CalculationMethod.karachi),
  _Method('Turkey', CalculationMethod.turkey),
  _Method('Umm al-Qura', CalculationMethod.umm_al_qura),
];

void main() {
  final now = DateTime.now();
  final date = DateComponents(now.year, now.month, now.day);

  print(
    'Prayer method comparison for ${now.year}-${_twoDigits(now.month)}-'
    '${_twoDigits(now.day)} (UTC)',
  );
  print(
    '${'City'.padRight(12)}'
    '${'Method'.padRight(22)}'
    '${'Fajr'.padRight(7)}'
    '${'Dhuhr'.padRight(7)}'
    '${'Asr'.padRight(7)}'
    '${'Maghrib'.padRight(9)}'
    'Isha',
  );

  for (final city in _cities) {
    final coordinates = Coordinates(city.latitude, city.longitude);

    for (final method in _methods) {
      final params = method.calculationMethod.getParameters();
      params.madhab = Madhab.hanafi;
      final times = PrayerTimes.utc(coordinates, date, params);

      print(
        '${city.name.padRight(12)}'
        '${method.name.padRight(22)}'
        '${_formatUtc(times.fajr).padRight(7)}'
        '${_formatUtc(times.dhuhr).padRight(7)}'
        '${_formatUtc(times.asr).padRight(7)}'
        '${_formatUtc(times.maghrib).padRight(9)}'
        '${_formatUtc(times.isha)}',
      );
    }
  }
}

String _formatUtc(DateTime time) {
  final utc = time.toUtc();
  return '${_twoDigits(utc.hour)}:${_twoDigits(utc.minute)}';
}

String _twoDigits(int value) => value.toString().padLeft(2, '0');

class _City {
  const _City(this.name, this.latitude, this.longitude);

  final String name;
  final double latitude;
  final double longitude;
}

class _Method {
  const _Method(this.name, this.calculationMethod);

  final String name;
  final CalculationMethod calculationMethod;
}
