import 'package:crew_app/core/state/auth/auth_providers.dart';
import 'package:crew_app/features/events/presentation/pages/map/events_map_page.dart';
import 'package:crew_app/features/user/presentation/pages/user_profile/user_profile_page.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'state/app_overlay_provider.dart';
import 'state/bottom_navigation_visibility_provider.dart';
import 'state/map_overlay_sheet.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});
  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  int _index = 0; // 默认打开“地图”
  int _navigationIndex = 1;
  MapOverlaySheet? _activeSheet;
  late final PageController _overlayController = PageController(initialPage: 0);
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
          if (next != 0 && _activeSheet != null) {
            _activeSheet = null;
            _navigationIndex = 1;
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
    _overlayIndexSubscription?.close();
    super.dispose();
  }

  void _handleSheetDismissed() {
    if (_activeSheet == null) {
      return;
    }
    setState(() {
      _activeSheet = null;
      _navigationIndex = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final currentUser = ref.watch(currentUserProvider);

    final theme = Theme.of(context);
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
      body: Stack(
        children: [
          EventsMapPage(
            activeSheet: _activeSheet,
            onSheetDismissed: _handleSheetDismissed,
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
                if (!shouldUpdateIndex) {
                  return;
                }
                setState(() {
                  _index = page;
                  if (page == 0) {
                    return;
                  }
                  _activeSheet = null;
                  _navigationIndex = 1;
                });
                ref.read(appOverlayIndexProvider.notifier).state = page;
              },
              children: [
                const SizedBox.expand(),
                UserProfilePage(
                  uid: currentUser?.uid,
                  onClose: () {
                    ref.read(appOverlayIndexProvider.notifier).state = 0;
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: AnimatedSlide(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeInOut,
        offset: Offset(0, showBottomNav ? 0 : 1.2),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeInOut,
          opacity: showBottomNav ? 1 : 0,
          child: SafeArea(
            top: false,
            child: NavigationBarTheme(
              data: theme.navigationBarTheme.copyWith(
                height: 72,
                indicatorColor: theme.colorScheme.primary.withValues(alpha: 0.18),
                indicatorShape: const StadiumBorder(),
                labelBehavior:
                    NavigationDestinationLabelBehavior.alwaysShow,
                labelTextStyle: WidgetStateProperty.resolveWith(
                  (states) => theme.textTheme.labelMedium?.copyWith(
                    fontWeight: states.contains(WidgetState.selected)
                        ? FontWeight.w600
                        : FontWeight.w500,
                    color: states.contains(WidgetState.selected)
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                iconTheme: WidgetStateProperty.resolveWith(
                  (states) => IconThemeData(
                    size: states.contains(WidgetState.selected) ? 30 : 26,
                    color: states.contains(WidgetState.selected)
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                backgroundColor: theme.colorScheme.surface,
              ),
              child: NavigationBar(
                elevation: 0,
                backgroundColor: theme.colorScheme.surface,
                surfaceTintColor: theme.colorScheme.surface,
                selectedIndex: _navigationIndex,
                onDestinationSelected: (i) {
                  if (i == 0) {
                    setState(() {
                      _navigationIndex = 0;
                      _activeSheet = MapOverlaySheet.explore;
                    });
                    return;
                  }
                  if (i == 2) {
                    setState(() {
                      _navigationIndex = 2;
                      _activeSheet = MapOverlaySheet.chat;
                    });
                    return;
                  }
                  setState(() {
                    _navigationIndex = 1;
                    _activeSheet = null;
                  });
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
    );
  }
}
