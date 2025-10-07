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
  int _activeOverlayIndex = 0;
  bool _isScrolling = false;
  Timer? _scrollDebounceTimer;
  ProviderSubscription<int>? _overlayIndexSubscription;

  @override
  void initState() {
    super.initState();
    _overlayIndexSubscription = ref.listenManual(
      appOverlayIndexProvider,
      (previous, next) {
        if (next == _index) {
          if (next != 1 && _activeOverlayIndex != next) {
            setState(() => _activeOverlayIndex = next);
          }
          return;
        }
        setState(() {
          _index = next;
          if (next == 1) {
            _isScrolling = false;
          } else {
            _activeOverlayIndex = next;
          }
        });
      },
    );
  }

  @override
  void dispose() {
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
          _OverlayBottomSheet(
            isVisible: isOverlayOpen,
            isGroup: _activeOverlayIndex == 2,
            onScrollActivityChanged: _handleScrollActivity,
            childBuilder: (scrollController) {
              if (_activeOverlayIndex == 0) {
                return EventsListContent(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                );
              }
              return UserEventsPage(
                embedInScaffold: false,
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
              );
            },
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
                        ref.read(appOverlayIndexProvider.notifier).state = i;
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

class _OverlayBottomSheet extends StatelessWidget {
  const _OverlayBottomSheet({
    required this.isVisible,
    required this.isGroup,
    required this.onScrollActivityChanged,
    required this.childBuilder,
  });

  final bool isVisible;
  final bool isGroup;
  final ValueChanged<bool> onScrollActivityChanged;
  final Widget Function(ScrollController controller) childBuilder;

  void _showNotReady(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final handleColor = colorScheme.onSurfaceVariant.withValues(alpha: 0.28);

    return IgnorePointer(
      ignoring: !isVisible,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
        offset: isVisible ? Offset.zero : const Offset(0, 1.05),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: isVisible ? 1 : 0,
          child: NotificationListener<DraggableScrollableNotification>(
            onNotification: (notification) {
              if (!isVisible) {
                return false;
              }
              final isMoving = notification.extent != notification.minExtent &&
                  notification.extent != notification.maxExtent;
              onScrollActivityChanged(isMoving);
              if (!isMoving) {
                onScrollActivityChanged(false);
              }
              return false;
            },
            child: DraggableScrollableSheet(
              expand: false,
              minChildSize: 0.2,
              initialChildSize: 0.45,
              maxChildSize: 0.92,
              snap: true,
              snapSizes: const [0.25, 0.45, 0.85],
              builder: (context, scrollController) {
                final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
                return Padding(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 16 + bottomPadding,
                  ),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.shadow.withValues(alpha: 0.12),
                          blurRadius: 30,
                          offset: const Offset(0, 18),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        Container(
                          width: 48,
                          height: 4,
                          decoration: BoxDecoration(
                            color: handleColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  isGroup ? loc.group : loc.events_title,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              IconButton(
                                tooltip: loc.feature_not_ready,
                                onPressed: () =>
                                    _showNotReady(context, loc.feature_not_ready),
                                icon: Icon(
                                  isGroup ? Icons.group_add : Icons.filter_list_alt,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: NotificationListener<ScrollNotification>(
                            onNotification: (notification) {
                              if (notification is ScrollStartNotification) {
                                onScrollActivityChanged(true);
                              } else if (notification is ScrollEndNotification) {
                                onScrollActivityChanged(false);
                              }
                              return false;
                            },
                            child: childBuilder(scrollController),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
