import 'dart:async';
import 'dart:math' as math;

import 'package:crew_app/app/router/app_router.dart';
import 'package:crew_app/app/state/app_overlay_provider.dart';
import 'package:crew_app/app/state/bottom_navigation_visibility_provider.dart';
import 'package:crew_app/features/events/presentation/pages/map/sheets/map_explore_sheet.dart';
import 'package:crew_app/features/events/presentation/pages/trips/sheets/create_road_trip_sheet.dart';
import 'package:crew_app/features/events/presentation/pages/trips/data/road_trip_editor_models.dart';
import 'package:crew_app/features/events/presentation/pages/moment/sheets/create_content_options_sheet.dart';
import 'package:crew_app/features/messages/presentation/messages_chat/chat_sheet.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:crew_app/shared/widgets/app_floating_action_button.dart';
import 'package:crew_app/shared/widgets/toggle_tab_bar.dart';
import 'package:crew_app/app/view/app_drawer.dart';

import '../../../data/event.dart';
import 'package:crew_app/features/events/state/events_providers.dart';
import 'widgets/search_event_appbar.dart';
import 'widgets/map_canvas.dart';
import 'widgets/markers_layer.dart';
import 'widgets/events_map_event_carousel.dart';
import 'widgets/breathing_marker_overlay.dart';
import 'widgets/expandable_filter_button.dart';
import 'state/events_map_search_controller.dart';
import 'state/map_selection_controller.dart';
import 'controllers/map_controller.dart';
import 'controllers/event_carousel_manager.dart';
import 'controllers/search_manager.dart';
import 'controllers/location_selection_manager.dart';
import 'state/map_overlay_sheet_provider.dart';
import 'state/map_overlay_sheet_stage_provider.dart';

class EventsMapPage extends ConsumerStatefulWidget {
  final Event? selectedEvent;
  const EventsMapPage({super.key, this.selectedEvent});

  @override
  ConsumerState<EventsMapPage> createState() => _EventsMapPageState();
}

