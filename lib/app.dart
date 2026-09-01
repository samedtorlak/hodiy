import 'package:flutter/material.dart';
import 'package:hodiy/core/localization/generated/app_localizations.dart';
import 'package:hodiy/features/prayer_times/state/prayer_controller.dart';
import 'package:hodiy/features/prayer_times/ui/home_screen.dart';
import 'package:hodiy/features/settings/state/settings_controller.dart';
import 'package:provider/provider.dart';

class HodiyApp extends StatelessWidget {
  const HodiyApp({required this.settings, super.key});

  final SettingsController settings;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsController>.value(value: settings),
        ChangeNotifierProxyProvider<SettingsController, PrayerController>(
          create: (_) => PrayerController(settings),
          update: (_, currentSettings, prayerController) {
            final controller =
                prayerController ?? PrayerController(currentSettings);
            controller.recompute();
            return controller;
          },
        ),
      ],
      child: MaterialApp(
        title: 'Hodiy',
        locale: settings.locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
        home: const HomeScreen(),
      ),
    );
  }
}
