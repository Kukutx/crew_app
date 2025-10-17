import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/widgets.dart';
import 'package:talker_flutter/talker_flutter.dart';

class ErrorHandler {
  const ErrorHandler();

  void initialize({
    required Talker talker,
    FirebaseCrashlytics? crashlytics,
  }) {
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      reportError(
        talker: talker,
        crashlytics: crashlytics,
        error: details.exception,
        stackTrace: details.stack,
        fatal: false,
        reason: details.context?.toDescription(),
      );
    };

    WidgetsBinding.instance.platformDispatcher.onError = (error, stackTrace) {
      reportError(
        talker: talker,
        crashlytics: crashlytics,
        error: error,
        stackTrace: stackTrace,
        fatal: true,
        reason: 'platformDispatcher',
      );
      return true;
    };
  }

  void handleZoneError({
    Talker? talker,
    FirebaseCrashlytics? crashlytics,
    required Object error,
    required StackTrace stackTrace,
  }) {
    if (talker == null) {
      debugPrint('Unhandled zone error: $error');
      debugPrint('$stackTrace');
      return;
    }

    reportError(
      talker: talker,
      crashlytics: crashlytics,
      error: error,
      stackTrace: stackTrace,
      fatal: true,
      reason: 'runZonedGuarded',
    );
  }

  void reportError({
    required Talker talker,
    FirebaseCrashlytics? crashlytics,
    required Object error,
    StackTrace? stackTrace,
    bool fatal = false,
    String? reason,
  }) {
    talker.handle(error, stackTrace, reason);
    crashlytics?.recordError(
      error,
      stackTrace ?? StackTrace.current,
      fatal: fatal,
      reason: reason,
    );
  }
}
