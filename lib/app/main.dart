import 'dart:ui';

import 'package:crew_app/app/app.dart';
import 'package:crew_app/features/profile/user_events_page.dart';
import 'package:crew_app/features/profile/presentation/favorites_page.dart';
import 'package:crew_app/features/profile/presentation/history_page.dart';
import 'package:crew_app/features/profile/presentation/preferences_page.dart';
import 'package:crew_app/features/profile/presentation/profile_page.dart';
import 'package:crew_app/core/network/auth/firebase_auth_service.dart';
import 'package:crew_app/features/auth/presentation/login_page.dart';
import 'package:crew_app/features/settings/presentation/settings/settings_page.dart';
import 'package:crew_app/core/config/firebase_options.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/network/api_service.dart';

late final FirebaseAuthService auth; // 全局或用 DI 框架注入

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  auth = FirebaseAuthService();

  // 本地化存储
  final prefs = await SharedPreferences.getInstance();

  // 获取持久化语言设置
  String? langCode = prefs.getString('language');
  Locale locale;
  if (langCode != null) {
    locale = Locale(langCode);
  } else {
    // 自动跟随系统语言
    locale = PlatformDispatcher.instance.locale;
  }
  // 获取持久化主题设置
  bool darkMode = prefs.getBool('darkMode') ?? false;
  runApp(ProviderScope(child: MyApp(locale: locale, darkMode: darkMode)));
}

class MyApp extends StatefulWidget {
  final Locale locale;
  final bool darkMode;

  const MyApp({required this.locale, required this.darkMode, super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Locale _locale;
  late bool _darkMode;
  final api = ApiService();

  @override
  void initState() {
    super.initState();
    _locale = widget.locale;
    _darkMode = widget.darkMode;
  }

  void updateLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', locale.languageCode);
    setState(() {
      _locale = locale;
    });
  }

  void updateDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', value);
    setState(() {
      _darkMode = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Events Demo",
      locale: _locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: _darkMode ? ThemeMode.dark : ThemeMode.light,
      routes: {
        '/': (context) => App(),
        '/login': (context) => LoginPage(),
        '/settings': (context) => SettingsPage(
              locale: _locale,
              darkMode: _darkMode,
              onLocaleChanged: updateLocale,
              onDarkModeChanged: updateDarkMode,
            ),
        '/preferences': (context) => PreferencesPage(),
        '/user_event': (context) => UserEventsPage(),
        '/profile': (context) => ProfilePage(),
        '/history': (context) => HistoryPage(),
        '/favorites': (context) => FavoritesPage(),
      },
    );
  }
}



// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   runApp(const ProviderScope(child: MyApp()));
// }

// class MyApp extends ConsumerWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final settingsAsync = ref.watch(settingsProvider);

//     return settingsAsync.when(
//       loading: () => const MaterialApp(home: Scaffold(body: Center(child: CircularProgressIndicator()))),
//       error: (e, _) => MaterialApp(home: Scaffold(body: Center(child: Text('Settings load failed')))),
//       data: (settings) {
//         final authAsync = ref.watch(authStateProvider);
//         return MaterialApp(
//           title: 'Crew',
//           locale: settings.locale,
//           supportedLocales: AppLocalizations.supportedLocales,
//           localizationsDelegates: AppLocalizations.localizationsDelegates,
//           theme: ThemeData.light(),
//           darkTheme: ThemeData.dark(),
//           themeMode: settings.themeMode,
//           routes: {
//             '/': (_) => authAsync.asData?.value != null ? const App() : const LoginPage(),
//             '/login': (_) => const LoginPage(),
//             '/settings': (_) => const SettingsPage(),
//             '/preferences': (_) => const PreferencesPage(),
//             '/user_event': (_) => const UserEventsPage(),
//             '/profile': (_) => const ProfilePage(),
//             '/history': (_) => const HistoryPage(),
//             '/favorites': (_) => const FavoritesPage(),
//           },
//         );
//       },
//     );
//   }
// }