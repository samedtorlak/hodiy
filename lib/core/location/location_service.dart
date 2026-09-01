import 'dart:async';

import 'package:geolocator/geolocator.dart';

sealed class LocationResult {}

class LocationGranted extends LocationResult {
  LocationGranted({required this.lat, required this.lon});

  final double lat;
  final double lon;
}

class LocationDenied extends LocationResult {}

class LocationDeniedForever extends LocationResult {}

class LocationServiceOff extends LocationResult {}

class LocationTimeout extends LocationResult {}

class LocationService {
  Future<LocationResult> getOnce() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return LocationServiceOff();
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      return LocationDenied();
    }
    if (permission == LocationPermission.deniedForever) {
      return LocationDeniedForever();
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
        ),
      ).timeout(const Duration(seconds: 15));

      return LocationGranted(lat: position.latitude, lon: position.longitude);
    } on TimeoutException {
      final position = await Geolocator.getLastKnownPosition();
      if (position == null) {
        return LocationTimeout();
      }

      return LocationGranted(lat: position.latitude, lon: position.longitude);
    }
  }
}
