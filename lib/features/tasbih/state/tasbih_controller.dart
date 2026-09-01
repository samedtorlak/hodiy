import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:hodiy/core/storage/prefs_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TasbihController extends ChangeNotifier {
  int count = 0;
  int target = 33;
  int laps = 0;
  bool justCompletedLap = false;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    count = prefs.getInt(PrefsKeys.tasbihCount) ?? count;
    target = prefs.getInt(PrefsKeys.tasbihTarget) ?? target;
    notifyListeners();
  }

  void increment() {
    justCompletedLap = false;
    count++;
    if (count >= target) {
      laps++;
      count = 0;
      justCompletedLap = true;
    }
    notifyListeners();
    unawaited(_persist());
  }

  void setTarget(int newTarget) {
    target = newTarget;
    notifyListeners();
    unawaited(_persist());
  }

  void reset() {
    count = 0;
    notifyListeners();
    unawaited(_persist());
  }

  void acknowledgeLapCompletion() {
    justCompletedLap = false;
    notifyListeners();
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(PrefsKeys.tasbihCount, count);
      await prefs.setInt(PrefsKeys.tasbihTarget, target);
    } catch (error, stackTrace) {
      debugPrint('Failed to save tasbih state: $error\n$stackTrace');
    }
  }
}
