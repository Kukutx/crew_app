import 'dart:async';

import 'package:crew_app/app/router/app_router.dart';
import 'package:crew_app/core/config/app_theme.dart';
import 'package:crew_app/features/settings/state/settings_providers.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:crew_app/shared/state/country_city_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quick_actions/quick_actions.dart';

const String _scanQrShortcutType = 'action_scan_qr';
const String _myQrShortcutType = 'action_my_qr_code';

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

    switch (shortcutType) {
      case _scanQrShortcutType:
        ref.read(crewAppRouterProvider).push(AppRoutePaths.qrScanner);
        return true;
      case _myQrShortcutType:
        ref.read(crewAppRouterProvider).push(AppRoutePaths.myQrCode);
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
    final router = ref.watch(crewAppRouterProvider);
    // 预加载国家-城市数据
    ref.watch(countryCityDataProvider);

    return ScreenUtilInit(
      // 设计稿基准尺寸：iPhone 13 (390x844)
      designSize: const Size(390, 844),
      // 最小文字适配，确保文字不会过小
      minTextAdapt: true,
      // 根据屏幕高度分割，确保横竖屏都能正常显示
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'Crew',
          locale: settings.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: settings.themeMode,
          routerConfig: router,
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
      },
    );
  }
}