class _EventsMapPageState extends ConsumerState<EventsMapPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  ProviderSubscription<Event?>? _mapFocusSubscription;
  ProviderSubscription<EventCarouselManager>? _carouselSubscription;
  bool _isDrawerOpen = false;
  final ClusterManagerId _eventsClusterManagerId = const ClusterManagerId(
    'events_cluster_manager',
  );
  late final ClusterManager _eventsClusterManager;
  CameraPosition? _currentCameraPosition;
  CameraPosition? _lastNotifiedCameraPosition;
  
  // 缓存 markers 和 polylines，避免重复创建
  Set<Marker>? _cachedMarkers;
  Set<Polyline>? _cachedPolylines;
  MapSelectionState? _lastSelectionState;
  List<Event>? _lastEventsList;
  
  // 保存 bottom navigation visibility 的 notifier，以便在 dispose 时安全使用
  StateController<bool>? _bottomNavigationVisibilityController;

  @override
  void initState() {
    super.initState();
    _eventsClusterManager = ClusterManager(
      clusterManagerId: _eventsClusterManagerId,
      onClusterTap: (cluster) {
        final controller = ref.read(mapControllerProvider);
        unawaited(controller.moveCamera(cluster.position, zoom: 14));
      },
    );
    _mapFocusSubscription = ref.listenManual(mapFocusEventProvider, (
      previous,
      next,
    ) {
      final event = next;
      if (event == null) {
        return;
      }
      final mapController = ref.read(mapControllerProvider);
      mapController.focusOnEvent(event);
      final carouselManager = ref.read(eventCarouselManagerProvider);
      carouselManager.showEventCard(event);
      // 延迟修改 provider，避免在 widget 构建期间修改
      Future.microtask(() {
        if (mounted) {
          ref.read(mapFocusEventProvider.notifier).state = null;
        }
      });
    });
    _carouselSubscription = ref.listenManual(eventCarouselManagerProvider, (
      _,
      manager,
    ) {
      if (!mounted) {
        return;
      }
      _updateBottomNavigation(!_isDrawerOpen && !manager.isVisible);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _updateBottomNavigation(true);
    });
  }

  @override
  void dispose() {
    _mapFocusSubscription?.close();
    _carouselSubscription?.close();
    // 注意：不能在 dispose 中修改 provider，这违反了 Riverpod 的规则
    // Widget 销毁时，provider 状态会自动处理，无需手动清理
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final safeBottom = MediaQuery.of(context).viewPadding.bottom;

    // 获取各个管理器
    final mapController = ref.watch(mapControllerProvider);
    final carouselManager = ref.watch(eventCarouselManagerProvider);
    final searchManager = ref.watch(searchManagerProvider);
    final locationSelectionManager = ref.watch(
      locationSelectionManagerProvider,
    );
    final mapSheetType = ref.watch(mapOverlaySheetProvider);
    final mapSheetStage = ref.watch(mapOverlaySheetStageProvider);
    final mapSheetSize = ref.watch(mapOverlaySheetSizeProvider);
    final showBottomNavigation = ref.watch(bottomNavigationVisibilityProvider);

    if (mapSheetType == MapOverlaySheetType.none &&
        mapSheetStage != MapOverlaySheetStage.collapsed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        final notifier = ref.read(mapOverlaySheetStageProvider.notifier);
        if (notifier.state != MapOverlaySheetStage.collapsed) {
          notifier.state = MapOverlaySheetStage.collapsed;
        }
        // 重置 sheet size
        ref.read(mapOverlaySheetSizeProvider.notifier).state = 0.0;
      });
    }
    
    // 当 sheet 类型变为 none 时，重置 sheet size
    if (mapSheetType == MapOverlaySheetType.none && mapSheetSize > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        ref.read(mapOverlaySheetSizeProvider.notifier).state = 0.0;
      });
    }

    final cardVisible =
        carouselManager.isVisible && carouselManager.events.isNotEmpty;
    final bottomPadding = (cardVisible ? 240 : 120) + safeBottom;
    final searchState = ref.watch(eventsMapSearchControllerProvider);
    final loc = AppLocalizations.of(context)!;

    final events = ref.watch(eventsProvider);
    final startCenter = mapController.getInitialCenter();
    final selectionState = ref.watch(mapSelectionControllerProvider);

    // 构建 markers 和 polylines
    // 使用缓存策略：只在选择状态或事件列表变化时重新创建
    final currentEventsList = events.hasValue ? events.value : null;
    final shouldRebuildMarkers = _lastSelectionState != selectionState ||
        _lastEventsList != currentEventsList;
    
    if (shouldRebuildMarkers || _cachedMarkers == null) {
      _lastSelectionState = selectionState;
      _lastEventsList = currentEventsList;
      _cachedMarkers = _buildMarkers(
        events,
        selectionState,
        mapController,
        carouselManager,
        locationSelectionManager,
      );
      _cachedPolylines = _buildPolylines(selectionState);
    }
    
    final markers = _cachedMarkers!;
    final polylines = _cachedPolylines!;
    
    final shouldHideEventMarkers =
        selectionState.selectedLatLng != null ||
        selectionState.isSelectingDestination;
    final clusterManagers = <ClusterManager>{
      if (!shouldHideEventMarkers) _eventsClusterManager,
    };

    // 页面首帧跳转至选中事件
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.selectedEvent != null && !mapController.movedToSelected) {
        mapController.focusOnEvent(widget.selectedEvent!);
        carouselManager.showEventCard(widget.selectedEvent!);
      }
    });

    // 当创建路线 sheet 打开时，只在起始页（选择起点/终点）和途径点页（添加途径点）显示信息横幅
    final isCreatingRoadTrip = mapSheetType == MapOverlaySheetType.createRoadTrip;
    // 判断是否在显示提示词的页面：
    // - 起始页：选择起点或终点（selectedLatLng 或 destinationLatLng 相关状态）
    // - 途径点页：添加途径点（isAddingWaypoint）
    final shouldShowGuide = isCreatingRoadTrip && (
      selectionState.selectedLatLng == null || // 选择起点
      selectionState.isSelectingDestination || // 选择终点
      selectionState.destinationLatLng == null || // 需要选择终点
      selectionState.isAddingWaypoint // 添加途径点
    );
    final hideSearchBar =
        shouldShowGuide ||
        selectionState.isSelectionSheetOpen ||
        selectionState.isSelectingDestination ||
        selectionState.isAddingWaypoint ||
        selectionState.selectedLatLng != null;
    final showClearSelectionInAppBar =
        !hideSearchBar && selectionState.selectedLatLng != null;

    if (hideSearchBar &&
        (searchManager.searchFocusNode.hasFocus || searchState.showResults)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        final manager = ref.read(searchManagerProvider);
        if (manager.searchFocusNode.hasFocus) {
          manager.searchFocusNode.unfocus();
        }
        ref.read(eventsMapSearchControllerProvider.notifier).hideResults();
      });
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      key: _scaffoldKey,
      drawer: AppDrawer(onClose: () => Navigator.of(context).pop()),
      onDrawerChanged: (isOpened) {
        _isDrawerOpen = isOpened;
        _updateBottomNavigation(!isOpened && !carouselManager.isVisible);
      },
      appBar: hideSearchBar
          ? null
          : _SlidingAppBar(
              hidden:
                  !showBottomNavigation ||
                  (mapSheetType != MapOverlaySheetType.none &&
                      mapSheetStage == MapOverlaySheetStage.expanded),
              child: SearchEventAppBar(
                controller: searchManager.searchController,
                focusNode: searchManager.searchFocusNode,
                onSearch: searchManager.onSearchSubmitted,
                onChanged: searchManager.onQueryChanged,
                onClear: searchManager.clearSearch,
                onQuickActionsTap: _openQuickActionsDrawer,
                onAvatarTap: _onAvatarTap,
                onResultTap: (event) =>
                    searchManager.onSearchResultTap(event, context),
                showResults: searchState.showResults,
                isLoading: searchState.isLoading,
                results: searchState.results,
                errorText: searchState.errorText,
                showClearSelectionAction: showClearSelectionInAppBar,
                onClearSelection: showClearSelectionInAppBar
                    ? () => unawaited(
                        locationSelectionManager.clearSelectedLocation(),
                      )
                    : null,
              ),
            ),
      body: Stack(
        children: [
          Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: (_) => searchManager.onOutsideTap(),
            child: RepaintBoundary(
              child: MapCanvas(
                initialCenter: startCenter,
                onMapCreated: mapController.onMapCreated,
                onMapReady: () {
                  mapController.onMapReady();
                  // 设置初始相机位置
                  if (_currentCameraPosition == null) {
                    setState(() {
                      _currentCameraPosition = CameraPosition(
                        target: startCenter,
                        zoom: 5,
                      );
                    });
                  }
                },
                onCameraMove: (position) {
                  // 只更新相机位置，不触发 setState
                  // 这样可以避免每次相机移动时重建整个 widget 树
                  _currentCameraPosition = position;
                  // 只在需要更新 BreathingMarkerOverlay 时才通知
                  // 使用节流：只在相机位置变化超过阈值时才更新
                  if (_lastNotifiedCameraPosition == null ||
                      _shouldUpdateCameraPosition(position, _lastNotifiedCameraPosition!)) {
                    _lastNotifiedCameraPosition = position;
                    // 使用 SchedulerBinding 来延迟更新，避免阻塞手势
                    // 只在需要更新 BreathingMarkerOverlay 时才触发 setState
                    if (mounted) {
                      setState(() {
                        // 只更新需要相机位置的 widget
                      });
                    }
                  }
                },
                onTap: (pos) {
                  carouselManager.hideEventCard();
                  unawaited(locationSelectionManager.onMapTap(pos, context));
                },
                onLongPress: (pos) {
                  carouselManager.hideEventCard();
                  unawaited(
                    locationSelectionManager.onMapLongPress(pos, context),
                  );
                },
                markers: markers,
                clusterManagers: clusterManagers,
                polylines: polylines,
                showUserLocation: false,
                mapPadding: selectionState.mapPadding,
              ),
            ),
          ), // Listener 结束
          // 使用 RepaintBoundary 隔离事件轮播，避免地图移动时重绘
          RepaintBoundary(
            child: EventsMapEventCarousel(
              events: carouselManager.events,
              visible:
                  carouselManager.isVisible && carouselManager.events.isNotEmpty,
              controller: carouselManager.pageController,
              safeBottom: safeBottom,
              onPageChanged: carouselManager.onPageChanged,
              onOpenDetails: (event) =>
                  carouselManager.openEventDetails(event, context),
              onClose: carouselManager.hideEventCard,
              onRegister: () => _showSnackBar(loc.registration_not_implemented),
              onFavorite: () => _showSnackBar(loc.feature_not_ready),
            ),
          ),
          // 呼吸动画覆盖层
          // 使用 RepaintBoundary 隔离，只在需要时重绘
          RepaintBoundary(
            child: BreathingMarkerOverlay(
              draggingPosition: selectionState.draggingMarkerPosition,
              draggingType: selectionState.draggingMarkerType,
              cameraPosition: _currentCameraPosition,
            ),
          ),
          // 可展开的分享按钮（自适应位置：搜索框下方或顶部）
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            top: (hideSearchBar || 
                  (mapSheetType != MapOverlaySheetType.none && 
                   mapSheetStage == MapOverlaySheetStage.expanded))
                // 搜索框消失时，移动到搜索框原本的位置（顶部安全区域 + 搜索框顶部 padding）
                ? MediaQuery.of(context).padding.top + 12.0
                // 搜索框显示时，在搜索框下方
                : MediaQuery.of(context).padding.top + 
                    (showClearSelectionInAppBar ? 112.0 : 68.0) + 
                    (searchState.showResults 
                        ? (searchState.isLoading 
                            ? 92.0 
                            : (searchState.errorText != null || searchState.results.isEmpty 
                                ? 84.0 
                                : ((searchState.results.length > 4 ? 4 : searchState.results.length) * 56.0 + 
                                   ((searchState.results.length > 4 ? 4 : searchState.results.length) > 1 
                                    ? ((searchState.results.length > 4 ? 4 : searchState.results.length) - 1) * 1.0 
                                    : 0.0) + 20.0)))
                        : 0.0) + 
                    8.0,
            left: 12,
            right: 12,
            child: RepaintBoundary(
              child: const ExpandableFilterButton(),
            ),
          ),
          // 使用 RepaintBoundary 隔离提示横幅，避免地图移动时重绘
          if (hideSearchBar)
            RepaintBoundary(
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.25),
                            Colors.black.withValues(alpha: 0.15),
                            Colors.black.withValues(alpha: 0.05),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.5, 0.8, 1.0],
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.white.withValues(alpha: 0.85),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _getGuideText(
                                  loc,
                                  selectionState,
                                  mapSheetType == MapOverlaySheetType.createRoadTrip,
                                ),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            // 只在设置起点、终点的时候显示清除选点按钮（起始页）
                            if (_shouldShowClearButton(selectionState, isCreatingRoadTrip)) ...[
                              const SizedBox(width: 12),
                              TextButton(
                                onPressed: () {
                                  if (selectionState.isAddingWaypoint) {
                                    // 在途经点阶段，只清除途经点选择状态，保留起点和终点
                                    locationSelectionManager.clearWaypointSelection();
                                  } else {
                                    // 其他阶段，清除所有选择
                                    unawaited(
                                      locationSelectionManager.clearSelectedLocation(),
                                    );
                                  }
                                },
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  selectionState.isAddingWaypoint
                                      ? loc.map_clear_waypoint
                                      : loc.map_clear_selected_point,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.85),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (mapSheetType != MapOverlaySheetType.none)
            _MapOverlaySheet(sheetType: mapSheetType),
          // 自适应悬浮按钮
          _AdaptiveFloatingButtons(
            mapSheetType: mapSheetType,
            mapSheetStage: mapSheetStage,
            mapSheetSize: mapSheetSize,
            bottomPadding: bottomPadding,
            safeBottom: safeBottom,
            onAddPressed: () => showCreateContentOptionsSheet(context),
            onLocationPressed: () async {
              await mapController.moveToMyLocation();
            },
          ),
        ],
      ),
    );
  }

  void _openQuickActionsDrawer() {
    final searchManager = ref.read(searchManagerProvider);
    if (searchManager.searchFocusNode.hasFocus) {
      searchManager.searchFocusNode.unfocus();
    }
    final searchController = ref.read(
      eventsMapSearchControllerProvider.notifier,
    );
    searchController.hideResults();
    _scaffoldKey.currentState?.openDrawer();
  }

  void _updateBottomNavigation(bool visible) {
    // 缓存 notifier 引用，避免重复调用 ref.read
    _bottomNavigationVisibilityController ??= ref.read(bottomNavigationVisibilityProvider.notifier);
    final controller = _bottomNavigationVisibilityController!;
    if (controller.state != visible) {
      controller.state = visible;
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  /// 根据当前步骤和是否在创建路线流程中返回相应的引导文字
  String _getGuideText(
    AppLocalizations loc,
    MapSelectionState selectionState,
    bool isCreatingRoadTrip,
  ) {
    // 如果在创建路线流程中，根据状态显示引导文字
    if (isCreatingRoadTrip) {
      // 途径点页：添加途径点
      if (selectionState.isAddingWaypoint) {
        // 点击了按钮后：在列表中管理途径点
        return loc.map_guide_waypoint_manage;
      }
      
      // 起始页：选择起点和终点
      if (selectionState.isSelectingDestination) {
        // 步骤 2：选择终点
        return loc.map_guide_step_2;
      } else if (selectionState.selectedLatLng == null) {
        // 步骤 1：选择起点（带 Step 说明）
        return loc.map_guide_step_1;
      } else if (selectionState.destinationLatLng == null) {
        // 已有起点，但终点为空，显示步骤 2
        return loc.map_guide_step_2;
      } else {
        // 起点和终点都已选择，显示途径点页的引导（步骤 3）
        return loc.map_guide_waypoint_step_3;
      }
    }
    
    // 不在创建路线流程中，显示原有的引导文字
    if (selectionState.isAddingWaypoint) {
      return loc.map_add_waypoint_tip;
    } else if (selectionState.isSelectingDestination) {
      return loc.map_select_location_destination_tip;
    } else {
      return loc.map_select_location_tip;
    }
  }

  /// 判断是否应该显示清除选点按钮
  /// 只在起始页（选择起点/终点）设置 marker 的时候显示，途径点页不显示
  bool _shouldShowClearButton(MapSelectionState selectionState, bool isCreatingRoadTrip) {
    // 在创建路线流程中，只在起始页（选择起点/终点）时显示清除按钮，途径点页不显示
    if (isCreatingRoadTrip && selectionState.isAddingWaypoint) {
      return false;
    }
    // 只在设置 marker 时显示：
    // 1. 正在选择起点（selectedLatLng != null 且不在选择终点模式）
    // 2. 正在选择终点（isSelectingDestination 或 destinationLatLng != null）
    return (selectionState.selectedLatLng != null && !selectionState.isSelectingDestination) ||
        selectionState.isSelectingDestination ||
        selectionState.destinationLatLng != null;
  }

  void _onAvatarTap(bool authed) {
    final searchManager = ref.read(searchManagerProvider);
    if (searchManager.searchFocusNode.hasFocus) {
      searchManager.searchFocusNode.unfocus();
    }
    ref.read(eventsMapSearchControllerProvider.notifier).hideResults();
    if (!authed) {
      if (!mounted) {
        return;
      }
      context.push(AppRoutePaths.login);
      return;
    }
    ref.read(appOverlayIndexProvider.notifier).state = 1;
  }

  // 判断是否需要更新相机位置（节流）
  // 只在相机位置变化超过阈值时才返回 true
  bool _shouldUpdateCameraPosition(
    CameraPosition current,
    CameraPosition last,
  ) {
    // 计算位置距离（米）
    final distance = _calculateDistance(
      current.target,
      last.target,
    );
    // 如果距离超过 10 米或缩放级别变化超过 0.5，则更新
    return distance > 10 || (current.zoom - last.zoom).abs() > 0.5;
  }

  // 计算两个经纬度之间的距离（米）
  double _calculateDistance(LatLng a, LatLng b) {
    const double earthRadius = 6371000; // 地球半径（米）
    final double dLat = (b.latitude - a.latitude) * math.pi / 180.0;
    final double dLon = (b.longitude - a.longitude) * math.pi / 180.0;
    final double a1 = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(a.latitude * math.pi / 180.0) *
            math.cos(b.latitude * math.pi / 180.0) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final double c = 2 * math.atan2(math.sqrt(a1), math.sqrt(1 - a1));
    return earthRadius * c;
  }

  // 构建 markers
  Set<Marker> _buildMarkers(
    AsyncValue<List<Event>> events,
    MapSelectionState selectionState,
    MapController mapController,
    EventCarouselManager carouselManager,
    LocationSelectionManager locationSelectionManager,
  ) {
    final markersLayer = events.when(
      loading: () => const MarkersLayer(markers: <Marker>{}),
      error: (_, _) => const MarkersLayer(markers: <Marker>{}),
      data: (list) => MarkersLayer.fromEvents(
        events: list,
        onEventTap: (event) {
          mapController.focusOnEvent(event);
          carouselManager.showEventCard(event);
        },
        clusterManagerId: _eventsClusterManagerId,
      ),
    );

    final shouldHideEventMarkers =
        selectionState.selectedLatLng != null ||
        selectionState.isSelectingDestination;
    final markers = <Marker>{
      if (!shouldHideEventMarkers) ...markersLayer.markers,
    };
    
    final selected = selectionState.selectedLatLng;
    if (selected != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('selected_location'),
          position: selected,
          draggable: true,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
          onTap: () =>
              unawaited(locationSelectionManager.clearSelectedLocation()),
          onDrag: (pos) {
            final selectionController = ref.read(mapSelectionControllerProvider.notifier);
            selectionController.setDraggingMarker(pos, DraggingMarkerType.start);
            selectionController.setSelectedLatLng(pos);
          },
          onDragEnd: (pos) {
            final selectionController = ref.read(mapSelectionControllerProvider.notifier);
            selectionController.setSelectedLatLng(pos);
            selectionController.clearDraggingMarker();
            HapticFeedback.lightImpact();
          },
        ),
      );
    }

    final destination = selectionState.destinationLatLng;
    if (destination != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('destination_location'),
          position: destination,
          draggable: true,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
          onTap: () =>
              unawaited(locationSelectionManager.clearSelectedLocation()),
          onDrag: (pos) {
            final selectionController = ref.read(mapSelectionControllerProvider.notifier);
            selectionController.setDraggingMarker(pos, DraggingMarkerType.destination);
            selectionController.setDestinationLatLng(pos);
          },
          onDragEnd: (pos) {
            final selectionController = ref.read(mapSelectionControllerProvider.notifier);
            selectionController.setDestinationLatLng(pos);
            selectionController.clearDraggingMarker();
            HapticFeedback.lightImpact();
          },
        ),
      );
    }

    // 添加途经点 markers
    final forwardWaypoints = selectionState.forwardWaypoints;
    final returnWaypoints = selectionState.returnWaypoints;
    
    for (int i = 0; i < forwardWaypoints.length; i++) {
      markers.add(
        Marker(
          markerId: MarkerId('forward_waypoint_$i'),
          position: forwardWaypoints[i],
          draggable: true,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueYellow,
          ),
          onDrag: (pos) {
            final selectionController = ref.read(mapSelectionControllerProvider.notifier);
            selectionController.setDraggingMarker(pos, DraggingMarkerType.forwardWaypoint);
            final currentWaypoints = List<LatLng>.from(forwardWaypoints);
            currentWaypoints[i] = pos;
            selectionController.setForwardWaypoints(currentWaypoints);
          },
          onDragEnd: (pos) {
            final selectionController = ref.read(mapSelectionControllerProvider.notifier);
            final currentWaypoints = List<LatLng>.from(forwardWaypoints);
            currentWaypoints[i] = pos;
            selectionController.setForwardWaypoints(currentWaypoints);
            selectionController.clearDraggingMarker();
            HapticFeedback.lightImpact();
          },
        ),
      );
    }
    
    for (int i = 0; i < returnWaypoints.length; i++) {
      markers.add(
        Marker(
          markerId: MarkerId('return_waypoint_$i'),
          position: returnWaypoints[i],
          draggable: true,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueYellow,
          ),
          onDrag: (pos) {
            final selectionController = ref.read(mapSelectionControllerProvider.notifier);
            selectionController.setDraggingMarker(pos, DraggingMarkerType.returnWaypoint);
            final currentWaypoints = List<LatLng>.from(returnWaypoints);
            currentWaypoints[i] = pos;
            selectionController.setReturnWaypoints(currentWaypoints);
          },
          onDragEnd: (pos) {
            final selectionController = ref.read(mapSelectionControllerProvider.notifier);
            final currentWaypoints = List<LatLng>.from(returnWaypoints);
            currentWaypoints[i] = pos;
            selectionController.setReturnWaypoints(currentWaypoints);
            selectionController.clearDraggingMarker();
            HapticFeedback.lightImpact();
          },
        ),
      );
    }

    return markers;
  }

  // 构建 polylines
  Set<Polyline> _buildPolylines(MapSelectionState selectionState) {
    final polylines = <Polyline>{};
    final selected = selectionState.selectedLatLng;
    final destination = selectionState.destinationLatLng;
    
    if (selected != null && destination != null) {
      final routeType = selectionState.routeType;
      final forwardWaypoints = selectionState.forwardWaypoints;
      final returnWaypoints = selectionState.returnWaypoints;
      final points = <LatLng>[];
      
      // 起点
      points.add(selected);
      
      // 根据路线类型添加途经点和终点
      if (routeType == RoadTripRouteType.roundTrip) {
        // 往返路线：起点 -> 去程途经点 -> 终点 -> 返程途经点 -> 起点
        points.addAll(forwardWaypoints);
        points.add(destination);
        points.addAll(returnWaypoints.reversed);
        points.add(selected); // 回到起点
      } else {
        // 单程路线：起点 -> 去程途经点 -> 终点
        points.addAll(forwardWaypoints);
        points.add(destination);
      }
      
      if (points.length > 1) {
        polylines.add(
          Polyline(
            polylineId: const PolylineId('route_polyline'),
            points: points,
            color: Colors.blue,
            width: 4,
            geodesic: true,
          ),
        );
      }
    }

    return polylines;
  }
}

