import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:hodiy/core/localization/locale_resolver.dart';

void main() {
  const supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
    Locale('uz'),
    Locale('kk'),
    Locale('ky'),
    Locale('tg'),
  ];

  test('returns Uzbek for an Uzbek device locale with a region', () {
    expect(
      resolveAppLocale(const Locale('uz', 'UZ'), supportedLocales),
      const Locale('uz'),
    );
  });

  test('returns Tajik for a Tajik device locale', () {
    expect(
      resolveAppLocale(const Locale('tg'), supportedLocales),
      const Locale('tg'),
    );
  });

  test('falls back to English for an unsupported device locale', () {
    expect(
      resolveAppLocale(const Locale('de'), supportedLocales),
      const Locale('en'),
    );
  });

  test('falls back to English when the device locale is unavailable', () {
    expect(resolveAppLocale(null, supportedLocales), const Locale('en'));
  });

  test('falls back to English when the matched locale is not supplied', () {
    expect(
      resolveAppLocale(const Locale('tg'), const [Locale('en')]),
      const Locale('en'),
    );
  });
}
