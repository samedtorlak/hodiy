import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hodiy/app.dart';
import 'package:hodiy/core/storage/prefs_keys.dart';
import 'package:hodiy/features/settings/state/settings_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('renders the app in Tajik without localization exceptions', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({PrefsKeys.localeCode: 'tg'});
    final settings = SettingsController();
    await settings.load();

    await tester.pumpWidget(HodiyApp(settings: settings));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Шаҳрро интихоб кунед'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
