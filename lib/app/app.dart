import 'dart:async';
import 'dart:ui';

import 'package:crew_app/features/events/presentation/group_chat/group_chat_page.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:crew_app/shared/widgets/scroll_activity_listener.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/events/presentation/events_list/events_list_page.dart';
import '../features/events/presentation/map/events_map_page.dart';
import '../shared/playground/profile/profile_page.dart';
import 'state/app_overlay_provider.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});
  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  int _index = 1; // 默认打开“地图”
  bool _isScrolling = false;
  Timer? _scrollDebounceTimer;
  ProviderSubscription<int>? _overlayIndexSubscription;

  static const double _sheetMinExtent = 0.46;
  static const double _sheetInitialExtent = 0.68;
  static const double _sheetMaxExtent = 0.95;

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
    final selectedDestination = _index == 3 ? 1 : _index;

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          ScrollActivityListener(
            onScrollActivityChanged: _handleScrollActivity,
            listenToPointerActivity: true,
            child: const EventsMapPage(),
          ),
          Positioned.fill(
            child: IgnorePointer(
              ignoring: !isOverlayOpen,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 240),
                color: isOverlayOpen
                    ? Colors.black.withValues(alpha: 0.08)
                    : Colors.transparent,
              ),
            ),
          ),
          IgnorePointer(
            ignoring: !isOverlayOpen,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeInOut,
                offset: isOverlayOpen ? Offset.zero : const Offset(0, 1),
                child: isOverlayOpen
                    ? DraggableScrollableSheet(
                        initialChildSize: _sheetInitialExtent,
                        minChildSize: _sheetMinExtent,
                        maxChildSize: _sheetMaxExtent,
                        snap: true,
                        snapSizes: const [
                          _sheetMinExtent,
                          _sheetInitialExtent,
                          _sheetMaxExtent,
                        ],
                        builder: (context, controller) {
                          return ScrollActivityListener(
                            onScrollActivityChanged: _handleScrollActivity,
                            listenToPointerActivity: true,
                            child: _OverlayContent(
                              index: _index,
                              controller: controller,
                              onClose: () => ref
                                  .read(appOverlayIndexProvider.notifier)
                                  .state = 1,
                            ),
                          );
                        },
                      )
                    : const SizedBox.shrink(),
              ),
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
                    selectedIndex: selectedDestination,
                    onDestinationSelected: (i) {
                      final targetIndex = i;
                      if (_index == targetIndex) {
                        return;
                      }
                      setState(() {
                        _index = targetIndex;
                        if (targetIndex == 1) {
                          _isScrolling = false;
                        }
                      });
                      ref.read(appOverlayIndexProvider.notifier).state =
                          targetIndex;
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

class _OverlayContent extends StatelessWidget {
  const _OverlayContent({
    required this.index,
    required this.controller,
    required this.onClose,
  });

  final int index;
  final ScrollController controller;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    switch (index) {
      case 0:
        return EventsListPage(
          showAsSheet: true,
          scrollController: controller,
          onClose: onClose,
        );
      case 2:
        return GroupChatPage(
          showAsSheet: true,
          scrollController: controller,
          onClose: onClose,
        );
      case 3:
        return ProfileSheet(
          controller: controller,
          onClose: onClose,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
