import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:hodiy/core/localization/generated/app_localizations.dart';
import 'package:hodiy/core/location/cities.dart';
import 'package:hodiy/features/notifications/notification_service.dart';
import 'package:hodiy/features/prayer_times/ui/city_picker_screen.dart';
import 'package:hodiy/features/settings/state/settings_controller.dart';
import 'package:hodiy/features/settings/ui/about_screen.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const _supportedLocales = [
    Locale('en'),
    Locale('tr'),
    Locale('ru'),
    Locale('uz'),
    Locale('kk'),
    Locale('ky'),
    Locale('tg'),
  ];
  static const _imsakOffsets = [0, 5, 10];
  static const _hijriOffsets = [-2, -1, 0, 1, 2];
  static const _soundTypes = ['default', 'adhan'];

  bool? _canScheduleExact;

  @override
  void initState() {
    super.initState();
    _checkExactAlarmPermission();
  }

  Future<void> _checkExactAlarmPermission() async {
    try {
      final canSchedule = await context
          .read<NotificationServiceBase>()
          .canScheduleExact();
      if (mounted) {
        setState(() => _canScheduleExact = canSchedule);
      }
    } catch (error, stackTrace) {
      debugPrint('Failed to check exact alarm permission: $error\n$stackTrace');
    }
  }

  Future<void> _requestExactAlarmPermission() async {
    try {
      await context
          .read<NotificationServiceBase>()
          .requestExactAlarmPermission();
      await _checkExactAlarmPermission();
    } catch (error, stackTrace) {
      debugPrint(
        'Failed to request exact alarm permission: $error\n$stackTrace',
      );
    }
  }

  City? _selectedCity(String? cityCode) {
    if (cityCode == null) {
      return null;
    }
    for (final city in centralAsianCities) {
      if (city.code == cityCode) {
        return city;
      }
    }
    return null;
  }

  String _cityName(BuildContext context, City city) {
    return switch (Localizations.localeOf(context).languageCode) {
      'en' || 'tr' => city.nameEn,
      'ru' => city.nameRu,
      _ => city.nameLocal,
    };
  }

  String _prayerName(AppLocalizations l10n, String prayer) {
    return switch (prayer) {
      'imsak' => l10n.prayerImsak,
      'fajr' => l10n.prayerFajr,
      'sunrise' => l10n.prayerSunrise,
      'dhuhr' => l10n.prayerDhuhr,
      'asr' => l10n.prayerAsr,
      'maghrib' => l10n.prayerMaghrib,
      'isha' => l10n.prayerIsha,
      _ => prayer,
    };
  }

  String _languageName(Locale locale) {
    return switch (locale.languageCode) {
      'en' => 'English',
      'tr' => 'Türkçe',
      'ru' => 'Русский',
      'uz' => 'Oʻzbekcha',
      'kk' => 'Қазақша',
      'ky' => 'Кыргызча',
      'tg' => 'Тоҷикӣ',
      _ => locale.languageCode,
    };
  }

  Widget _dropdown<T>({
    required T value,
    required List<T> values,
    required String Function(T value) label,
    required ValueChanged<T?> onChanged,
  }) {
    return SizedBox(
      width: 190,
      child: DropdownButton<T>(
        value: value,
        isExpanded: true,
        items: [
          for (final item in values)
            DropdownMenuItem<T>(value: item, child: Text(label(item))),
        ],
        onChanged: onChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settings = context.watch<SettingsController>();
    final city = _selectedCity(settings.cityCode);
    final imsakOffset = _imsakOffsets.contains(settings.imsakOffsetMinutes)
        ? settings.imsakOffsetMinutes
        : 0;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        children: [
          ListTile(
            title: Text(l10n.languageSetting),
            trailing: _dropdown<Locale>(
              value: settings.locale,
              values: _supportedLocales,
              label: _languageName,
              onChanged: (locale) {
                if (locale != null) {
                  settings.setLocale(locale);
                }
              },
            ),
          ),
          ListTile(
            title: Text(l10n.locationSetting),
            subtitle: Text(
              city == null
                  ? l10n.locationUnknownLabel
                  : _cityName(context, city),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const CityPickerScreen()),
            ),
          ),
          ListTile(
            title: Text(l10n.calculationMethodSetting),
            trailing: _dropdown<CalculationMethod>(
              value: settings.calcMethod,
              values: CalculationMethod.values,
              label: (method) => method.name,
              onChanged: (method) {
                if (method != null) {
                  settings.setCalcMethod(method);
                }
              },
            ),
          ),
          ListTile(
            title: Text(l10n.madhabSetting),
            trailing: _dropdown<Madhab>(
              value: settings.madhab,
              values: Madhab.values,
              label: (madhab) => madhab.name,
              onChanged: (madhab) {
                if (madhab != null) {
                  settings.setMadhab(madhab);
                }
              },
            ),
          ),
          ListTile(
            title: Text(l10n.highLatitudeRuleSetting),
            trailing: _dropdown<HighLatitudeRule>(
              value: settings.highLatitudeRule,
              values: HighLatitudeRule.values,
              label: (rule) => rule.name,
              onChanged: (rule) {
                if (rule != null) {
                  settings.setHighLatitudeRule(rule);
                }
              },
            ),
          ),
          ListTile(
            title: Text(l10n.imsakOffsetSetting),
            trailing: _dropdown<int>(
              value: imsakOffset,
              values: _imsakOffsets,
              label: (minutes) => '$minutes min',
              onChanged: (minutes) {
                if (minutes != null) {
                  settings.setImsakOffset(minutes);
                }
              },
            ),
          ),
          ListTile(
            title: Text(l10n.hijriOffsetSetting),
            trailing: _dropdown<int>(
              value: settings.hijriOffsetDays,
              values: _hijriOffsets,
              label: (days) => days > 0 ? '+$days' : '$days',
              onChanged: (days) {
                if (days != null) {
                  settings.setHijriOffset(days);
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(
              l10n.notificationsSetting,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          for (final prayer in SettingsController.prayerNames)
            SwitchListTile(
              title: Text(_prayerName(l10n, prayer)),
              value: settings.notificationsEnabled[prayer] ?? false,
              onChanged: (enabled) {
                settings.setNotificationEnabled(prayer, enabled);
              },
            ),
          ListTile(
            title: Text(l10n.soundSetting),
            trailing: _dropdown<String>(
              value: settings.soundType,
              values: _soundTypes,
              label: (soundType) => soundType,
              onChanged: (soundType) {
                if (soundType != null) {
                  settings.setSoundType(soundType);
                }
              },
            ),
          ),
          if (_canScheduleExact == false)
            Card(
              color: Colors.orange.shade100,
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.exactAlarmWarningMessage),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _requestExactAlarmPermission,
                      child: Text(l10n.openSettingsButton),
                    ),
                  ],
                ),
              ),
            ),
          ListTile(
            title: Text(l10n.aboutSetting),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const AboutScreen()),
            ),
          ),
        ],
      ),
    );
  }
}
