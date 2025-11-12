import 'dart:ui';

import 'package:crew_app/features/events/presentation/widgets/common/components/map_overlay_sheet_providers.dart';
import 'package:crew_app/features/events/presentation/widgets/common/components/map_overlay_sheet_stage_providers.dart';
import 'package:crew_app/shared/utils/responsive_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/app_overlay_providers.dart';
import '../state/bottom_navigation_visibility_providers.dart';

class AppBottomNavigation extends ConsumerStatefulWidget {
  const AppBottomNavigation({
    super.key,
    required this.show,
    required this.isScrolling,
  });

  final bool show;
  final bool isScrolling;

  @override
  ConsumerState<AppBottomNavigation> createState() => _AppBottomNavigationState();
}

class _AppBottomNavigationState extends ConsumerState<AppBottomNavigation> {
  /// 根据 MapOverlaySheetType 计算导航索引
  int _getNavigationIndex(MapOverlaySheetType sheetType) {
    switch (sheetType) {
      case MapOverlaySheetType.explore:
        return 0;
      case MapOverlaySheetType.none:
      case MapOverlaySheetType.createRoadTrip:
      case MapOverlaySheetType.createCityEvent:
        return 1;
      case MapOverlaySheetType.chat:
        return 2;
    }
  }

  void _handleDestinationSelected(int index) {
    // 添加触感反馈
    HapticFeedback.lightImpact();

    final sheetNotifier = ref.read(mapOverlaySheetProvider.notifier);
    switch (index) {
      case 0:
        sheetNotifier.state = MapOverlaySheetType.explore;
        break;
      case 1:
        sheetNotifier.state = MapOverlaySheetType.none;
        break;
      case 2:
        sheetNotifier.state = MapOverlaySheetType.chat;
        break;
    }

    ref.read(appOverlayIndexProvider.notifier).state = 0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final borderRadius = BorderRadius.circular(18.r);
    final glassBorderColor = colorScheme.outline.withValues(alpha: 0.14);

    // 使用 select 优化性能，只监听需要的部分
    final mapSheetType = ref.watch(mapOverlaySheetProvider);
    final mapSheetStage = ref.watch(mapOverlaySheetStageProvider);
    final baseVisible = widget.show && ref.watch(bottomNavigationVisibilityProvider);
    
    // 计算导航索引
    final navigationIndex = _getNavigationIndex(mapSheetType);
    
    // 出现创建活动时强制隐藏；其它 Sheet 只在完全展开时隐藏
    final hideForCreate = mapSheetType == MapOverlaySheetType.createRoadTrip ||
        mapSheetType == MapOverlaySheetType.createCityEvent;
    final hideForOthers = mapSheetType != MapOverlaySheetType.none &&
        mapSheetStage == MapOverlaySheetStage.expanded;
    final showBottomNav = baseVisible && !hideForCreate && !hideForOthers;

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
            blurRadius: isScrolling ? 30.r : 24.r,
            offset: Offset(0, isScrolling ? 18.h : 12.h),
          ),
        ],
      );
    }

    return SafeArea(
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeInOut,
        offset: Offset(0, showBottomNav ? 0 : 1.2),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeInOut,
          opacity: showBottomNav ? 1 : 0,
          child: Padding(
            padding: EdgeInsets.fromLTRB(10.w, 0, 10.w, 0),
            child: ClipRRect(
              borderRadius: borderRadius,
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: widget.isScrolling ? 12 : 0,
                  sigmaY: widget.isScrolling ? 12 : 0,
                ),
                child: Container(
                  decoration: navDecoration(widget.isScrolling),
                  child: NavigationBarTheme(
                    data: theme.navigationBarTheme.copyWith(
                      backgroundColor: Colors.transparent,
                      height: 64.h,
                      indicatorColor: colorScheme.primary.withValues(
                        alpha: 0.12,
                      ),
                      indicatorShape: const StadiumBorder(),
                      labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
                      iconTheme: WidgetStateProperty.resolveWith(
                        (states) => IconThemeData(
                          size: states.contains(WidgetState.selected) ? 30.sp : 26.sp,
                          color: states.contains(WidgetState.selected)
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    child: NavigationBar(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      selectedIndex: navigationIndex,
                      onDestinationSelected: _handleDestinationSelected,
                      destinations: const [
                        NavigationDestination(
                          icon: Icon(Icons.event_outlined),
                          selectedIcon: Icon(Icons.event),
                          label: '',
                        ),
                        NavigationDestination(
                          icon: Icon(Icons.map_outlined),
                          selectedIcon: Icon(Icons.map),
                          label: '',
                        ),
                        NavigationDestination(
                          icon: Icon(Icons.chat_bubble_outline),
                          selectedIcon: Icon(Icons.chat_bubble),
                          label: '',
                        ),
                      ],
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
