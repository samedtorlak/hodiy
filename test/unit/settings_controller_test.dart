import 'package:adhan/adhan.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hodiy/features/settings/state/settings_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('persists and restores a manually selected location', () async {
    final settings = SettingsController();
    await settings.setLocation(
      lat: 41.2995,
      lon: 69.2401,
      source: 'manual',
      cityCode: 'TAS',
    );

    final restored = SettingsController();
    await restored.load();

    expect(restored.lat, 41.2995);
    expect(restored.lon, 69.2401);
    expect(restored.locationSource, 'manual');
    expect(restored.cityCode, 'TAS');
  });

  test('persists and restores calculation method and madhab', () async {
    final settings = SettingsController();
    await settings.setCalcMethod(CalculationMethod.turkey);
    await settings.setMadhab(Madhab.shafi);

    final restored = SettingsController();
    await restored.load();

    expect(restored.calcMethod, CalculationMethod.turkey);
    expect(restored.madhab, Madhab.shafi);
  });
}
