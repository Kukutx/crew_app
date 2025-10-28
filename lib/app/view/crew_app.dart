import 'dart:async';

import 'package:crew_app/app/app.dart';
import 'package:crew_app/core/monitoring/monitoring_providers.dart';
import 'package:crew_app/features/auth/presentation/login_page.dart';
import 'package:crew_app/features/expenses/expenses_page.dart';
import 'package:crew_app/features/messages/presentation/messages_chat/chat_sheet.dart';
import 'package:crew_app/features/user/presentation/pages/edit_profile/edit_profile_page.dart';
import 'package:crew_app/features/user/presentation/pages/drafts/my_drafts_page.dart';
import 'package:crew_app/features/user/presentation/pages/friends/add_friend_page.dart';
import 'package:crew_app/features/user/presentation/pages/moments/my_moments_page.dart';
import 'package:crew_app/features/user/presentation/pages/qr/my_qr_code_page.dart';
import 'package:crew_app/features/user/presentation/pages/settings/pages/wallet/wallet_page.dart';
import 'package:crew_app/features/user/presentation/pages/settings/settings_page.dart';
import 'package:crew_app/features/user/presentation/pages/settings/state/settings_providers.dart';
import 'package:crew_app/features/user/presentation/pages/support/support_feedback_page.dart';
import 'package:crew_app/features/user/presentation/pages/user_profile/user_profile_page.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:crew_app/shared/widgets/qr_scanner/qr_scanner_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_actions/quick_actions.dart';

const String _scanQrShortcutType = 'action_scan_qr';
const String _myQrShortcutType = 'action_my_qr_code';

final GlobalKey<NavigatorState> crewAppNavigatorKey = GlobalKey<NavigatorState>();

class CrewApp extends ConsumerStatefulWidget {
  const CrewApp({super.key});

  @override
  ConsumerState<CrewApp> createState() => _CrewAppState();
}

class _CrewAppState extends ConsumerState<CrewApp> {
  final QuickActions _quickActions = const QuickActions();
  Locale? _lastLocale;
  String? _pendingShortcutType;
  bool _scheduledShortcutHandling = false;

  @override
  void initState() {
    super.initState();
    _quickActions.initialize(_handleShortcutSelection);
  }

  void _handleShortcutSelection(String shortcutType) {
    if (_tryHandleShortcut(shortcutType)) {
      if (_pendingShortcutType == null) {
        return;
      }
      if (!mounted) {
        _pendingShortcutType = null;
        return;
      }
      setState(() {
        _pendingShortcutType = null;
      });
      return;
    }

    if (!mounted) {
      _pendingShortcutType = shortcutType;
      return;
    }

    setState(() {
      _pendingShortcutType = shortcutType;
    });
  }

  bool _tryHandleShortcut(String? shortcutType) {
    if (shortcutType == null || shortcutType.isEmpty) {
      return false;
    }

    final navigator = crewAppNavigatorKey.currentState;
    if (navigator == null) {
      return false;
    }

    switch (shortcutType) {
      case _scanQrShortcutType:
        navigator.pushNamed('/qr-scanner');
        return true;
      case _myQrShortcutType:
        navigator.pushNamed('/my-qr-code');
        return true;
      default:
        return false;
    }
  }

  void _maybeSchedulePendingShortcutHandling() {
    if (_pendingShortcutType == null || _scheduledShortcutHandling) {
      return;
    }

    _scheduledShortcutHandling = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduledShortcutHandling = false;
      if (_pendingShortcutType == null) {
        return;
      }
      if (_tryHandleShortcut(_pendingShortcutType)) {
        if (!mounted) {
          _pendingShortcutType = null;
          return;
        }
        setState(() {
          _pendingShortcutType = null;
        });
        return;
      }
      _maybeSchedulePendingShortcutHandling();
    });
  }

  void _updateQuickActions(AppLocalizations loc, Locale locale) {
    if (_lastLocale == locale) {
      return;
    }
    _lastLocale = locale;

    unawaited(
      _quickActions.setShortcutItems(
        <ShortcutItem>[
          ShortcutItem(
            type: _scanQrShortcutType,
            localizedTitle: loc.qr_scanner_title,
          ),
          ShortcutItem(
            type: _myQrShortcutType,
            localizedTitle: loc.qr_scanner_my_code,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final routeObserver = ref.watch(talkerRouteObserverProvider);

    return MaterialApp(
      navigatorKey: crewAppNavigatorKey,
      title: 'Events Demo',
      locale: settings.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: settings.themeMode,
      navigatorObservers: [routeObserver],
      routes: appRoutes,
      builder: (context, child) {
        final loc = AppLocalizations.of(context);
        if (loc != null) {
          final locale = Localizations.localeOf(context);
          _updateQuickActions(loc, locale);
        }
        _maybeSchedulePendingShortcutHandling();
        return child ?? const SizedBox.shrink();
      },
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
  '/support': (context) => const SupportFeedbackPage(),
  '/moments': (context) => const MyMomentsPage(),
  '/drafts': (context) => const MyDraftsPage(),
  '/add_friend': (context) => const AddFriendPage(),
  '/qr-scanner': (context) => const QrScannerScreen(),
  '/my-qr-code': (context) => const MyQrCodePage(),
  '/profile': (context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final uid = args is String ? args : null;
    return UserProfilePage(uid: uid);
  },
};
