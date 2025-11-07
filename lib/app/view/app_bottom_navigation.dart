import 'dart:ui';

import 'package:crew_app/features/events/presentation/pages/map/state/map_overlay_sheet_provider.dart';
import 'package:crew_app/features/events/presentation/pages/map/state/map_overlay_sheet_stage_provider.dart';
import 'package:crew_app/shared/utils/responsive_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/app_overlay_provider.dart';
import '../state/bottom_navigation_visibility_provider.dart';

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
  int _navigationIndex = 1;
  ProviderSubscription<MapOverlaySheetType>? _mapSheetSubscription;

  @override
  void initState() {
    super.initState();
    _mapSheetSubscription = ref.listenManual(mapOverlaySheetProvider, (
      previous,
      next,
    ) {
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
        case MapOverlaySheetType.createRoadTrip:
        // tips: 可能是隐患，需要确认
          if (_navigationIndex != 1) {
            setState(() => _navigationIndex = 1);
          }
      }
    });
  }

  @override
  void dispose() {
    _mapSheetSubscription?.close();
    super.dispose();
  }

  void _handleDestinationSelected(int index) {
    if (_navigationIndex != index) {
      setState(() => _navigationIndex = index);
      // 添加触感反馈
      HapticFeedback.lightImpact();
    }

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

  // ✅ 关注 Overlay 类型/阶段
  final mapSheetType  = ref.watch(mapOverlaySheetProvider);
  // 如果你已经在项目里用了 stage，可一起判断；没有就删掉下一行和相关逻辑
  final mapSheetStage = ref.watch(mapOverlaySheetStageProvider);

  // ✅ 出现创建行程时强制隐藏；其它 Sheet 只在完全展开时隐藏（阶段一、二显示，阶段三隐藏）
  final hideForCreate = mapSheetType == MapOverlaySheetType.createRoadTrip;
  final hideForOthers = mapSheetType != MapOverlaySheetType.none &&
    mapSheetStage == MapOverlaySheetStage.expanded;

      
    final baseVisible = widget.show && ref.watch(bottomNavigationVisibilityProvider);
  final showBottomNav = baseVisible && !hideForCreate && !hideForOthers; // 👈 关键

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
                      selectedIndex: _navigationIndex,
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
