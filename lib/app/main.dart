import 'package:crew_app/core/config/firebase_options.dart';
import 'package:crew_app/core/state/settings_providers.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);
    final router = ref.watch(routerProvider);

    return settingsAsync.when(
      loading: () =>
          const MaterialApp(home: Scaffold(body: Center(child: CircularProgressIndicator()))),
      error: (e, _) =>
          MaterialApp(home: Scaffold(body: Center(child: Text('Settings load failed')))),
      data: (settings) {
        return MaterialApp.router(
          title: 'Crew',
          routerConfig: router,
          locale: settings.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: settings.themeMode,
        );
      },
    );
  }
}
