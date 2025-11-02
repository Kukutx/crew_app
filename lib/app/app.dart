import 'dart:async';
import 'dart:math' as math;
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
        child: AnimatedSlide(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeInOut,
          offset: Offset(0, showBottomNav ? 0 : 1.2),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeInOut,
            opacity: showBottomNav ? 1 : 0,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: _GlassNavigationBar(
                    destinations: destinations,
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
                    colorScheme: colorScheme,
                    borderRadius: borderRadius,
                    glassBorderColor: glassBorderColor,
                    isScrolling: _isScrolling,
                    theme: theme,
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

class _GlassNavigationBar extends StatelessWidget {
  const _GlassNavigationBar({
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.colorScheme,
    required this.borderRadius,
    required this.glassBorderColor,
    required this.isScrolling,
    required this.theme,
  });

  final List<NavigationDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final ColorScheme colorScheme;
  final BorderRadius borderRadius;
  final Color glassBorderColor;
  final bool isScrolling;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final baseColor = colorScheme.surface.withValues(
      alpha: theme.brightness == Brightness.dark ? 0.42 : 0.82,
    );
    final borderColor = isScrolling
        ? glassBorderColor
        : glassBorderColor.withValues(alpha: 0.6);
    final shadowColor = colorScheme.shadow.withValues(
      alpha: isScrolling ? 0.08 : 0.12,
    );

    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            border: Border.all(color: borderColor),
            color: baseColor,
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: isScrolling ? 30 : 24,
                offset: Offset(0, isScrolling ? 18 : 12),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final itemCount = destinations.length;
                final itemWidth = constraints.maxWidth / itemCount;
                final indicatorWidth = math.min(48.0, itemWidth - 16);
                final indicatorLeft =
                    (itemWidth * selectedIndex) + (itemWidth - indicatorWidth) / 2;

                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        for (var i = 0; i < itemCount; i++)
                          Expanded(
                            child: _GlassNavigationItem(
                              destination: destinations[i],
                              isSelected: selectedIndex == i,
                              colorScheme: colorScheme,
                              onTap: () => onDestinationSelected(i),
                            ),
                          ),
                      ],
                    ),
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOut,
                      left: indicatorLeft,
                      right: null,
                      bottom: 6,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOut,
                        height: 3,
                        width: indicatorWidth,
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassNavigationItem extends StatelessWidget {
  const _GlassNavigationItem({
    required this.destination,
    required this.isSelected,
    required this.colorScheme,
    required this.onTap,
  });

  final NavigationDestination destination;
  final bool isSelected;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final iconColor = isSelected
        ? colorScheme.primary
        : colorScheme.onSurfaceVariant.withValues(alpha: 0.72);

    final iconSize = isSelected ? 30.0 : 26.0;

    return Semantics(
      label: destination.label,
      button: true,
      selected: isSelected,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colorScheme.primary.withValues(alpha: 0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: IconTheme.merge(
                  data: IconThemeData(
                    size: iconSize,
                    color: iconColor,
                  ),
                  child: isSelected
                      ? destination.selectedIcon
                      : destination.icon,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
