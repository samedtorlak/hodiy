import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hodiy/core/localization/generated/app_localizations.dart';
import 'package:hodiy/core/location/cities.dart';
import 'package:hodiy/core/location/location_service.dart';
import 'package:hodiy/core/location/nearest_city.dart';
import 'package:hodiy/features/settings/state/settings_controller.dart';
import 'package:provider/provider.dart';

class CityPickerScreen extends StatefulWidget {
  const CityPickerScreen({super.key});

  @override
  State<CityPickerScreen> createState() => _CityPickerScreenState();
}

class _CityPickerScreenState extends State<CityPickerScreen> {
  static const _countryCodes = ['UZ', 'KZ', 'KG', 'TJ', 'TM'];

  String _query = '';
  bool _isLocating = false;

  Future<void> _useCurrentLocation() async {
    setState(() => _isLocating = true);
    try {
      final result = await LocationService().getOnce();
      if (!mounted) {
        return;
      }

      switch (result) {
        case LocationGranted(:final lat, :final lon):
          final city = nearestCity(lat, lon, centralAsianCities);
          await context.read<SettingsController>().setLocation(
            lat: lat,
            lon: lon,
            source: 'gps',
            cityCode: city.code,
          );
          if (mounted) {
            Navigator.of(context).pop();
          }
        case LocationDenied():
          _showMessage(
            AppLocalizations.of(context).locationPermissionDeniedMessage,
          );
        case LocationDeniedForever():
          await _showSettingsDialog(
            message: AppLocalizations.of(context)
                .locationPermissionDeniedMessage,
            openSettings: Geolocator.openAppSettings,
          );
        case LocationServiceOff():
          await _showSettingsDialog(
            message: AppLocalizations.of(context).locationServiceOffMessage,
            openSettings: Geolocator.openLocationSettings,
          );
        case LocationTimeout():
          _showMessage(AppLocalizations.of(context).errorGenericMessage);
      }
    } catch (_) {
      if (mounted) {
        _showMessage(AppLocalizations.of(context).errorGenericMessage);
      }
    } finally {
      if (mounted) {
        setState(() => _isLocating = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _showSettingsDialog({
    required String message,
    required Future<bool> Function() openSettings,
  }) async {
    final l10n = AppLocalizations.of(context);
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () async {
              await openSettings();
              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop();
              }
            },
            child: Text(l10n.openSettingsButton),
          ),
        ],
      ),
    );
  }

  Future<void> _chooseCity(City city) async {
    await context.read<SettingsController>().setLocation(
      lat: city.lat,
      lon: city.lon,
      source: 'manual',
      cityCode: city.code,
    );
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  String _cityName(City city) {
    return switch (Localizations.localeOf(context).languageCode) {
      'en' => city.nameEn,
      'ru' => city.nameRu,
      _ => city.nameLocal,
    };
  }

  List<City> get _filteredCities {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) {
      return centralAsianCities;
    }
    return centralAsianCities.where((city) {
      return city.nameEn.toLowerCase().contains(query) ||
          city.nameLocal.toLowerCase().contains(query) ||
          city.nameRu.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final filteredCities = _filteredCities;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.cityPickerTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _isLocating ? null : _useCurrentLocation,
                icon: _isLocating
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.my_location),
                label: Text(l10n.useMyLocationButton),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: l10n.searchCityHint,
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                for (final countryCode in _countryCodes)
                  if (filteredCities.any(
                    (city) => city.countryCode == countryCode,
                  )) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                      child: Text(
                        countryCode,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                    for (final city in filteredCities.where(
                      (city) => city.countryCode == countryCode,
                    ))
                      ListTile(
                        title: Text(_cityName(city)),
                        onTap: () => _chooseCity(city),
                      ),
                  ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
