import 'dart:ui';

import 'package:crew_app/core/state/auth/auth_providers.dart';
import 'package:crew_app/features/events/presentation/pages/map/sheets/map_moments_sheet.dart';
import 'package:crew_app/features/messages/presentation/messages_chat/chat_sheet.dart';
import 'package:crew_app/features/user/presentation/pages/user_profile/user_profile_page.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:crew_app/shared/playground/my_test_page.dart';
import 'package:crew_app/shared/widgets/scroll_activity_listener.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:crew_app/features/events/presentation/pages/map/events_map_page.dart';
import 'state/app_navigation_controller.dart';
import 'state/bottom_navigation_visibility_provider.dart';

class App extends ConsumerWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final controller = ref.watch(appNavigationControllerProvider);
    final currentUser = ref.watch(currentUserProvider);
    final bottomNavigationVisible = ref.watch(bottomNavigationVisibilityProvider);

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

    Future<void> showEventsListSheet() {
      return showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (sheetContext) {
          return FractionallySizedBox(
            heightFactor: 0.92,
            child: const MapMomentsSheet(),
          );
        },
      );
    }

    Future<void> showChatSheet() {
      return showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (sheetContext) {
          return FractionallySizedBox(
            heightFactor: 0.92,
            child: const ChatSheet(),
          );
        },
      );
    }

    final showBottomNav = controller.index == 1 && bottomNavigationVisible;

    return Scaffold(
      extendBody: true,
      body: AppOverlayView(
        controller: controller,
        currentUserUid: currentUser?.uid,
      ),
      bottomNavigationBar: AppBottomNav(
        controller: controller,
        destinations: destinations,
        showBottomNav: showBottomNav,
        onShowEventsSheet: showEventsListSheet,
        onShowChatSheet: showChatSheet,
      ),
    );
  }
}

class AppOverlayView extends StatelessWidget {
  const AppOverlayView({
    super.key,
    required this.controller,
    required this.currentUserUid,
  });

  final AppNavigationController controller;
  final String? currentUserUid;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ScrollActivityListener(
          onScrollActivityChanged: controller.handleScrollActivity,
          listenToPointerActivity: true,
          child: const EventsMapPage(),
        ),
        IgnorePointer(
          ignoring: !controller.isOverlayOpen,
          child: PageView(
            controller: controller.overlayController,
            physics: controller.isOverlayOpen
                ? const PageScrollPhysics()
                : const NeverScrollableScrollPhysics(),
            onPageChanged: controller.onOverlayPageChanged,
            children: [
              ScrollActivityListener(
                onScrollActivityChanged: controller.handleScrollActivity,
                child: MyTestPage(
                  onClose: controller.closeOverlay,
                ),
              ),
              const SizedBox.expand(),
              ScrollActivityListener(
                onScrollActivityChanged: controller.handleScrollActivity,
                child: UserProfilePage(
                  uid: currentUserUid,
                  onClose: controller.closeOverlay,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.controller,
    required this.destinations,
    required this.showBottomNav,
    required this.onShowEventsSheet,
    required this.onShowChatSheet,
  });

  final AppNavigationController controller;
  final List<NavigationDestination> destinations;
  final bool showBottomNav;
  final SheetLauncher onShowEventsSheet;
  final SheetLauncher onShowChatSheet;

  @override
  Widget build(BuildContext context) {
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
            color: colorScheme.shadow.withValues(
              alpha: isScrolling ? 0.08 : 0.12,
            ),
            blurRadius: isScrolling ? 30 : 24,
            offset: Offset(0, isScrolling ? 18 : 12),
          ),
        ],
      );
    }

    return SafeArea(
      minimum: const EdgeInsets.only(bottom: 28),
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
            child: FractionallySizedBox(
              widthFactor: 0.88,
              child: ClipRRect(
                borderRadius: borderRadius,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 240),
                    curve: Curves.easeInOut,
                    decoration: navDecoration(controller.isScrolling),
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
                            size: states.contains(WidgetState.selected) ? 30 : 26,
                            color: states.contains(WidgetState.selected)
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      child: NavigationBar(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        selectedIndex: controller.navigationIndex,
                        onDestinationSelected: (index) {
                          controller.onDestinationSelected(
                            index,
                            showEventsSheet: onShowEventsSheet,
                            showChatSheet: onShowChatSheet,
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
      ),
    );
  }
}
