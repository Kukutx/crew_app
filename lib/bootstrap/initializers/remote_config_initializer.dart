import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:talker_flutter/talker_flutter.dart';

import 'package:crew_app/core/config/remote_config_keys.dart';

class RemoteConfigInitializer {
  const RemoteConfigInitializer();

  Future<FirebaseRemoteConfig?> initialize(Talker talker) async {
    try {
      final remoteConfig = FirebaseRemoteConfig.instance;
      await remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(hours: 1),
      ));
      await remoteConfig.setDefaults(RemoteConfigDefaults.values);

      final activated = await remoteConfig.fetchAndActivate();
      talker.info('Remote Config fetchAndActivate: $activated');
      return remoteConfig;
    } on FirebaseException catch (error, stackTrace) {
      talker.handle(
        error,
        stackTrace,
        'remote_config.init.firebase_exception',
      );
    } on Object catch (error, stackTrace) {
      talker.handle(error, stackTrace, 'remote_config.init.exception');
    }
    return null;
  }
}
