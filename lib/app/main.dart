import 'dart:ui';

import 'package:crew_app/app/app.dart';
import 'package:crew_app/features/events/presentation/user_events_page.dart';
import 'package:crew_app/features/profile/presentation/favorites_page.dart';
import 'package:crew_app/features/profile/presentation/history_page.dart';
import 'package:crew_app/features/profile/presentation/preferences_page.dart';
import 'package:crew_app/features/profile/presentation/profile_page.dart';
import 'package:crew_app/playground/deprecated/test_home_page.dart';
import 'package:crew_app/core/network/auth/firebase_auth_service.dart';
import 'package:crew_app/features/events/presentation/events_list_page.dart';
import 'package:crew_app/features/events/presentation/map/events_map_page.dart';
import 'package:crew_app/features/auth/presentation/login_page.dart';
import 'package:crew_app/features/settings/presentation/settings_page.dart';
import 'package:crew_app/playground/test_evente_detail_page.dart';
import 'package:crew_app/playground/test_home_page.dart';
import 'package:crew_app/playground/test_profile_page.dart';
import 'package:crew_app/playground/test_staggered_grid.dart';
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

  // runApp(MyApp(locale: locale, darkMode: darkMode));  // 无flutter_riverpod访问地图
  // runApp(TuotuoApp());
  // runApp(TuotuoApp2());
  // runApp(TuotuoApp3());
  // runApp(TestStaggeredGrid());

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
      // initialRoute: FirebaseAuthService().currentUser == null ? '/' : kHomeRoute,    // 测试登录
      routes: {
        // kHomeRoute: (_) => const TestHomePage(), // TODO: 替换为你的首页
        // '/': (context) => const LoginPage(),
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
