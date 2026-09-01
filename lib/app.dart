import 'package:flutter/material.dart';
import 'package:hodiy/core/localization/generated/app_localizations.dart';
import 'package:hodiy/core/navigation/app_shell.dart';
import 'package:hodiy/features/notifications/notification_service.dart';
import 'package:hodiy/features/notifications/scheduler.dart';
import 'package:hodiy/features/prayer_times/state/prayer_controller.dart';
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
        Provider<NotificationService>(create: (_) => NotificationService()),
        Provider<NotificationServiceBase>(
          create: (context) => context.read<NotificationService>(),
        ),
        Provider<Scheduler>(
          create: (context) => Scheduler(context.read<NotificationService>()),
        ),
      ],
      child: Builder(
        builder: (context) => MaterialApp(
          title: 'Hodiy',
          locale: context.watch<SettingsController>().locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
          home: const AppShell(),
        ),
      ),
    );
  }
}
