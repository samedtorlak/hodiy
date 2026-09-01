import 'package:flutter_test/flutter_test.dart';
import 'package:hodiy/core/location/cities.dart';
import 'package:hodiy/core/location/nearest_city.dart';

void main() {
  test('finds Toshkent near its city center', () {
    final city = nearestCity(41.30, 69.25, centralAsianCities);

    expect(city.code, 'TAS');
  });

  test('finds Almaty near its city center', () {
    final city = nearestCity(43.24, 76.91, centralAsianCities);

    expect(city.code, 'ALA');
  });
}