class _MapOverlaySheet extends ConsumerStatefulWidget {
  const _MapOverlaySheet({required this.sheetType});

  final MapOverlaySheetType sheetType;

  @override
  ConsumerState<_MapOverlaySheet> createState() => _MapOverlaySheetState();
}

class _SlidingAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _SlidingAppBar({required this.child, required this.hidden});

  final PreferredSizeWidget child;
  final bool hidden;

  @override
  Size get preferredSize => child.preferredSize;

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeInOut,
      offset: Offset(0, hidden ? -1.2 : 0),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        opacity: hidden ? 0 : 1,
        child: child,
      ),
    );
  }
}

class _MapOverlaySheetState extends ConsumerState<_MapOverlaySheet> {
  late final DraggableScrollableController _controller;
  double _currentSize = 0;
  int _chatTab = 0; // Chat sheet 的 tab 状态
  int _exploreTab = 0; // Explore sheet 的 tab 状态

 bool get _attached => _controller.isAttached;

  @override
  void initState() {
    super.initState();
    _controller = DraggableScrollableController()
      ..addListener(_handleSizeChanged);
    _currentSize = _initialSize;
    // 延迟到下一帧再更新状态，避免在 initState 中直接修改 provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _notifyStage(_currentSize);
      _notifySize(_currentSize);
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_handleSizeChanged);
    _controller.dispose();
    // 不在这里重置，因为主页面会在 sheet 类型变为 none 时重置
    // 这样可以避免在 dispose 生命周期中修改 provider 状态
    super.dispose();
  }

  void _handleSizeChanged() {
        if (!_attached || !mounted) return;  
    final size = _controller.size;
    if ((size - _currentSize).abs() < 1e-4 || !mounted) {
      return;
    }

    final schedulerPhase = SchedulerBinding.instance.schedulerPhase;
    if (schedulerPhase == SchedulerPhase.idle) {
      _notifyStage(size);
      _notifySize(size);
      setState(() => _currentSize = size);
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _notifyStage(size);
      _notifySize(size);
      setState(() => _currentSize = size);
    });
  }

  void _notifySize(double size) {
    final notifier = ref.read(mapOverlaySheetSizeProvider.notifier);
    if ((notifier.state - size).abs() < 1e-4) {
      return;
    }

    void updateSize() {
      if (!mounted) {
        return;
      }
      notifier.state = size;
    }

    final phase = SchedulerBinding.instance.schedulerPhase;
    if (phase == SchedulerPhase.idle ||
        phase == SchedulerPhase.postFrameCallbacks) {
      updateSize();
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => updateSize());
  }

  void _onDragUpdate(
    DragUpdateDetails details,
    double minSize,
    double maxSize,
    double height,
  ) {
        if (!_attached) return; 
    final delta = details.primaryDelta ?? 0;
    if (delta == 0) {
      return;
    }
    final proposed = (_controller.size - delta / height).clamp(
      minSize,
      maxSize,
    );
    if (proposed != _controller.size) {
      _controller.jumpTo(proposed);
    }
  }

  void _onDragEnd(DragEndDetails details, List<double> snapSizes) {
        if (!_attached) return; 
    final velocity = details.primaryVelocity ?? 0;
    final currentSize = _currentSize;
    final target = _targetSnapFor(currentSize, velocity, snapSizes);
    if ((target - currentSize).abs() < 0.001) {
      return;
    }
    _controller.animateTo(
      target,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }

  double _targetSnapFor(double size, double velocity, List<double> snapSizes) {
    if (velocity.abs() < 50) {
      return _nearestSnap(size, snapSizes);
    }
    if (velocity < 0) {
      for (final snap in snapSizes) {
        if (snap > size + 1e-4) {
          return snap;
        }
      }
      return snapSizes.last;
    }
    for (final snap in snapSizes.reversed) {
      if (snap < size - 1e-4) {
        return snap;
      }
    }
    return snapSizes.first;
  }

  double _nearestSnap(double size, List<double> snapSizes) {
    double closest = snapSizes.first;
    double distance = (size - closest).abs();
    for (final snap in snapSizes.skip(1)) {
      final d = (size - snap).abs();
      if (d < distance) {
        closest = snap;
        distance = d;
      }
    }
    return closest;
  }

  List<double> get _snapSizes {
    return switch (widget.sheetType) {
      MapOverlaySheetType.chat => const [0.2, 0.5, 0.88],
      MapOverlaySheetType.explore => const [0.2, 0.5, 0.88],
      MapOverlaySheetType.none => const [0.2, 0.5, 0.88],
      MapOverlaySheetType.createRoadTrip => const [0.2, 0.3, 0.88],
    };
  }
  
  bool get _shouldSnap => true;

  double get _initialSize {
    final snapSizes = _snapSizes;
    return switch (widget.sheetType) {
      MapOverlaySheetType.chat => snapSizes[1],
      MapOverlaySheetType.explore => snapSizes[1],
      MapOverlaySheetType.none => snapSizes.first,
      MapOverlaySheetType.createRoadTrip => snapSizes.length > 1 ? snapSizes[1] : snapSizes.first,
    };
  }

  @override
  void didUpdateWidget(covariant _MapOverlaySheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sheetType != widget.sheetType) {
      final newSize = _initialSize;
      setState(() => _currentSize = newSize);
      // 延迟到下一帧再更新状态，避免在 didUpdateWidget 中直接修改 provider
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        _notifyStage(newSize);
        _notifySize(newSize);
        DraggableScrollableActuator.reset(context);
      });
    }
  }

  void _notifyStage(double size) {
    final notifier = ref.read(mapOverlaySheetStageProvider.notifier);
    final newStage = _stageForSize(size);
    if (notifier.state == newStage) {
      return;
    }

    void updateStage() {
      if (!mounted) {
        return;
      }
      notifier.state = newStage;
    }

    final phase = SchedulerBinding.instance.schedulerPhase;
    if (phase == SchedulerPhase.idle ||
        phase == SchedulerPhase.postFrameCallbacks) {
      updateStage();
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => updateStage());
  }

  MapOverlaySheetStage _stageForSize(double size) {
    final snapSizes = _snapSizes;
    if (snapSizes.isEmpty) {
      return MapOverlaySheetStage.collapsed;
    }
    if (size >= snapSizes.last - 0.01) {
      return MapOverlaySheetStage.expanded;
    }
    if (snapSizes.length > 1 && size >= snapSizes[1] - 0.01) {
      return MapOverlaySheetStage.middle;
    }
    return MapOverlaySheetStage.collapsed;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final handleColor = colorScheme.onSurfaceVariant.withValues(alpha: 0.2);

    final snapSizes = _snapSizes;
    final initialSize = _initialSize;

    final mediaQuery = MediaQuery.of(context);
    final totalHeight = mediaQuery.size.height;
    final currentSize = _currentSize;
    final isExpanded = currentSize >= snapSizes.last - 0.01;
    final actionIcon = isExpanded
        ? Icons.keyboard_arrow_down_rounded
        : Icons.close;

    return Align(
      alignment: Alignment.bottomCenter,
      child: DraggableScrollableActuator(
        child: DraggableScrollableSheet(
          controller: _controller,
          expand: false,
          minChildSize: snapSizes.first,
          maxChildSize: snapSizes.last,
          initialChildSize: initialSize,
          snap: _shouldSnap,
          snapSizes: _shouldSnap ? snapSizes : null,
          builder: (context, scrollController) {
            final Widget effectiveContent;
            switch (widget.sheetType) {
              case MapOverlaySheetType.explore:
                effectiveContent = MapExploreSheet(
                  scrollController: scrollController,
                  selectedTab: _exploreTab,
                );
                break;
              case MapOverlaySheetType.chat:
                effectiveContent = ChatSheet(
                  scrollController: scrollController,
                  selectedTab: _chatTab,
                );
                break;
              case MapOverlaySheetType.none:
                effectiveContent = const SizedBox.shrink();
                break;
              case MapOverlaySheetType.createRoadTrip:
                effectiveContent = Consumer(
                  builder: (context, ref, _) {
                    final selectionController = ref.read(mapSelectionControllerProvider.notifier);
                    final selectionState = ref.read(mapSelectionControllerProvider);
                    
                    // 始终使用完整创建模式
                    const mode = CreateRoadTripMode.fullCreation;
                    
                    // 构建 initialRoute（如果有起点）
                    QuickRoadTripResult? initialRoute;
                    if (selectionState.selectedLatLng != null) {
                      initialRoute = QuickRoadTripResult(
                        title: '',
                        start: selectionState.selectedLatLng!,
                        destination: selectionState.destinationLatLng,
                        startAddress: null,
                        destinationAddress: null,
                        openDetailed: false,
                      );
                    }
                    
                    return CreateRoadTripSheet(
                      scrollController: scrollController,
                      mode: mode,
                      embeddedMode: true, // overlay 模式
                      initialRoute: initialRoute,
                      startPositionListenable: selectionController.selectedLatLngListenable,
                      destinationListenable: selectionController.destinationLatLngListenable,
                      onCancel: () {
                        final selectionController = ref.read(mapSelectionControllerProvider.notifier);
                        
                        // 立即清理所有选择状态（包括起点、终点、选择模式）
                        // 这会清除地图标记和顶部提示
                        // 必须按顺序清除：先清除选择模式，再清除位置，最后清除 sheet 状态
                        selectionController.setSelectingDestination(false);
                        selectionController.setSelectionSheetOpen(false);
                        selectionController.setSelectedLatLng(null); // 这会自动清除 destination
                        selectionController.resetMapPadding();
                        
                        // 关闭 overlay
                        ref.read(mapOverlaySheetProvider.notifier).state = MapOverlaySheetType.none;
                      },
                      onCreateQuickTrip: (result) async {
                        // 处理快速创建
                        final manager = ref.read(locationSelectionManagerProvider);
                        await manager.createQuickRoadTrip(result);
                        // 关闭 overlay
                        ref.read(mapOverlaySheetProvider.notifier).state = MapOverlaySheetType.none;
                        // 清理选择状态
                        ref.read(mapSelectionControllerProvider.notifier).resetSelection();
                      },
                      onOpenDetailed: () {
                        // 打开详细编辑器
                        ref.read(mapOverlaySheetProvider.notifier).state = MapOverlaySheetType.none;
                        // 清理选择状态，但保留位置信息用于详细编辑器
                        // ref.read(mapSelectionControllerProvider.notifier).resetSelection();
                      },
                    );
                  },
                );
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: Material(
                color: colorScheme.surface,
                elevation: 12,
                shadowColor: colorScheme.shadow.withValues(alpha: 0.18),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onVerticalDragUpdate: (details) => _onDragUpdate(
                        details,
                        snapSizes.first,
                        snapSizes.last,
                        totalHeight,
                      ),
                      onVerticalDragEnd: (details) =>
                          _onDragEnd(details, snapSizes),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 6, // 进一步减小头部垂直 padding
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 40,
                              height: 3, // 减小拖动手柄高度
                              decoration: BoxDecoration(
                                color: handleColor,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                visualDensity: VisualDensity.compact,
                                icon: Icon(actionIcon),
                                onPressed: () {
                                  if (isExpanded) {
                                    if (_attached && _controller.isAttached) {
                                      _controller.animateTo(
                                        snapSizes[snapSizes.length - 2],
                                        duration: const Duration(
                                          milliseconds: 220,
                                        ),
                                        curve: Curves.easeOutCubic,
                                      );
                                    }
                                    return;
                                  }
                                  // 关闭 overlay 时，如果是 CreateRoadTripSheet，需要清理状态
                                  if (widget.sheetType == MapOverlaySheetType.createRoadTrip) {
                                    final selectionController = ref
                                        .read(mapSelectionControllerProvider.notifier);
                                    
                                    // 立即清理所有选择状态（包括起点、终点、选择模式）
                                    // 这会清除地图标记和顶部提示
                                    selectionController.setSelectingDestination(false);
                                    selectionController.setSelectionSheetOpen(false);
                                    selectionController.setSelectedLatLng(null); // 这会自动清除 destination
                                    selectionController.resetMapPadding();
                                  }
                                  ref
                                      .read(mapOverlaySheetProvider.notifier)
                                      .state = MapOverlaySheetType
                                      .none;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // 为使用 ToggleTabBar 的 sheet 类型添加 ToggleTabBar（在分割线上方）
                    Consumer(
                      builder: (context, ref, _) {
                        final loc = AppLocalizations.of(context)!;
                        if (widget.sheetType == MapOverlaySheetType.chat) {
                          return ToggleTabBar(
                            selectedIndex: _chatTab,
                            firstLabel: loc.messages_tab_private,
                            secondLabel: loc.messages_tab_groups,
                            onChanged: (value) {
                              setState(() => _chatTab = value);
                            },
                          );
                        } else if (widget.sheetType == MapOverlaySheetType.explore) {
                          return ToggleTabBar(
                            selectedIndex: _exploreTab,
                            firstLabel: loc.events_tab_invites,
                            secondLabel: loc.events_tab_moments,
                            onChanged: (value) {
                              setState(() => _exploreTab = value);
                            },
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    const Divider(height: 1),
                    Expanded(child: effectiveContent),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AdaptiveFloatingButtons extends StatelessWidget {
  const _AdaptiveFloatingButtons({
    required this.mapSheetType,
    required this.mapSheetStage,
    required this.mapSheetSize,
    required this.bottomPadding,
    required this.safeBottom,
    required this.onAddPressed,
    required this.onLocationPressed,
  });

  final MapOverlaySheetType mapSheetType;
  final MapOverlaySheetStage mapSheetStage;
  final double mapSheetSize;
  final double bottomPadding;
  final double safeBottom;
  final VoidCallback onAddPressed;
  final VoidCallback onLocationPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    
    // 计算按钮的底部偏移
    double bottomOffset;
    double opacity;
    
    if (mapSheetType != MapOverlaySheetType.none) {
      if (mapSheetStage == MapOverlaySheetStage.collapsed) {
        // 阶段一（collapsed）：根据 sheet 高度平滑上移
        final sheetHeight = screenHeight * mapSheetSize;
        // 按钮需要上移到 sheet 上方，加上一些间距
        bottomOffset = sheetHeight + 16 + safeBottom;
        opacity = 1.0;
      } else {
        // 其他阶段（middle, expanded）：直接隐藏
        bottomOffset = bottomPadding;
        opacity = 0.0;
      }
    } else {
      // 没有 sheet，使用默认位置
      bottomOffset = bottomPadding;
      opacity = 1.0;
    }

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      right: 16,
      bottom: bottomOffset,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: opacity,
        child: IgnorePointer(
          ignoring: opacity == 0.0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AppFloatingActionButton(
                heroTag: 'events_map_add_fab',
                backgroundColor: theme.colorScheme.secondary,
                foregroundColor: theme.colorScheme.onSecondary,
                onPressed: onAddPressed,
                child: const Icon(Icons.add),
              ),
              AppFloatingActionButton(
                heroTag: 'events_map_my_location_fab',
                margin: const EdgeInsets.only(top: 8, right: 0),
                onPressed: onLocationPressed,
                child: const Icon(Icons.my_location),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
