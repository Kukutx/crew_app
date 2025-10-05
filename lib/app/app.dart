import 'dart:async';
import 'dart:ui';

import 'package:crew_app/features/chat/user_event/presentation/user_events_page.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:crew_app/shared/widgets/scroll_activity_listener.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/events/presentation/list/events_list_page.dart';
import '../features/events/presentation/map/events_map_page.dart';
import '../core/state/app/app_overlay_provider.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});
  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  int _index = 1; // 默认打开“地图”
  bool _isScrolling = false;
  Timer? _scrollDebounceTimer;
  late final PageController _overlayController = PageController(initialPage: 1);
  ProviderSubscription<int>? _overlayIndexSubscription;

  @override
  void initState() {
    super.initState();
    _overlayIndexSubscription = ref.listenManual(
      appOverlayIndexProvider,
      (previous, next) {
        if (next == _index) {
          return;
        }
        setState(() {
          _index = next;
          if (next == 1) {
            _isScrolling = false;
          }
        });
        _overlayController.animateToPage(
          next,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
    );
  }

  @override
  void dispose() {
    _overlayController.dispose();
    _scrollDebounceTimer?.cancel();
    _overlayIndexSubscription?.close();
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

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

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
        color: isScrolling
            ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.52)
            : colorScheme.surface,
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
      NavigationDestination(
        icon: const Icon(Icons.chat_bubble_outline),
        selectedIcon: const Icon(Icons.chat_bubble),
        label: loc.group,
      ),
    ];

    final isOverlayOpen = _index != 1;

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          ScrollActivityListener(
            onScrollActivityChanged: _handleScrollActivity,
            listenToPointerActivity: true,
            child: const EventsMapPage(),
          ),
          IgnorePointer(
            ignoring: !isOverlayOpen,
            child: PageView(
              controller: _overlayController,
              physics: isOverlayOpen
                  ? const PageScrollPhysics()
                  : const NeverScrollableScrollPhysics(),
              onPageChanged: (page) {
                final shouldUpdateIndex = _index != page;
                final shouldResetScroll = page == 1 && _isScrolling;
                if (!shouldUpdateIndex && !shouldResetScroll) {
                  return;
                }
                setState(() {
                  _index = page;
                  if (page == 1) {
                    _isScrolling = false;
                  }
                });
                ref.read(appOverlayIndexProvider.notifier).state = page;
              },
              children: [
                ScrollActivityListener(
                  onScrollActivityChanged: _handleScrollActivity,
                  child: const EventsListPage(),
                ),
                const SizedBox.expand(),
                ScrollActivityListener(
                  onScrollActivityChanged: _handleScrollActivity,
                  child: const UserEventsPage(),
                ),
              ],
            ),
          ),
        ],
      ),
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
                      onDestinationSelected: (i) {
                        if (_index == i) {
                          return;
                        }
                        setState(() {
                          _index = i;
                          if (i == 1) {
                            _isScrolling = false;
                          }
                        });
                        ref.read(appOverlayIndexProvider.notifier).state = i;
                        _overlayController.animateToPage(
                          i,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
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
