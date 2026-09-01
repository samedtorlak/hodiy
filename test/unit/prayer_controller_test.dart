import 'package:flutter_test/flutter_test.dart';
import 'package:hodiy/features/prayer_times/state/prayer_controller.dart';
import 'package:hodiy/features/settings/state/settings_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('computes prayer times when a location is available', () async {
    final settings = SettingsController();
    await settings.setLocation(lat: 41.2995, lon: 69.2401, source: 'manual');
    final controller = PrayerController(settings);
    addTearDown(controller.dispose);

    controller.recompute();

    expect(controller.today, isNotNull);
    expect(controller.next, isNotNull);
  });

  test('recomputes automatically when the imsak offset changes', () async {
    final settings = SettingsController();
    await settings.setLocation(lat: 41.2995, lon: 69.2401, source: 'manual');
    final controller = PrayerController(settings);
    addTearDown(controller.dispose);
    controller.recompute();
    final originalImsak = controller.today!.imsak;

    await settings.setImsakOffset(10);

    expect(
      originalImsak.difference(controller.today!.imsak),
      const Duration(minutes: 10),
    );
  });
}
