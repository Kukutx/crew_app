import 'package:crew_app/core/state/auth/auth_providers.dart';
import 'package:crew_app/features/events/presentation/pages/map/events_map_page.dart';
import 'package:crew_app/features/events/presentation/widgets/common/components/map_overlay_sheet_providers.dart';
import 'package:crew_app/features/user/presentation/pages/user_profile/user_profile_page.dart';
import 'package:crew_app/app/state/scroll_activity_listener.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'state/app_overlay_providers.dart';
import 'state/scroll_activity_providers.dart';
import 'view/app_bottom_navigation.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});
  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  late final PageController _overlayController = PageController(initialPage: 0);

  @override
  void initState() {
    super.initState();
    // 如果登录了，设置 MapOverlaySheetType.none
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentUser = ref.read(currentUserProvider);
      if (currentUser != null && mounted) {
        ref.read(mapOverlaySheetProvider.notifier).state = MapOverlaySheetType.none;
      }
    });

    // 监听 overlay 索引变化，同步到 PageController
    ref.listenManual(appOverlayIndexProvider, (previous, next) {
      if (!mounted) return;
      if (_overlayController.hasClients && _overlayController.page?.round() != next) {
        _overlayController.animateToPage(
          next,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _overlayController.dispose();
    super.dispose();
  }

  void _handlePageChanged(int page) {
    final currentIndex = ref.read(appOverlayIndexProvider);
    if (currentIndex == page) return;

    ref.read(appOverlayIndexProvider.notifier).state = page;
    
    // 如果返回到地图页面，重置滚动状态
    if (page == 0) {
      ref.read(scrollActivityProvider.notifier).reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    // 使用 select 优化性能，只监听需要的部分
    final overlayIndex = ref.watch(appOverlayIndexProvider);
    final currentUser = ref.watch(currentUserProvider.select((user) => user?.uid));
    final isScrolling = ref.watch(scrollActivityProvider);

    final isOverlayOpen = overlayIndex != 0;

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          ScrollActivityListener(
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
              onPageChanged: _handlePageChanged,
              children: [
                const SizedBox.expand(),
                ScrollActivityListener(
                  child: UserProfilePage(
                    uid: currentUser,
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
        show: !isOverlayOpen,
        isScrolling: isScrolling,
      ),
    );
  }
}
