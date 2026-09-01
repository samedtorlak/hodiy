import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hodiy/app.dart';
import 'package:hodiy/features/settings/state/settings_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('opens the city picker when no location is configured', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final settings = SettingsController();
    await settings.load();

    await tester.pumpWidget(HodiyApp(settings: settings));
    await tester.pumpAndSettle();

    expect(find.text('Choose a city'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
