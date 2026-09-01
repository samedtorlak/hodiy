import 'package:flutter/material.dart';
import 'package:hodiy/core/localization/generated/app_localizations.dart';
import 'package:hodiy/core/location/cities.dart';
import 'package:hodiy/features/hijri/domain/hijri_service.dart';
import 'package:hodiy/features/prayer_times/domain/prayer_calculator.dart';
import 'package:hodiy/features/prayer_times/state/prayer_controller.dart';
import 'package:hodiy/features/prayer_times/ui/city_picker_screen.dart';
import 'package:hodiy/features/settings/state/settings_controller.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final PrayerController _prayerController;
  bool _showingTomorrow = false;
  bool _initialLocationChecked = false;

  @override
  void initState() {
    super.initState();
    _prayerController = context.read<PrayerController>();
    _prayerController.startTicking();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _initialLocationChecked) {
        return;
      }
      _initialLocationChecked = true;
      final settings = context.read<SettingsController>();
      if (settings.lat == null || settings.lon == null) {
        _openCityPicker();
      }
    });
  }

  @override
  void dispose() {
    _prayerController.stopTicking();
    super.dispose();
  }

  void _openCityPicker() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const CityPickerScreen()));
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
      'en' => city.nameEn,
      'ru' => city.nameRu,
      _ => city.nameLocal,
    };
  }

  String _hijriMonth(AppLocalizations l10n, int month) {
    return switch (month) {
      1 => l10n.hijriMonth1,
      2 => l10n.hijriMonth2,
      3 => l10n.hijriMonth3,
      4 => l10n.hijriMonth4,
      5 => l10n.hijriMonth5,
      6 => l10n.hijriMonth6,
      7 => l10n.hijriMonth7,
      8 => l10n.hijriMonth8,
      9 => l10n.hijriMonth9,
      10 => l10n.hijriMonth10,
      11 => l10n.hijriMonth11,
      12 => l10n.hijriMonth12,
      _ => '',
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

  String _formatCountdown(Duration? duration) {
    final remaining = duration == null || duration.isNegative
        ? Duration.zero
        : duration;
    final hours = remaining.inHours.toString().padLeft(2, '0');
    final minutes = (remaining.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (remaining.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  List<MapEntry<String, DateTime>> _prayerTimes(DayTimes day) {
    return [
      MapEntry('imsak', day.imsak),
      MapEntry('fajr', day.fajr),
      MapEntry('sunrise', day.sunrise),
      MapEntry('dhuhr', day.dhuhr),
      MapEntry('asr', day.asr),
      MapEntry('maghrib', day.maghrib),
      MapEntry('isha', day.isha),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settings = context.watch<SettingsController>();
    final hijriDate = HijriService().today(
      offsetDays: settings.hijriOffsetDays,
    );
    final city = _selectedCity(settings.cityCode);

    return Consumer<PrayerController>(
      builder: (context, prayerController, _) {
        final day = _showingTomorrow
            ? prayerController.tomorrow
            : prayerController.today;
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          l10n.hijriDateLabel,
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${hijriDate.hDay} '
                          '${_hijriMonth(l10n, hijriDate.hMonth)} '
                          '${hijriDate.hYear}',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.location_on_outlined),
                    title: Text(
                      city == null
                          ? l10n.locationUnknownLabel
                          : _cityName(context, city),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _openCityPicker,
                  ),
                ),
                if (prayerController.next != null)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(l10n.nextPrayerLabel),
                          const SizedBox(height: 4),
                          Text(
                            _prayerName(l10n, prayerController.next!.key),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatCountdown(prayerController.countdown),
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: _showingTomorrow
                          ? () => setState(() => _showingTomorrow = false)
                          : null,
                      icon: const Icon(Icons.chevron_left),
                    ),
                    Text(
                      _showingTomorrow ? l10n.tomorrowLabel : l10n.todayLabel,
                    ),
                    IconButton(
                      onPressed:
                          !_showingTomorrow && prayerController.tomorrow != null
                          ? () => setState(() => _showingTomorrow = true)
                          : null,
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
                if (day == null) ...[
                  const SizedBox(height: 24),
                  Text(l10n.locationUnknownLabel, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _openCityPicker,
                    child: Text(l10n.cityPickerTitle),
                  ),
                ] else
                  for (final prayer in _prayerTimes(day))
                    Card(
                      child: ListTile(
                        title: Text(_prayerName(l10n, prayer.key)),
                        trailing: Text(
                          DateFormat('HH:mm').format(prayer.value.toLocal()),
                        ),
                      ),
                    ),
              ],
            ),
          ),
        );
      },
    );
  }
}
