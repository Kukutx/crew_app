import 'dart:async';
import 'dart:ui';

import 'package:crew_app/core/state/legal/disclaimer_providers.dart';
import 'package:crew_app/features/chat/user_event/prestantion/user_events_page.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:crew_app/shared/legal/disclaimer_dialog.dart';
import 'package:crew_app/shared/widgets/scroll_activity_listener.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/events/presentation/list/events_list_page.dart';
import '../features/events/presentation/map/events_map_page.dart';

/// 添加免责声明，缺测试
class App extends ConsumerStatefulWidget {
  const App({super.key});
  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  int _index = 1; // 默认打开“地图”
  bool _isScrolling = false;
  Timer? _scrollDebounceTimer;
  late final List<Widget> _pages = [
    ScrollActivityListener(
      onScrollActivityChanged: _handleScrollActivity,
      child: const EventsListPage(),
    ),
    ScrollActivityListener(
      onScrollActivityChanged: _handleScrollActivity,
      listenToPointerActivity: true,
      child: const EventsMapPage(),
    ),
    ScrollActivityListener(
      onScrollActivityChanged: _handleScrollActivity,
      child: const UserEventsPage(),
    ),
  ];
  int? _promptedVersion; // 防止同一版本重复弹
  ProviderSubscription<AsyncValue<DisclaimerState>>?
      _disclaimerSubscription;

  @override
  void initState() {
    super.initState();
    _disclaimerSubscription = ref.listenManual(
      disclaimerStateProvider,
      _onDisclaimerStateChanged,
      fireImmediately: true,
    );
  }

  @override
  void dispose() {
    _scrollDebounceTimer?.cancel();
    _disclaimerSubscription?.close();
    super.dispose();
  }

  void _handleScrollActivity(bool scrolling) {
    _scrollDebounceTimer?.cancel();
    if (scrolling) {
      if (!_isScrolling) {
        setState(() => _isScrolling = true);
      }
      return;
    }

    _scrollDebounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) {
        return;
      }
      if (_isScrolling) {
        setState(() => _isScrolling = false);
      }
    });
  }

  void _onDisclaimerStateChanged(
    AsyncValue<DisclaimerState>? _,
    AsyncValue<DisclaimerState> next,
  ) {
    final disclaimer = next.asData?.value;
    if (disclaimer == null || !disclaimer.needsReconsent) {
      return;
    }

    final version = disclaimer.toShow.version;
    if (_promptedVersion == version) {
      return; // 已经弹过了
    }
    _promptedVersion = version;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) {
        return;
      }
      final accept = ref.read(acceptDisclaimerProvider);
      await showDisclaimerDialog(
        context: context,
        d: disclaimer.toShow,
        onAccept: () => accept(version),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    final legal = ref.watch(disclaimerStateProvider);
    if (legal.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final borderRadius = BorderRadius.circular(30);
    final glassBorderColor = colorScheme.outline.withValues(alpha: 0.14);
    BoxDecoration navDecoration(bool isScrolling) {
      return BoxDecoration(
        borderRadius: borderRadius,
        border: Border.all(
          color: isScrolling ? glassBorderColor : Colors.transparent,
        ),
        gradient: isScrolling
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.surface.withValues(alpha: 0.65),
                  colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
                ],
              )
            : null,
        color: isScrolling ? null : colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: isScrolling ? 0.08 : 0.12),
            blurRadius: isScrolling ? 30 : 24,
            offset: Offset(0, isScrolling ? 18 : 12),
          ),
        ],
      );
    }
    final destinations = <NavigationDestination>[
      NavigationDestination(
        icon: const Icon(Icons.event_outlined),
        selectedIcon: const Icon(Icons.event),
        label: loc.events,
      ),
      NavigationDestination(
        icon: const Icon(Icons.map_outlined),
        selectedIcon: const Icon(Icons.map),
        label: loc.map,
      ),
      const NavigationDestination(
        icon: Icon(Icons.chat_bubble_outline),
        selectedIcon: Icon(Icons.chat_bubble),
        label: 'Group',
      ),
    ];

    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.only(bottom: 28),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: FractionallySizedBox(
            widthFactor: 0.88,
            child: ClipRRect(
              borderRadius: borderRadius,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeInOut,
                  decoration: navDecoration(_isScrolling),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: NavigationBarTheme(
                    data: theme.navigationBarTheme.copyWith(
                      backgroundColor: Colors.transparent,
                      height: 64,
                      indicatorColor:
                          colorScheme.primary.withValues(alpha: 0.18),
                      indicatorShape: const StadiumBorder(),
                      labelBehavior:
                          NavigationDestinationLabelBehavior.alwaysShow,
                      labelTextStyle: WidgetStateProperty.resolveWith(
                        (states) => theme.textTheme.labelMedium?.copyWith(
                          fontWeight: states.contains(WidgetState.selected)
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: states.contains(WidgetState.selected)
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                      iconTheme: WidgetStateProperty.resolveWith(
                        (states) => IconThemeData(
                          size: states.contains(WidgetState.selected)
                              ? 30
                              : 26,
                          color: states.contains(WidgetState.selected)
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    child: NavigationBar(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      selectedIndex: _index,
                      onDestinationSelected: (i) => setState(() => _index = i),
                      destinations: destinations,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
