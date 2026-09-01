import 'package:flutter_test/flutter_test.dart';
import 'package:hodiy/core/ads/ads_config.dart';

void main() {
  group('AdsConfig', () {
    test('disables ads by default', () {
      expect(AdsConfig.enabled, isFalse);
    });

    test('uses Google test banner ID by default', () {
      expect(
        AdsConfig.bannerAdUnitId,
        'ca-app-pub-3940256099942544/6300978111',
      );
    });
  });
}
