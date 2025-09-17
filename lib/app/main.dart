
import 'package:crew_app/app/app.dart';
import 'package:crew_app/core/state/settings_providers.dart';
import 'package:crew_app/features/profile/presentation/profile/profile_page.dart';
import 'package:crew_app/features/profile/user_events_page.dart';
import 'package:crew_app/features/profile/presentation/favorites/favorites_page.dart';
import 'package:crew_app/features/profile/presentation/history/history_page.dart';
import 'package:crew_app/features/profile/presentation/preferences/preferences_page.dart';
import 'package:crew_app/features/auth/presentation/login_page.dart';
import 'package:crew_app/features/settings/presentation/settings/settings_page.dart';
import 'package:crew_app/core/config/firebase_options.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 本地化存储
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return MaterialApp(
      title: 'Events Demo',
      locale: settings.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: settings.themeMode,
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