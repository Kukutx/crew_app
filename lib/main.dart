import 'dart:ui';

import 'package:crew_app/Pages/events_list_page.dart';
import 'package:crew_app/Pages/login_page.dart';
import 'package:crew_app/Pages/settings_page.dart';
import 'package:crew_app/Test%20Pages/test_evente_detail_page.dart';
import 'package:crew_app/Test%20Pages/test_home_page.dart';
import 'package:crew_app/Test%20Pages/test_profile_page.dart';
import 'package:crew_app/firebase_options.dart';
import 'package:crew_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './Services/api_service.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
     options: DefaultFirebaseOptions.currentPlatform,
  ); 

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

  // runApp(MyApp(locale: locale, darkMode: darkMode));
  // runApp(TuotuoApp());
  // runApp(TuotuoApp2());
  runApp(TuotuoApp3());
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
        '/': (context) => EventsListPage(api: api),
        '/login': (context) => LoginPage (), 
        '/settings': (context) => SettingsPage(
        locale: _locale,
        darkMode: _darkMode,
        onLocaleChanged: updateLocale,
        onDarkModeChanged: updateDarkMode,
      ), 
      },
    );
  }
}

