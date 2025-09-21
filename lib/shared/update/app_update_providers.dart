import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_update_service.dart';
import 'app_update_status.dart';

final firebaseRemoteConfigProvider = Provider<FirebaseRemoteConfig>((ref) {
  return FirebaseRemoteConfig.instance;
});

final appUpdateServiceProvider = Provider<AppUpdateService>((ref) {
  return AppUpdateService(remoteConfig: ref.watch(firebaseRemoteConfigProvider));
});

final appUpdateStatusProvider = FutureProvider<AppUpdateStatus>((ref) {
  final service = ref.watch(appUpdateServiceProvider);
  return service.checkForUpdate();
});
