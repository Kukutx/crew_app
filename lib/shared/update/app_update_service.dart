import 'dart:async';
import 'dart:math';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'app_update_status.dart';

class AppUpdateService {
  AppUpdateService({FirebaseRemoteConfig? remoteConfig})
      : _remoteConfig = remoteConfig ?? FirebaseRemoteConfig.instance;

  final FirebaseRemoteConfig _remoteConfig;

  Future<AppUpdateStatus> checkForUpdate({bool forceRefresh = false}) async {
    final packageInfo = await PackageInfo.fromPlatform();

    try {
      await _remoteConfig.ensureInitialized();
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval:
            forceRefresh ? Duration.zero : const Duration(hours: 1),
      ));

      await _remoteConfig.setDefaults(const <String, dynamic>{
        'latest_version': '',
        'force_update': false,
        'update_url': '',
        'update_message': '',
      });

      if (forceRefresh) {
        await _remoteConfig.fetch();
        await _remoteConfig.activate();
      } else {
        await _remoteConfig.fetchAndActivate();
      }

      final latestVersion = _remoteConfig.getString('latest_version').trim();
      final forceUpdate = _remoteConfig.getBool('force_update');
      final updateUrl = _remoteConfig.getString('update_url').trim();
      final message = _remoteConfig.getString('update_message').trim();

      final sanitizedLatestVersion =
          latestVersion.isNotEmpty ? latestVersion : packageInfo.version;
      final hasUrl = updateUrl.isNotEmpty;
      final updateAvailable = _isVersionGreater(
        sanitizedLatestVersion,
        packageInfo.version,
      );

      return AppUpdateStatus(
        currentVersion: packageInfo.version,
        latestVersion: sanitizedLatestVersion,
        updateAvailable: updateAvailable,
        forceUpdate: updateAvailable && forceUpdate && hasUrl,
        updateUrl: hasUrl ? updateUrl : null,
        message: message.isNotEmpty ? message : null,
      );
    } catch (error, stackTrace) {
      debugPrint('Failed to fetch update info: $error\n$stackTrace');
      return AppUpdateStatus(
        currentVersion: packageInfo.version,
        latestVersion: packageInfo.version,
        updateAvailable: false,
        forceUpdate: false,
        updateUrl: null,
        message: null,
        errorDescription: error is Exception ? error.toString() : '$error',
      );
    }
  }

  bool _isVersionGreater(String latest, String current) {
    final latestParts = _parseVersion(latest);
    final currentParts = _parseVersion(current);
    final length = max(latestParts.length, currentParts.length);
    for (var i = 0; i < length; i++) {
      final latestPart = i < latestParts.length ? latestParts[i] : 0;
      final currentPart = i < currentParts.length ? currentParts[i] : 0;
      if (latestPart > currentPart) {
        return true;
      }
      if (latestPart < currentPart) {
        return false;
      }
    }
    return false;
  }

  List<int> _parseVersion(String version) {
    final sanitized = version.split('+').first;
    return sanitized
        .split('.')
        .map((part) => int.tryParse(part) ?? 0)
        .toList();
  }
}
