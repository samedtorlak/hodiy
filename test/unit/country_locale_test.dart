import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:hodiy/core/location/country_locale.dart';

void main() {
  group('countryCodeForPosition', () {
    test('resolves Istanbul to TR', () {
      expect(countryCodeForPosition(41.0082, 28.9784), 'TR');
    });

    test('resolves Ankara to TR', () {
      expect(countryCodeForPosition(39.9334, 32.8597), 'TR');
    });

    test('resolves Tashkent to UZ', () {
      expect(countryCodeForPosition(41.2995, 69.2401), 'UZ');
    });

    test('resolves Almaty to KZ', () {
      expect(countryCodeForPosition(43.2389, 76.8897), 'KZ');
    });

    test('resolves Bishkek to KG', () {
      expect(countryCodeForPosition(42.8746, 74.5698), 'KG');
    });

    test('resolves Dushanbe to TJ', () {
      expect(countryCodeForPosition(38.5598, 68.7870), 'TJ');
    });

    test('resolves Ashgabat to TM', () {
      expect(countryCodeForPosition(37.9601, 58.3261), 'TM');
    });

    test('returns null for Berlin', () {
      expect(countryCodeForPosition(52.5200, 13.4050), isNull);
    });
  });

  group('localeForCountry', () {
    test('maps supported countries to their language', () {
      expect(localeForCountry('TR'), const Locale('tr'));
      expect(localeForCountry('UZ'), const Locale('uz'));
      expect(localeForCountry('KZ'), const Locale('kk'));
      expect(localeForCountry('KG'), const Locale('ky'));
      expect(localeForCountry('TJ'), const Locale('tg'));
    });

    test('maps TM to Russian because Turkmen is unsupported', () {
      expect(localeForCountry('TM'), const Locale('ru'));
    });

    test('returns null for unknown or missing country', () {
      expect(localeForCountry('DE'), isNull);
      expect(localeForCountry(null), isNull);
    });
  });
}
