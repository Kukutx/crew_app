import 'package:crew_app/app/app.dart';
import 'package:crew_app/core/monitoring/monitoring_providers.dart';
import 'package:crew_app/features/auth/presentation/login_page.dart';
import 'package:crew_app/features/expenses/expenses_page.dart';
import 'package:crew_app/features/messages/presentation/messages_chat/chat_sheet.dart';
import 'package:crew_app/shared/widgets/qr_scanner/qr_scanner_screen.dart';
import 'package:crew_app/features/user/presentation/pages/settings/pages/history/history_page.dart';
import 'package:crew_app/features/user/presentation/pages/edit_profile/edit_profile_page.dart';
import 'package:crew_app/features/user/presentation/pages/drafts/my_drafts_page.dart';
import 'package:crew_app/features/user/presentation/pages/friends/add_friend_page.dart';
import 'package:crew_app/features/user/presentation/pages/moments/my_moments_page.dart';
import 'package:crew_app/features/user/presentation/pages/settings/settings_page.dart';
import 'package:crew_app/features/user/presentation/pages/settings/state/settings_providers.dart';
import 'package:crew_app/features/user/presentation/pages/user_profile/user_profile_page.dart';
import 'package:crew_app/features/user/presentation/pages/settings/pages/wallet/wallet_page.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CrewApp extends ConsumerWidget {
  const CrewApp({super.key});

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
      routes: appRoutes,
    );
  }
}

final Map<String, WidgetBuilder> appRoutes = <String, WidgetBuilder>{
  '/': (context) => const App(),
  '/login': (context) => const LoginPage(),
  '/settings': (context) => const SettingsPage(),
  '/preferences': (context) => EditProfilePage(),
  '/messages_chat': (context) => const ChatSheet(),
  '/expenses': (context) => const ExpensesPage(),
  '/wallet': (context) => const WalletPage(),
  '/moments': (context) => const MyMomentsPage(),
  '/drafts': (context) => const MyDraftsPage(),
  '/add_friend': (context) => const AddFriendPage(),
  '/qr-scanner': (context) => const QrScannerScreen(),
  '/profile': (context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final uid = args is String ? args : null;
    return UserProfilePage(uid: uid);
  },
  '/history': (context) => HistoryPage(),
};
