import 'dart:async';
import 'dart:ui';

import 'package:crew_app/core/state/auth/auth_providers.dart';
import 'package:crew_app/features/user/presentation/pages/user_profile/user_profile_page.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:crew_app/shared/widgets/scroll_activity_listener.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:crew_app/features/events/presentation/pages/map/events_map_page.dart';
import 'state/app_overlay_provider.dart';
import 'state/bottom_navigation_visibility_provider.dart';
import 'package:crew_app/features/events/presentation/pages/map/state/map_overlay_sheet_provider.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});
  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  int _index = 0; // 默认打开“地图”
  int _navigationIndex = 1;
  bool _isScrolling = false;
  Timer? _scrollDebounceTimer;
  late final PageController _overlayController = PageController(initialPage: 0);
  ProviderSubscription<int>? _overlayIndexSubscription;
  ProviderSubscription<MapOverlaySheetType>? _mapSheetSubscription;

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
          if (next == 0) {
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

    _mapSheetSubscription = ref.listenManual(
      mapOverlaySheetProvider,
      (previous, next) {
        if (!mounted) {
          return;
        }
        switch (next) {
          case MapOverlaySheetType.none:
            if (_navigationIndex != 1) {
              setState(() => _navigationIndex = 1);
            }
            break;
          case MapOverlaySheetType.explore:
            if (_navigationIndex != 0) {
              setState(() => _navigationIndex = 0);
            }
            break;
          case MapOverlaySheetType.chat:
            if (_navigationIndex != 2) {
              setState(() => _navigationIndex = 2);
            }
            break;
        }
      },
    );
  }

  @override
  void dispose() {
    _overlayController.dispose();
    _scrollDebounceTimer?.cancel();
    _overlayIndexSubscription?.close();
    _mapSheetSubscription?.close();
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
    final currentUser = ref.watch(currentUserProvider);

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
            : colorScheme.surface.withValues(alpha: 0.9),
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
        label: loc.messages,
      ),
    ];

    final isOverlayOpen = _index != 0;

    final showBottomNav =
        _index == 0 && ref.watch(bottomNavigationVisibilityProvider);

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
                final shouldResetScroll = page == 0 && _isScrolling;
                if (!shouldUpdateIndex && !shouldResetScroll) {
                  return;
                }
                setState(() {
                  _index = page;
                  if (page == 0) {
                    _isScrolling = false;
                  }
                });
                ref.read(appOverlayIndexProvider.notifier).state = page;
              },
              children: [
                const SizedBox.expand(),
                ScrollActivityListener(
                  onScrollActivityChanged: _handleScrollActivity,
                  child: UserProfilePage(
                    uid: currentUser?.uid,
                    onClose: () {
                      ref.read(appOverlayIndexProvider.notifier).state = 0;
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 0, 20, 22),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: AnimatedSlide(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeInOut,
            offset: Offset(0, showBottomNav ? 0 : 1.2),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeInOut,
              opacity: showBottomNav ? 1 : 0,
              child: ClipRRect(
                borderRadius: borderRadius,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: DecoratedBox(
                    decoration: navDecoration(_isScrolling),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      child: NavigationBarTheme(
                        data: theme.navigationBarTheme.copyWith(
                          backgroundColor: Colors.transparent,
                          height: 64,
                          indicatorColor:
                              colorScheme.primary.withValues(alpha: 0.16),
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
                          selectedIndex: _navigationIndex,
                          onDestinationSelected: (i) {
                            if (_navigationIndex != i) {
                              setState(() => _navigationIndex = i);
                            }
                            if (i != 0 && i != 2) {
                              ref.read(mapOverlaySheetProvider.notifier).state =
                                  MapOverlaySheetType.none;
                            }
                            if (i == 0) {
                              ref.read(mapOverlaySheetProvider.notifier).state =
                                  MapOverlaySheetType.explore;
                            } else if (i == 2) {
                              ref.read(mapOverlaySheetProvider.notifier).state =
                                  MapOverlaySheetType.chat;
                            }
                            if (_index != 0) {
                              ref.read(appOverlayIndexProvider.notifier).state = 0;
                            }
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
        ),
      ),
    );
  }
}
