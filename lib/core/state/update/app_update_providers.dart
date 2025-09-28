import 'dart:convert';

import 'package:crew_app/core/config/remote_config_keys.dart';
import 'package:crew_app/core/config/remote_config_providers.dart';
import 'package:crew_app/core/monitoring/monitoring_providers.dart';
import 'package:crew_app/shared/update/app_update_info.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppUpdateState {
  AppUpdateState({
    required this.info,
    required this.currentVersion,
  });

  final AppUpdateInfo info;
  final String currentVersion;

  bool get requiresForceUpdate => info.requiresForceUpdate(currentVersion);
  bool get hasOptionalUpdate => info.requiresUpdate(currentVersion);
}

final packageInfoProvider = FutureProvider<PackageInfo>((ref) async {
  return PackageInfo.fromPlatform();
});

final appUpdateStateProvider = FutureProvider<AppUpdateState?>((ref) async {
  final remoteConfig = ref.watch(remoteConfigProvider);
  if (remoteConfig == null) {
    return null;
  }

  final talker = ref.watch(talkerProvider);

  try {
    await remoteConfig.fetchAndActivate();
  } catch (error, stackTrace) {
    talker.handle(error, stackTrace, 'remote_config.app_update.fetch');
  }

  final raw = remoteConfig.getString(RemoteConfigKeys.appUpdateInfo);
  final trimmed = raw.trim();
  if (trimmed.isEmpty || trimmed == '{}') {
    return null;
  }

  try {
    final map = json.decode(trimmed) as Map<String, dynamic>;
    final info = AppUpdateInfo.fromJson(map);
    if (info.latestVersion.isEmpty && info.minSupportedVersion.isEmpty) {
      return null;
    }
    final packageInfo = await ref.watch(packageInfoProvider.future);
    return AppUpdateState(
      info: info,
      currentVersion: packageInfo.version,
    );
  } catch (error, stackTrace) {
    talker.handle(error, stackTrace, 'remote_config.app_update.parse');
    return null;
  }
});
