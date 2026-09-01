import 'dart:ui';

import 'package:adhan/adhan.dart';
import 'package:flutter/foundation.dart';
import 'package:hodiy/core/storage/prefs_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsController extends ChangeNotifier {
  static const prayerNames = <String>[
    'imsak',
    'fajr',
    'sunrise',
    'dhuhr',
    'asr',
    'maghrib',
    'isha',
  ];

  Locale _locale = const Locale('en');
  String? _cityCode;
  double? _lat;
  double? _lon;
  String _locationSource = 'none';
  CalculationMethod _calcMethod = CalculationMethod.muslim_world_league;
  Madhab _madhab = Madhab.hanafi;
  HighLatitudeRule _highLatitudeRule = HighLatitudeRule.middle_of_the_night;
  int _hijriOffsetDays = 0;
  int _imsakOffsetMinutes = 0;
  final Map<String, bool> _notificationsEnabled = {
    for (final prayer in prayerNames)
      prayer: prayer != 'imsak' && prayer != 'sunrise',
  };
  String _soundType = 'default';

  Locale get locale => _locale;
  String? get cityCode => _cityCode;
  double? get lat => _lat;
  double? get lon => _lon;
  String get locationSource => _locationSource;
  CalculationMethod get calcMethod => _calcMethod;
  Madhab get madhab => _madhab;
  HighLatitudeRule get highLatitudeRule => _highLatitudeRule;
  int get hijriOffsetDays => _hijriOffsetDays;
  int get imsakOffsetMinutes => _imsakOffsetMinutes;
  Map<String, bool> get notificationsEnabled =>
      Map.unmodifiable(_notificationsEnabled);
  String get soundType => _soundType;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _locale = Locale(prefs.getString(PrefsKeys.localeCode) ?? 'en');
    _cityCode = prefs.getString(PrefsKeys.cityCode);
    _lat = prefs.getDouble(PrefsKeys.lat);
    _lon = prefs.getDouble(PrefsKeys.lon);
    _locationSource = prefs.getString(PrefsKeys.locationSource) ?? 'none';
    _calcMethod = CalculationMethod.values.firstWhere(
      (method) => method.name == prefs.getString(PrefsKeys.calcMethodName),
      orElse: () => CalculationMethod.muslim_world_league,
    );
    _madhab = Madhab.values.firstWhere(
      (madhab) => madhab.name == prefs.getString(PrefsKeys.madhabName),
      orElse: () => Madhab.hanafi,
    );
    _highLatitudeRule = HighLatitudeRule.values.firstWhere(
      (rule) => rule.name == prefs.getString(PrefsKeys.highLatitudeRuleName),
      orElse: () => HighLatitudeRule.middle_of_the_night,
    );
    _hijriOffsetDays = (prefs.getInt(PrefsKeys.hijriOffsetDays) ?? 0)
        .clamp(-2, 2)
        .toInt();
    _imsakOffsetMinutes = prefs.getInt(PrefsKeys.imsakOffsetMinutes) ?? 0;
    for (final prayer in prayerNames) {
      _notificationsEnabled[prayer] =
          prefs.getBool('${PrefsKeys.notificationsEnabledPrefix}$prayer') ??
          (prayer != 'imsak' && prayer != 'sunrise');
    }
    _soundType = prefs.getString(PrefsKeys.soundType) ?? 'default';
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) {
    _locale = locale;
    notifyListeners();
    return _save((prefs) async {
      await prefs.setString(PrefsKeys.localeCode, locale.languageCode);
    });
  }

  Future<void> setLocation({
    required double lat,
    required double lon,
    required String source,
    String? cityCode,
  }) {
    _lat = lat;
    _lon = lon;
    _locationSource = source;
    _cityCode = cityCode;
    notifyListeners();
    return _save((prefs) async {
      await prefs.setDouble(PrefsKeys.lat, lat);
      await prefs.setDouble(PrefsKeys.lon, lon);
      await prefs.setString(PrefsKeys.locationSource, source);
      if (cityCode == null) {
        await prefs.remove(PrefsKeys.cityCode);
      } else {
        await prefs.setString(PrefsKeys.cityCode, cityCode);
      }
    });
  }

  Future<void> clearLocation() {
    _lat = null;
    _lon = null;
    _cityCode = null;
    _locationSource = 'none';
    notifyListeners();
    return _save((prefs) async {
      await prefs.remove(PrefsKeys.lat);
      await prefs.remove(PrefsKeys.lon);
      await prefs.remove(PrefsKeys.cityCode);
      await prefs.setString(PrefsKeys.locationSource, 'none');
    });
  }

  Future<void> setCalcMethod(CalculationMethod method) {
    _calcMethod = method;
    notifyListeners();
    return _save((prefs) async {
      await prefs.setString(PrefsKeys.calcMethodName, method.name);
    });
  }

  Future<void> setMadhab(Madhab madhab) {
    _madhab = madhab;
    notifyListeners();
    return _save((prefs) async {
      await prefs.setString(PrefsKeys.madhabName, madhab.name);
    });
  }

  Future<void> setHighLatitudeRule(HighLatitudeRule rule) {
    _highLatitudeRule = rule;
    notifyListeners();
    return _save((prefs) async {
      await prefs.setString(PrefsKeys.highLatitudeRuleName, rule.name);
    });
  }

  Future<void> setHijriOffset(int days) {
    _hijriOffsetDays = days.clamp(-2, 2).toInt();
    notifyListeners();
    return _save((prefs) async {
      await prefs.setInt(PrefsKeys.hijriOffsetDays, _hijriOffsetDays);
    });
  }

  Future<void> setImsakOffset(int minutes) {
    _imsakOffsetMinutes = minutes;
    notifyListeners();
    return _save((prefs) async {
      await prefs.setInt(PrefsKeys.imsakOffsetMinutes, minutes);
    });
  }

  Future<void> setNotificationEnabled(String prayer, bool enabled) {
    if (!prayerNames.contains(prayer)) {
      throw ArgumentError.value(prayer, 'prayer', 'Unknown prayer name');
    }
    _notificationsEnabled[prayer] = enabled;
    notifyListeners();
    return _save((prefs) async {
      await prefs.setBool(
        '${PrefsKeys.notificationsEnabledPrefix}$prayer',
        enabled,
      );
    });
  }

  Future<void> setSoundType(String soundType) {
    _soundType = soundType;
    notifyListeners();
    return _save((prefs) async {
      await prefs.setString(PrefsKeys.soundType, soundType);
    });
  }

  Future<void> _save(
    Future<void> Function(SharedPreferences prefs) operation,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await operation(prefs);
    } catch (error, stackTrace) {
      debugPrint('Failed to save settings: $error\n$stackTrace');
      rethrow;
    }
  }
}
