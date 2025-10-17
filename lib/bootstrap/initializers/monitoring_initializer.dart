import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:talker_flutter/talker_flutter.dart';

class MonitoringInitializationResult {
  MonitoringInitializationResult({
    required this.talker,
    required this.routeObserver,
    this.crashlytics,
  });

  final Talker talker;
  final TalkerRouteObserver routeObserver;
  final FirebaseCrashlytics? crashlytics;
}

class MonitoringInitializer {
  const MonitoringInitializer();

  Future<MonitoringInitializationResult> initialize() async {
    final talker = Talker();
    final routeObserver = TalkerRouteObserver(talker);
    FirebaseCrashlytics? crashlytics;

    if (kIsWeb) {
      talker.info('Crashlytics is not supported on web.');
    } else {
      crashlytics = FirebaseCrashlytics.instance;
      await crashlytics.setCrashlyticsCollectionEnabled(true);
      if (kDebugMode) {
        debugPrint('Crashlytics collection forced enabled in debug mode.');
      }
    }

    return MonitoringInitializationResult(
      talker: talker,
      routeObserver: routeObserver,
      crashlytics: crashlytics,
    );
  }
}
