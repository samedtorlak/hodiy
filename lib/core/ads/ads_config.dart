class AdsConfig {
  static const bool enabled = bool.fromEnvironment(
    'ADS_ENABLED',
    defaultValue: false,
  );

  // Google's public test banner ad unit ID (safe to ship, always returns test ads).
  static const String _testBannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111';

  static String get bannerAdUnitId {
    const fromEnv = String.fromEnvironment('ADMOB_BANNER_ID');
    return fromEnv.isEmpty ? _testBannerAdUnitId : fromEnv;
  }
}
