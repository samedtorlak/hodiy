import 'package:flutter_test/flutter_test.dart';
import 'package:hodiy/core/location/cities.dart';

void main() {
  test('city codes are unique', () {
    final codes = centralAsianCities.map((city) => city.code).toSet();

    expect(codes, hasLength(centralAsianCities.length));
  });

  test('city coordinates stay within the Central Asian bounds', () {
    for (final city in centralAsianCities) {
      expect(city.lat, inInclusiveRange(35, 56), reason: city.code);
      expect(city.lon, inInclusiveRange(50, 88), reason: city.code);
    }
  });

  test('each supported country has at least six cities', () {
    for (final countryCode in const ['UZ', 'KZ', 'KG', 'TJ', 'TM']) {
      final cityCount = centralAsianCities
          .where((city) => city.countryCode == countryCode)
          .length;

      expect(cityCount, greaterThanOrEqualTo(6), reason: countryCode);
    }
  });

  test('the catalog contains 56 cities', () {
    expect(centralAsianCities, hasLength(56));
  });
}
