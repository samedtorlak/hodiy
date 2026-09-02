import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hodiy/core/ads/banner_slot.dart';
import 'package:hodiy/core/localization/generated/app_localizations.dart';
import 'package:hodiy/features/notifications/notification_service.dart';
import 'package:hodiy/features/notifications/scheduler.dart';
import 'package:hodiy/features/prayer_times/domain/prayer_calculator.dart';
import 'package:hodiy/features/prayer_times/state/prayer_controller.dart';
import 'package:hodiy/features/prayer_times/ui/home_screen.dart';
import 'package:hodiy/features/qibla/ui/qibla_screen.dart';
import 'package:hodiy/features/settings/state/settings_controller.dart';
import 'package:hodiy/features/settings/ui/settings_screen.dart';
import 'package:hodiy/features/tasbih/ui/tasbih_screen.dart';
import 'package:hodiy/features/updater/ui/update_prompt.dart';
import 'package:hodiy/features/updater/update_service.dart';
import 'package:provider/provider.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;
  late final SettingsController _settings;
  bool _notificationServiceReady = false;

  @override
  void initState() {
    super.initState();
    _settings = context.read<SettingsController>();
    _settings.addListener(_onSettingsChanged);
    unawaited(_initializeNotifications());
    // Release-only: never contact GitHub from debug runs or widget tests.
    if (kReleaseMode && updaterEnabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          unawaited(maybePromptForUpdate(context, UpdateService()));
        }
      });
    }
  }

  Future<void> _initializeNotifications() async {
    final notificationService = context.read<NotificationService>();
    try {
      await notificationService.init();
      _notificationServiceReady = true;
      try {
        await notificationService.requestPermission();
      } catch (error, stackTrace) {
        debugPrint(
          'Failed to request notification permission: $error\n$stackTrace',
        );
      }
      if (mounted) {
        _onSettingsChanged();
      }
    } catch (error, stackTrace) {
      debugPrint('Failed to initialize notifications: $error\n$stackTrace');
    }
  }

  void _onSettingsChanged() {
    final lat = _settings.lat;
    final lon = _settings.lon;
    if (!_notificationServiceReady || lat == null || lon == null) {
      return;
    }

    unawaited(_reschedule(lat, lon));
  }

  Future<void> _reschedule(double lat, double lon) async {
    final prayerController = context.read<PrayerController>();
    try {
      await context.read<Scheduler>().reschedule(
        settings: _settings,
        computeForDate: (date) => computeDayTimes(
          lat: lat,
          lon: lon,
          date: date,
          params: prayerController.buildParams(),
          imsakOffsetMinutes: _settings.imsakOffsetMinutes,
        ),
      );
    } catch (error, stackTrace) {
      debugPrint('Failed to reschedule notifications: $error\n$stackTrace');
    }
  }

  @override
  void dispose() {
    _settings.removeListener(_onSettingsChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            tooltip: l10n.settingsTitle,
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: const [HomeScreen(), QiblaScreen(), TasbihScreen()],
            ),
          ),
          const BannerSlot(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.access_time),
            label: l10n.navPrayerTimes,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.explore),
            label: l10n.navQibla,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.fingerprint),
            label: l10n.navTasbih,
          ),
        ],
      ),
    );
  }
}
