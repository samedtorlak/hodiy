import 'dart:ui';

const _supportedLanguageCodes = {'en', 'ru', 'uz', 'kk', 'ky', 'tg'};

Locale resolveAppLocale(Locale? deviceLocale, List<Locale> supportedLocales) {
  final languageCode = deviceLocale?.languageCode;
  if (languageCode == null || !_supportedLanguageCodes.contains(languageCode)) {
    return const Locale('en');
  }

  for (final locale in supportedLocales) {
    if (locale.languageCode == languageCode) {
      return locale;
    }
  }
  return const Locale('en');
}
