import 'package:flutter_test/flutter_test.dart';
import 'package:hodiy/features/qibla/domain/qibla_bearing.dart';

void main() {
  group('qiblaBearing', () {
    test('returns a west-southwest bearing for Tashkent', () {
      final bearing = qiblaBearing(41.2995, 69.2401);

      expect(bearing, inInclusiveRange(235, 250));
    });

    test('returns a west-southwest bearing for Almaty', () {
      final bearing = qiblaBearing(43.2220, 76.8512);

      expect(bearing, inInclusiveRange(245, 255));
    });
  });
}
