import 'package:flutter_test/flutter_test.dart';
import 'package:hodiy/features/updater/version_compare.dart';

void main() {
  group('isNewerVersion', () {
    test('higher rc number is newer', () {
      expect(isNewerVersion(current: '1.0.0-rc3', latest: '1.0.0-rc4'), isTrue);
      expect(
        isNewerVersion(current: '1.0.0-rc9', latest: '1.0.0-rc10'),
        isTrue,
      );
    });

    test('same version is not newer', () {
      expect(
        isNewerVersion(current: '1.0.0-rc3', latest: '1.0.0-rc3'),
        isFalse,
      );
      expect(isNewerVersion(current: '1.0.0', latest: '1.0.0'), isFalse);
    });

    test('older rc is not newer', () {
      expect(
        isNewerVersion(current: '1.0.0-rc4', latest: '1.0.0-rc3'),
        isFalse,
      );
    });

    test('final release is newer than its release candidates', () {
      expect(isNewerVersion(current: '1.0.0-rc3', latest: '1.0.0'), isTrue);
      expect(isNewerVersion(current: '1.0.0', latest: '1.0.0-rc3'), isFalse);
    });

    test('base version comparison is numeric per segment', () {
      expect(isNewerVersion(current: '1.0.0', latest: '1.0.1'), isTrue);
      expect(isNewerVersion(current: '1.9.0', latest: '1.10.0'), isTrue);
      expect(isNewerVersion(current: '2.0.0', latest: '1.9.9'), isFalse);
      expect(isNewerVersion(current: '1.0.0-rc1', latest: '1.0.1-rc1'), isTrue);
    });

    test('unparseable versions never report an update', () {
      expect(isNewerVersion(current: '1.0.0', latest: 'nightly'), isFalse);
      expect(isNewerVersion(current: 'garbage', latest: '2.0.0'), isFalse);
      expect(isNewerVersion(current: '1.0', latest: '2.0'), isFalse);
    });
  });
}
