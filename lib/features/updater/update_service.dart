import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:hodiy/features/updater/version_compare.dart';

/// Self-updating is only for sideloaded test builds. Google Play forbids apps
/// that install APKs, so Play builds must be produced with
/// `--dart-define=UPDATER_ENABLED=false`.
const updaterEnabled = bool.fromEnvironment(
  'UPDATER_ENABLED',
  defaultValue: true,
);

class UpdateInfo {
  UpdateInfo({required this.version, required this.apkUrl});

  final String version;
  final String apkUrl;
}

class UpdateService {
  static const _channel = MethodChannel('com.msela.hodiy/updater');
  static const _latestReleaseUrl =
      'https://api.github.com/repos/samedtorlak/hodiy/releases/latest';
  static const _apkAssetName = 'app-release.apk';

  /// Returns the newer release, or null when up to date or on any failure.
  /// The check must never break app startup, so all errors map to null.
  Future<UpdateInfo?> checkForUpdate() async {
    try {
      final currentVersion = await _channel.invokeMethod<String>(
        'getVersionName',
      );
      if (currentVersion == null) {
        return null;
      }

      final client = HttpClient();
      try {
        final request = await client.getUrl(Uri.parse(_latestReleaseUrl));
        request.headers.set(HttpHeaders.userAgentHeader, 'hodiy-app');
        request.headers.set(
          HttpHeaders.acceptHeader,
          'application/vnd.github+json',
        );
        final response = await request.close();
        if (response.statusCode != HttpStatus.ok) {
          return null;
        }
        final body = await response.transform(utf8.decoder).join();
        final release = jsonDecode(body) as Map<String, dynamic>;
        final tag = release['tag_name'] as String?;
        if (tag == null) {
          return null;
        }
        final latestVersion = tag.startsWith('v') ? tag.substring(1) : tag;
        if (!isNewerVersion(current: currentVersion, latest: latestVersion)) {
          return null;
        }

        final assets = release['assets'] as List<dynamic>? ?? const [];
        for (final asset in assets) {
          final map = asset as Map<String, dynamic>;
          if (map['name'] == _apkAssetName) {
            final url = map['browser_download_url'] as String?;
            if (url != null) {
              return UpdateInfo(version: latestVersion, apkUrl: url);
            }
          }
        }
        return null;
      } finally {
        client.close();
      }
    } catch (_) {
      return null;
    }
  }

  /// Downloads the APK into the app's private files directory.
  /// [onProgress] receives a value in 0..1, or null when the total size is
  /// unknown.
  Future<File> downloadApk(
    UpdateInfo info, {
    void Function(double? progress)? onProgress,
  }) async {
    final filesDirPath = await _channel.invokeMethod<String>('getFilesDirPath');
    if (filesDirPath == null) {
      throw StateError('Files directory unavailable');
    }
    final updatesDir = Directory('$filesDirPath/updates');
    await updatesDir.create(recursive: true);
    final apkFile = File('${updatesDir.path}/$_apkAssetName');

    final client = HttpClient();
    try {
      final request = await client.getUrl(Uri.parse(info.apkUrl));
      request.headers.set(HttpHeaders.userAgentHeader, 'hodiy-app');
      final response = await request.close();
      if (response.statusCode != HttpStatus.ok) {
        throw HttpException('Download failed: HTTP ${response.statusCode}');
      }

      final totalBytes = response.contentLength;
      var receivedBytes = 0;
      final sink = apkFile.openWrite();
      try {
        await for (final chunk in response) {
          sink.add(chunk);
          receivedBytes += chunk.length;
          if (onProgress != null) {
            onProgress(totalBytes > 0 ? receivedBytes / totalBytes : null);
          }
        }
        await sink.flush();
      } finally {
        await sink.close();
      }
      return apkFile;
    } finally {
      client.close();
    }
  }

  /// Hands the APK to the Android package installer. The system UI takes over
  /// from here (including the one-time "allow this source" prompt).
  Future<void> installApk(File apkFile) {
    return _channel.invokeMethod('installApk', {'path': apkFile.path});
  }
}
