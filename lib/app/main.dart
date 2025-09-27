
import 'dart:async';

import 'package:crew_app/app/app.dart';
import 'package:crew_app/core/config/firebase_options.dart';
import 'package:crew_app/core/monitoring/monitoring_providers.dart';
import 'package:crew_app/core/state/settings/settings_providers.dart';
import 'package:crew_app/features/auth/presentation/login_page.dart';
import 'package:crew_app/features/chat/user_event/prestantion/user_events_page.dart';
import 'package:crew_app/features/profile/presentation/favorites/favorites_page.dart';
import 'package:crew_app/features/profile/presentation/history/history_page.dart';
import 'package:crew_app/features/profile/presentation/preferences/preferences_page.dart';
import 'package:crew_app/features/profile/presentation/profile/profile_page.dart';
import 'package:crew_app/features/settings/presentation/settings/settings_page.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:feedback/feedback.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talker_flutter/talker_flutter.dart';

/// 早期版本
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );

//   final crashlytics = await _configureCrashlytics();
//   final talker = Talker();
//   final talkerRouteObserver = TalkerRouteObserver(talker);

//   if (crashlytics == null) {
//     talker.info('Crashlytics disabled for this platform.');
//   }

//   _setupErrorHandling(talker, crashlytics);

//   // 本地化存储
//   final prefs = await SharedPreferences.getInstance();

//   runZonedGuarded(() {
//     runApp(
//       ProviderScope(
//         overrides: [
//           sharedPreferencesProvider.overrideWithValue(prefs),
//           crashlyticsProvider.overrideWithValue(crashlytics),
//           talkerProvider.overrideWithValue(talker),
//           talkerRouteObserverProvider.overrideWithValue(talkerRouteObserver),
//         ],
//         child: BetterFeedback(
//           child: const MyApp(),
//         ),
//       ),
//     );
//   }, (error, stackTrace) {
//     _reportError(
//       talker,
//       crashlytics,
//       error,
//       stackTrace,
//       fatal: true,
//       reason: 'runZonedGuarded',
//     );
//   });
// }




Future<void> main() async {
  Talker? talker;
  FirebaseCrashlytics? crashlytics;

  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Firebase 初始化
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Crashlytics & Talker 初始化
    crashlytics = await _configureCrashlytics();
    talker = Talker();
    final talkerRouteObserver = TalkerRouteObserver(talker!);

    if (crashlytics == null) {
      talker?.info('Crashlytics disabled for this platform.');
    }

    // 错误捕获
    _setupErrorHandling(talker!, crashlytics);

    // SharedPreferences
    final prefs = await SharedPreferences.getInstance();

    // 启动应用
    runApp(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          crashlyticsProvider.overrideWithValue(crashlytics),
          talkerProvider.overrideWithValue(talker!),
          talkerRouteObserverProvider.overrideWithValue(talkerRouteObserver),
        ],
        child: BetterFeedback(
          child: const MyApp(),
        ),
      ),
    );
  }, (error, stackTrace) {
    // 全局未捕获异常
    talker?.handle(error, stackTrace, 'unhandled zone error');
    crashlytics?.recordError(
      error,
      stackTrace,
      fatal: true,
      reason: 'runZonedGuarded',
    );
  });
}


Future<FirebaseCrashlytics?> _configureCrashlytics() async {
  if (kIsWeb) {
    debugPrint('Crashlytics is not supported on web.');
    return null;
  }

  final crashlytics = FirebaseCrashlytics.instance;
  // await crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);  // 非调试模式下启用,正式版本使用
  await crashlytics.setCrashlyticsCollectionEnabled(true);    // 强制开启，测试用,如果release版请注释掉
  if (kDebugMode) {
    debugPrint('Crashlytics collection disabled in debug mode.');
  }
  return crashlytics;
}

void _setupErrorHandling(Talker talker, FirebaseCrashlytics? crashlytics) {
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    _reportError(
      talker,
      crashlytics,
      details.exception,
      details.stack,
      fatal: false,   // 通常标记 fatal: false；真正未捕获的原生/平台异常在 platformDispatcher.onError 里用 fatal: true。
      reason: details.context?.toDescription(),
    );
  };

  WidgetsBinding.instance.platformDispatcher.onError = (error, stackTrace) {
    _reportError(
      talker,
      crashlytics,
      error,
      stackTrace,
      fatal: true,
      reason: 'platformDispatcher',
    );
    return true;
  };
}

void _reportError(
  Talker talker,
  FirebaseCrashlytics? crashlytics,
  dynamic error,
  StackTrace? stackTrace, {
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

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final routeObserver = ref.watch(talkerRouteObserverProvider);
    return MaterialApp(
      title: 'Events Demo',
      locale: settings.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: settings.themeMode,
      navigatorObservers: [routeObserver],
      routes: {
        '/': (context) => const App(),
        '/login': (context) => const LoginPage(),
        '/settings': (context) => const SettingsPage(),
        '/preferences': (context) => PreferencesPage(),
        '/user_event': (context) => UserEventsPage(),
        '/profile': (context) => ProfilePage(),
        '/history': (context) => HistoryPage(),
        '/favorites': (context) => FavoritesPage(),
      },
    );
  }
}