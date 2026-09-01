import 'package:adhan/adhan.dart';

abstract final class PrayerCalcDefaults {
  static CalculationParameters defaultParamsFor(String countryCode) {
    final normalizedCountryCode = countryCode.trim().toUpperCase();
    final method = normalizedCountryCode == 'TR'
        ? CalculationMethod.turkey
        : CalculationMethod.muslim_world_league;
    final params = method.getParameters();

    params.madhab = Madhab.hanafi;
    params.highLatitudeRule = normalizedCountryCode == 'KZ'
        ? HighLatitudeRule.twilight_angle
        : HighLatitudeRule.middle_of_the_night;

    return params;
  }
}
