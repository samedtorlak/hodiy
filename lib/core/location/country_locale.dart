import 'dart:ui';

import 'cities.dart';
import 'nearest_city.dart';

// Rough bounding box; precision is not needed because the result only picks
// a default UI language.
bool _isInTurkey(double lat, double lon) =>
    lat >= 35.8 && lat <= 42.3 && lon >= 25.5 && lon <= 44.9;

bool _isInCentralAsia(double lat, double lon) =>
    lat >= 35.0 && lat <= 56.0 && lon >= 46.0 && lon <= 88.0;

String? countryCodeForPosition(double lat, double lon) {
  if (_isInTurkey(lat, lon)) {
    return 'TR';
  }
  if (_isInCentralAsia(lat, lon)) {
    return nearestCity(lat, lon, centralAsianCities).countryCode;
  }
  return null;
}

Locale? localeForCountry(String? countryCode) {
  return switch (countryCode) {
    'TR' => const Locale('tr'),
    'UZ' => const Locale('uz'),
    'KZ' => const Locale('kk'),
    'KG' => const Locale('ky'),
    'TJ' => const Locale('tg'),
    // Turkmen is not supported; Russian is the most widely understood.
    'TM' => const Locale('ru'),
    _ => null,
  };
}
