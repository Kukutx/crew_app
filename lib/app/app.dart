import 'dart:async';
import 'package:crew_app/core/state/auth/auth_providers.dart';
import 'package:crew_app/features/events/presentation/pages/map/events_map_page.dart';
import 'package:crew_app/features/events/presentation/pages/map/state/map_overlay_sheet_provider.dart';
import 'package:crew_app/features/user/presentation/pages/user_profile/user_profile_page.dart';
import 'package:crew_app/app/state/scroll_activity_listener.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'state/app_overlay_provider.dart';
import 'view/app_bottom_navigation.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});
  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  int _index = 0; // 默认打开“地图”
  bool _isScrolling = false;
  Timer? _scrollDebounceTimer;
  late final PageController _overlayController = PageController(initialPage: 0);
  ProviderSubscription<int>? _overlayIndexSubscription;

  @override
  void initState() {
    super.initState();
    // 如果登录了，设置 MapOverlaySheetType.none，导航索引会设置为1
    // 延迟到构建完成后修改 provider，避免在 initState 中直接修改
    final currentUser = ref.read(currentUserProvider);
    if (currentUser != null) {
      Future.microtask(() {
        if (mounted) {
          ref.read(mapOverlaySheetProvider.notifier).state = MapOverlaySheetType.none;
        }
      });
    }
    
    _overlayIndexSubscription = ref.listenManual(appOverlayIndexProvider, (
      previous,
      next,
    ) {
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
    });
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
    final currentUser = ref.watch(currentUserProvider);

    final isOverlayOpen = _index != 0;

    final canShowBottomNav = _index == 0;

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
      bottomNavigationBar: AppBottomNavigation(
        show: canShowBottomNav,
        isScrolling: _isScrolling,
      ),
    );
  }
}
