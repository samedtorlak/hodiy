import 'dart:async';

import 'package:adhan/adhan.dart';
import 'package:flutter/foundation.dart';
import 'package:hodiy/features/prayer_times/domain/prayer_calculator.dart';
import 'package:hodiy/features/settings/state/settings_controller.dart';

class PrayerController extends ChangeNotifier {
  PrayerController(this._settings) {
    _settings.addListener(recompute);
  }

  final SettingsController _settings;
  DayTimes? _today;
  DayTimes? _tomorrow;
  MapEntry<String, DateTime>? _next;
  Duration? _countdown;
  Timer? _timer;

  DayTimes? get today => _today;
  DayTimes? get tomorrow => _tomorrow;
  MapEntry<String, DateTime>? get next => _next;
  Duration? get countdown => _countdown;

  CalculationParameters buildParams() {
    return _settings.calcMethod.getParameters()
      ..madhab = _settings.madhab
      ..highLatitudeRule = _settings.highLatitudeRule;
  }

  void recompute() {
    final lat = _settings.lat;
    final lon = _settings.lon;
    if (lat == null || lon == null) {
      _today = null;
      _tomorrow = null;
      _next = null;
      _countdown = null;
      notifyListeners();
      return;
    }

    final params = buildParams();
    final now = DateTime.now().toUtc();
    final todayDate = DateTime.utc(now.year, now.month, now.day);
    final tomorrowDate = todayDate.add(const Duration(days: 1));
    _today = computeDayTimes(
      lat: lat,
      lon: lon,
      date: todayDate,
      params: params,
      imsakOffsetMinutes: _settings.imsakOffsetMinutes,
    );
    _tomorrow = computeDayTimes(
      lat: lat,
      lon: lon,
      date: tomorrowDate,
      params: params,
      imsakOffsetMinutes: _settings.imsakOffsetMinutes,
    );
    _next = nextPrayer(_today!, _tomorrow!, now);
    _countdown = _next!.value.difference(now);
    notifyListeners();
  }

  void startTicking() {
    stopTicking();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_next == null) {
        return;
      }
      _countdown = _next!.value.difference(DateTime.now().toUtc());
      notifyListeners();
    });
  }

  void stopTicking() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _settings.removeListener(recompute);
    stopTicking();
    super.dispose();
  }
}
