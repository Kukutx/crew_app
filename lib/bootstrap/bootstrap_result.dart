import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talker_flutter/talker_flutter.dart';

class BootstrapResult {
  const BootstrapResult({
    required this.overrides,
    required this.talker,
    required this.routeObserver,
    required this.sharedPreferences,
    this.crashlytics,
    this.remoteConfig,
  });

  final List<Override> overrides;
  final Talker talker;
  final TalkerRouteObserver routeObserver;
  final SharedPreferences sharedPreferences;
  final FirebaseCrashlytics? crashlytics;
  final FirebaseRemoteConfig? remoteConfig;
}
