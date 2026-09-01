import 'dart:math' as math;

import 'cities.dart';

City nearestCity(double lat, double lon, List<City> cities) {
  var nearest = cities.first;
  var shortestDistance = _haversineKm(lat, lon, nearest.lat, nearest.lon);

  for (final city in cities.skip(1)) {
    final distance = _haversineKm(lat, lon, city.lat, city.lon);
    if (distance < shortestDistance) {
      nearest = city;
      shortestDistance = distance;
    }
  }

  return nearest;
}

double _haversineKm(double lat1, double lon1, double lat2, double lon2) {
  const earthRadiusKm = 6371.0;
  final lat1Radians = _toRadians(lat1);
  final lat2Radians = _toRadians(lat2);
  final latDelta = _toRadians(lat2 - lat1);
  final lonDelta = _toRadians(lon2 - lon1);

  final sinHalfLatDelta = math.sin(latDelta / 2);
  final sinHalfLonDelta = math.sin(lonDelta / 2);
  final a =
      sinHalfLatDelta * sinHalfLatDelta +
      math.cos(lat1Radians) *
          math.cos(lat2Radians) *
          sinHalfLonDelta *
          sinHalfLonDelta;
  final centralAngle = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

  return earthRadiusKm * centralAngle;
}

double _toRadians(double degrees) => degrees * math.pi / 180;
