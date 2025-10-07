import 'dart:async';
import 'dart:ui';

import 'package:crew_app/features/chat/user_event/presentation/user_events_page.dart';
import 'package:crew_app/features/events/presentation/list/events_list_page.dart';
import 'package:crew_app/features/events/presentation/map/events_map_page.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:crew_app/shared/widgets/scroll_activity_listener.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/state/app/app_overlay_provider.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});
  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  static const _sheetSnapSizes = [0.18, 0.42, 0.9];
  static const _sheetAnimationDuration = Duration(milliseconds: 280);

  int _index = 1; // 默认打开“地图”
  bool _isScrolling = false;
  Timer? _scrollDebounceTimer;
  double _sheetExtent = 0.0;

  late final DraggableScrollableController _sheetController;
  ProviderSubscription<int>? _navIndexSubscription;

  @override
  void initState() {
    super.initState();
    _sheetController = DraggableScrollableController();
    _sheetController.addListener(_handleSheetExtentChanged);
    _navIndexSubscription = ref.listenManual(
      appOverlayIndexProvider,
      (previous, next) => _onNavIndexChanged(next),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _onNavIndexChanged(ref.read(appOverlayIndexProvider));
    });
  }

  @override
  void dispose() {
    _navIndexSubscription?.close();
    _sheetController.removeListener(_handleSheetExtentChanged);
    _sheetController.dispose();
    _scrollDebounceTimer?.cancel();
    super.dispose();
  }

  void _onNavIndexChanged(int next) {
    if (!mounted) {
      return;
    }
    if (_index == next) {
      if (next != 1) {
        _expandSheet();
      }
      return;
    }
    setState(() {
      _index = next;
      if (next == 1) {
        _isScrolling = false;
      }
    });
    if (next == 1) {
      _collapseSheet();
    } else {
      _expandSheet();
    }
  }

  void _handleSheetExtentChanged() {
    if (!mounted || !_sheetController.isAttached) {
      return;
    }
    final size = _sheetController.size;
    if ((size - _sheetExtent).abs() < 0.0005) {
      return;
    }
    setState(() {
      _sheetExtent = size;
      if (size <= 0.001 && _index != 1) {
        _index = 1;
        _isScrolling = false;
        ref.read(appOverlayIndexProvider.notifier).state = 1;
      }
    });
  }

  void _expandSheet() {
    if (!_sheetController.isAttached) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _expandSheet());
      return;
    }
    final target = _sheetController.size <= 0.0
        ? _sheetSnapSizes[1]
        : _sheetController.size
            .clamp(_sheetSnapSizes.first, _sheetSnapSizes.last);
    _sheetController.animateTo(
      target,
      duration: _sheetAnimationDuration,
      curve: Curves.easeInOut,
    );
  }

  void _collapseSheet() {
    if (!_sheetController.isAttached) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _collapseSheet());
      return;
    }
    _sheetController.animateTo(
      0.0,
      duration: _sheetAnimationDuration,
      curve: Curves.easeInOut,
    );
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

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          ScrollActivityListener(
            onScrollActivityChanged: _handleScrollActivity,
            listenToPointerActivity: true,
            child: const EventsMapPage(),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: IgnorePointer(
              ignoring: _sheetExtent <= 0.001,
              child: AnimatedOpacity(
                opacity: _sheetExtent <= 0.001 ? 0 : 1,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: DraggableScrollableSheet(
                  controller: _sheetController,
                  snap: true,
                  minChildSize: 0.0,
                  maxChildSize: _sheetSnapSizes.last,
                  initialChildSize: 0.0,
                  snapSizes: _sheetSnapSizes,
                  builder: (context, scrollController) {
                    final bottomPadding =
                        MediaQuery.of(context).viewPadding.bottom;
                    return Padding(
                      padding: EdgeInsets.only(
                        left: 12,
                        right: 12,
                        bottom: 12 + bottomPadding,
                      ),
                      child: _SheetContainer(
                        child: _buildSheetContent(
                          context,
                          loc,
                          scrollController,
                        ),
                      ),
                    );
                  },
                ),
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
                      selectedIndex: _index,
                      onDestinationSelected: (i) {
                        if (_index == i) {
                          if (i != 1) {
                            _expandSheet();
                          }
                          return;
                        }
                        setState(() {
                          _index = i;
                          if (i == 1) {
                            _isScrolling = false;
                          }
                        });
                        ref.read(appOverlayIndexProvider.notifier).state = i;
                        if (i == 1) {
                          _collapseSheet();
                        } else {
                          _expandSheet();
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
    );
  }

  Widget _buildSheetContent(
    BuildContext context,
    AppLocalizations loc,
    ScrollController scrollController,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final title = _index == 0 ? loc.events_title : loc.my_events;
    final body = _index == 0
        ? EventsListPage(
            useScaffold: false,
            scrollController: scrollController,
            contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          )
        : UserEventsPage(
            useScaffold: false,
            scrollController: scrollController,
          );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.14),
            blurRadius: 32,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.28),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
              child: Row(
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      ref.read(appOverlayIndexProvider.notifier).state = 1;
                      _collapseSheet();
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: NotificationListener<UserScrollNotification>(
                onNotification: (notification) {
                  final scrolling =
                      notification.direction != ScrollDirection.idle;
                  _handleScrollActivity(scrolling);
                  return false;
                },
                child: body,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetContainer extends StatelessWidget {
  const _SheetContainer({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: child,
        );
      },
    );
  }
}

