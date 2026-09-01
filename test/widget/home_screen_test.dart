import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hodiy/app.dart';
import 'package:hodiy/features/settings/state/settings_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('shows the Hijri card and all seven prayer rows', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final settings = SettingsController();
    await settings.load();
    await settings.setLocation(
      lat: 41.2995,
      lon: 69.2401,
      source: 'manual',
      cityCode: 'TAS',
    );

    await tester.pumpWidget(HodiyApp(settings: settings));
    await tester.pump();

    expect(find.text('Hijri date'), findsOneWidget);
    expect(find.text('Imsak'), findsOneWidget);
    expect(find.text('Fajr'), findsWidgets);
    expect(find.text('Sunrise'), findsWidgets);
    expect(find.text('Dhuhr'), findsWidgets);
    expect(find.text('Asr'), findsWidgets);
    expect(find.text('Maghrib'), findsWidgets);
    expect(find.text('Isha'), findsWidgets);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
