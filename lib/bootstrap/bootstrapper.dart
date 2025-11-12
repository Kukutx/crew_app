import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talker_flutter/talker_flutter.dart';

import 'package:crew_app/bootstrap/bootstrap_result.dart';
import 'package:crew_app/bootstrap/error/error_handler.dart';
import 'package:crew_app/bootstrap/initializers/firebase_initializer.dart';
import 'package:crew_app/bootstrap/initializers/monitoring_initializer.dart';
import 'package:crew_app/bootstrap/initializers/preferences_initializer.dart';
import 'package:crew_app/bootstrap/initializers/remote_config_initializer.dart';
import 'package:crew_app/core/config/remote_config_providers.dart';
import 'package:crew_app/core/monitoring/monitoring_providers.dart';
import 'package:crew_app/core/storage/shared_preferences_providers.dart';

class Bootstrapper {
  Bootstrapper({
    FirebaseInitializer? firebaseInitializer,
    MonitoringInitializer? monitoringInitializer,
    RemoteConfigInitializer? remoteConfigInitializer,
    PreferencesInitializer? preferencesInitializer,
    ErrorHandler? errorHandler,
  })  : _firebaseInitializer = firebaseInitializer ?? const FirebaseInitializer(),
        _monitoringInitializer = monitoringInitializer ?? const MonitoringInitializer(),
        _remoteConfigInitializer = remoteConfigInitializer ?? const RemoteConfigInitializer(),
        _preferencesInitializer = preferencesInitializer ?? const PreferencesInitializer(),
        _errorHandler = errorHandler ?? const ErrorHandler();

  final FirebaseInitializer _firebaseInitializer;
  final MonitoringInitializer _monitoringInitializer;
  final RemoteConfigInitializer _remoteConfigInitializer;
  final PreferencesInitializer _preferencesInitializer;
  final ErrorHandler _errorHandler;

  Future<void> run(Widget Function(BootstrapResult result) builder) async {
    Talker? talker;
    FirebaseCrashlytics? crashlytics;

    await runZonedGuarded(() async {
      WidgetsFlutterBinding.ensureInitialized();

      // 并行初始化 Firebase 和 Preferences（它们互不依赖）
      final results = await Future.wait([
        _firebaseInitializer.initialize(),
        _preferencesInitializer.initialize(),
      ]);
      final preferences = results[1] as SharedPreferences;

      // Monitoring 依赖 Firebase，RemoteConfig 依赖 Monitoring
      final monitoring = await _monitoringInitializer.initialize();
      talker = monitoring.talker;
      crashlytics = monitoring.crashlytics;

      // 并行初始化 RemoteConfig 和 ErrorHandler（它们都依赖 Monitoring）
      final remoteConfigFuture = _remoteConfigInitializer.initialize(monitoring.talker);
      _errorHandler.initialize(
        talker: monitoring.talker,
        crashlytics: monitoring.crashlytics,
      );
      final remoteConfig = await remoteConfigFuture;

      final overrides = <Override>[
        sharedPreferencesProvider.overrideWithValue(preferences),
        crashlyticsProvider.overrideWithValue(crashlytics),
        talkerProvider.overrideWithValue(monitoring.talker),
        talkerRouteObserverProvider.overrideWithValue(monitoring.routeObserver),
        remoteConfigProvider.overrideWithValue(remoteConfig),
      ];

      final result = BootstrapResult(
        overrides: overrides,
        talker: monitoring.talker,
        routeObserver: monitoring.routeObserver,
        sharedPreferences: preferences,
        crashlytics: crashlytics,
        remoteConfig: remoteConfig,
      );

      final app = builder(result);
      runApp(app);
    }, (error, stackTrace) {
      _errorHandler.handleZoneError(
        talker: talker,
        crashlytics: crashlytics,
        error: error,
        stackTrace: stackTrace,
      );
    });
  }
}
