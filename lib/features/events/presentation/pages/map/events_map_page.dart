import 'dart:async';

import 'package:crew_app/app/router/app_router.dart';
import 'package:crew_app/app/state/app_overlay_provider.dart';
import 'package:crew_app/app/state/bottom_navigation_visibility_provider.dart';
import 'package:crew_app/features/events/presentation/pages/map/sheets/map_explore_sheet.dart';
import 'package:crew_app/features/events/presentation/pages/trips/sheets/create_road_trip_sheet.dart';
import 'package:crew_app/features/events/presentation/pages/city_events/sheets/create_city_event_sheet.dart';
import 'package:crew_app/features/events/presentation/pages/moment/sheets/create_content_options_sheet.dart';
import 'package:crew_app/features/messages/presentation/messages_chat/chat_sheet.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:crew_app/shared/widgets/map_floating_action_buttons.dart';
import 'package:crew_app/shared/widgets/toggle_tab_bar.dart';
import 'package:crew_app/app/view/app_drawer.dart';

import '../../../data/event.dart';
import 'package:crew_app/features/events/state/events_providers.dart';
import 'widgets/search_event_appbar.dart';
import 'widgets/map_canvas.dart';
import 'widgets/events_map_event_carousel.dart';
import 'widgets/breathing_marker_overlay.dart';
import 'widgets/expandable_filter_button.dart';
import 'widgets/map_marker_builder.dart';
import 'widgets/map_polyline_builder.dart';
import 'utils/camera_move_optimizer.dart';
import 'state/events_map_search_controller.dart';
import 'state/map_selection_controller.dart';
import 'controllers/map_controller.dart';
import 'controllers/event_carousel_manager.dart';
import 'controllers/search_manager.dart';
import 'controllers/location_selection_manager.dart';
import 'package:crew_app/features/events/presentation/widgets/common/screens/location_search_screen.dart';
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
  late final MapMarkerBuilder _markerBuilder;
  late final CameraMoveOptimizer _cameraOptimizer;
  CameraPosition? _currentCameraPosition;
  bool _showCompass = false;
  
  // 缓存 markers 和 polylines，避免重复创建
  Set<Marker>? _cachedMarkers;
  Set<Polyline>? _cachedPolylines;
  MapSelectionState? _lastSelectionState;
  List<Event>? _lastEventsList;
  
  // 保存 bottom navigation visibility 的 notifier，以便在 dispose 时安全使用
  StateController<bool>? _bottomNavigationVisibilityController;
  
  // CreateRoadTrip sheet 是否显示 ToggleTabBar（用于控制添加途径点按钮的显示）
  bool _roadTripCanSwipe = false;

  @override
  void initState() {
    super.initState();
    final mapController = ref.read(mapControllerProvider);
    _eventsClusterManager = ClusterManager(
      clusterManagerId: _eventsClusterManagerId,
      onClusterTap: (cluster) {
        unawaited(mapController.moveCamera(cluster.position, zoom: 14));
      },
    );
    _markerBuilder = MapMarkerBuilder(
      ref: ref,
      eventsClusterManagerId: _eventsClusterManagerId,
    );
    _cameraOptimizer = CameraMoveOptimizer(mapController: mapController);
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
    _cameraOptimizer.dispose();
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

    // 统一处理 sheet 状态重置
    if (mapSheetType == MapOverlaySheetType.none) {
      if (mapSheetStage != MapOverlaySheetStage.collapsed || mapSheetSize > 0) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          if (mapSheetStage != MapOverlaySheetStage.collapsed) {
            ref.read(mapOverlaySheetStageProvider.notifier).state = MapOverlaySheetStage.collapsed;
          }
          if (mapSheetSize > 0) {
            ref.read(mapOverlaySheetSizeProvider.notifier).state = 0.0;
          }
        });
      }
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
      _cachedMarkers = _markerBuilder.buildMarkers(
        events: events,
        selectionState: selectionState,
        mapController: mapController,
        carouselManager: carouselManager,
        locationSelectionManager: locationSelectionManager,
      );
      _cachedPolylines = MapPolylineBuilder.buildPolylines(selectionState);
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
                  // 使用优化器处理相机移动，减少不必要的更新
                  _currentCameraPosition = position;
                  
                  final shouldUpdate = _cameraOptimizer.handleCameraMove(position);
                  
                  // 如果有选中的标记点（呼吸效果），需要及时更新相机位置
                  final selectionState = ref.read(mapSelectionControllerProvider);
                  final hasSelectedMarker = selectionState.draggingMarkerPosition != null;
                  
                  if (shouldUpdate && mounted) {
                    // 检查指南针状态
                    final shouldShowCompass = _cameraOptimizer.shouldShowCompass(position);
                    if (shouldShowCompass != _showCompass) {
                      setState(() {
                        _showCompass = shouldShowCompass;
                      });
                    } else if (hasSelectedMarker) {
                      // 即使不需要更新指南针，如果有选中的标记点，也需要更新以刷新呼吸效果位置
                      setState(() {});
                    }
                  } else if (hasSelectedMarker && mounted) {
                    // 即使优化器认为不需要更新，如果有选中的标记点，也要更新
                    setState(() {});
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
                showUserLocation: true,
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
          // 呼吸动画覆盖层（用于显示选中标记点的呼吸效果）
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
                  !showBottomNavigation ||
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
                    12.0,
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
            _MapOverlaySheet(
              sheetType: mapSheetType,
              onRoadTripCanSwipeChanged: (canSwipe) {
                setState(() {
                  _roadTripCanSwipe = canSwipe;
                });
              },
            ),
          // 通用多功能悬浮按钮
          MapFloatingActionButtons(
            mapSheetType: mapSheetType,
            mapSheetStage: mapSheetStage,
            mapSheetSize: mapSheetSize,
            bottomPadding: bottomPadding,
            safeBottom: safeBottom,
            startLatLng: selectionState.selectedLatLng,
            destinationLatLng: selectionState.destinationLatLng,
            canSwipe: _roadTripCanSwipe,
            showCompass: _showCompass,
            onAddWaypoint: () {
              final selectionController = ref.read(mapSelectionControllerProvider.notifier);
              selectionController.setAddingWaypoint(true);
            },
            onAddPressed: () => showCreateContentOptionsSheet(context),
            onEdit: () => _onEditSelectedMarker(context, selectionState),
            onLocationPressed: () async {
              if (_showCompass) {
                // 回正地图
                if (_currentCameraPosition != null) {
                  await mapController.resetBearing(
                    currentZoom: _currentCameraPosition!.zoom,
                    currentTilt: _currentCameraPosition!.tilt,
                  );
                }
              } else {
                // 移动到我的位置
                await mapController.moveToMyLocation();
              }
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

  /// 处理编辑选中标记点的功能
  Future<void> _onEditSelectedMarker(
    BuildContext context,
    MapSelectionState selectionState,
  ) async {
    // 检查是否有选中的标记点
    if (selectionState.draggingMarkerPosition == null ||
        selectionState.draggingMarkerType == null) {
      _showSnackBar('请先选择一个标记点');
      return;
    }

    final selectedPosition = selectionState.draggingMarkerPosition!;
    final markerType = selectionState.draggingMarkerType!;
    final loc = AppLocalizations.of(context)!;
    final locationManager = ref.read(locationSelectionManagerProvider);

    // 根据标记点类型获取地址信息
    String? address;
    switch (markerType) {
      case DraggingMarkerType.start:
        // 起点：尝试从 CreateRoadTripSheet 获取地址，如果没有则使用反向地理编码
        // 这里先使用反向地理编码
        address = await locationManager.reverseGeocode(selectedPosition);
        break;
      case DraggingMarkerType.destination:
        // 终点：尝试从 CreateRoadTripSheet 获取地址，如果没有则使用反向地理编码
        address = await locationManager.reverseGeocode(selectedPosition);
        break;
      case DraggingMarkerType.forwardWaypoint:
      case DraggingMarkerType.returnWaypoint:
        // 途经点：使用反向地理编码获取地址
        address = await locationManager.reverseGeocode(selectedPosition);
        break;
    }

    // 跳转到 LocationSearchScreen（编辑模式）
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LocationSearchScreen(
          title: loc.map_select_location_title,
          initialQuery: address,
          initialLocation: selectedPosition,
          isRoundTrip: false, // 编辑模式下不需要往返模式的下拉菜单
          isEditMode: true, // 标记为编辑模式
          onLocationSelected: (newPlace) {
            // 处理位置更新
            final newLocation = newPlace.location;
            if (newLocation == null) return;

            final selectionController = ref.read(mapSelectionControllerProvider.notifier);

            // 根据标记点类型更新对应的位置
            switch (markerType) {
              case DraggingMarkerType.start:
                selectionController.setSelectedLatLng(newLocation);
                break;
              case DraggingMarkerType.destination:
                selectionController.setDestinationLatLng(newLocation);
                break;
              case DraggingMarkerType.forwardWaypoint:
                // 找到并更新对应的去程途经点
                final forwardWps = List<LatLng>.from(selectionState.forwardWaypoints);
                final index = forwardWps.indexWhere(
                  (wp) => wp.latitude == selectedPosition.latitude &&
                      wp.longitude == selectedPosition.longitude,
                );
                if (index >= 0) {
                  forwardWps[index] = newLocation;
                  selectionController.setForwardWaypoints(forwardWps);
                }
                break;
              case DraggingMarkerType.returnWaypoint:
                // 找到并更新对应的返程途经点
                final returnWps = List<LatLng>.from(selectionState.returnWaypoints);
                final index = returnWps.indexWhere(
                  (wp) => wp.latitude == selectedPosition.latitude &&
                      wp.longitude == selectedPosition.longitude,
                );
                if (index >= 0) {
                  returnWps[index] = newLocation;
                  selectionController.setReturnWaypoints(returnWps);
                }
                break;
            }

            // 清除选中的标记点（停止呼吸效果）
            selectionController.clearDraggingMarker();
          },
        ),
      ),
    );
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

}

class _MapOverlaySheet extends ConsumerStatefulWidget {
  const _MapOverlaySheet({
    required this.sheetType,
    this.onRoadTripCanSwipeChanged,
  });

  final MapOverlaySheetType sheetType;
  final ValueChanged<bool>? onRoadTripCanSwipeChanged;

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
  bool _roadTripCanSwipe = false; // CreateRoadTrip sheet 是否显示 ToggleTabBar
  int _roadTripTab = 0; // CreateRoadTrip sheet 的 tab 状态（路线/途径点）
  ValueNotifier<int>? _roadTripTabChangeNotifier; // CreateRoadTrip sheet 的 tab 切换请求

 bool get _attached => _controller.isAttached;

  @override
  void initState() {
    super.initState();
    _controller = DraggableScrollableController()
      ..addListener(_handleSizeChanged);
    _currentSize = _initialSize;
    // 延迟到下一帧再更新状态，避免在 initState 中直接修改 provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _notifyStateChanges(_currentSize);
      }
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
    if ((size - _currentSize).abs() < 1e-4) {
      return;
    }

    _currentSize = size;
    _notifyStateChanges(size);
  }

  /// 统一通知状态变化（stage 和 size）
  void _notifyStateChanges(double size) {
    void update() {
      if (!mounted) return;
      _notifyStage(size);
      _notifySize(size);
      setState(() {});
    }

    final phase = SchedulerBinding.instance.schedulerPhase;
    if (phase == SchedulerPhase.idle || phase == SchedulerPhase.postFrameCallbacks) {
      update();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => update());
    }
  }

  void _notifySize(double size) {
    final notifier = ref.read(mapOverlaySheetSizeProvider.notifier);
    if ((notifier.state - size).abs() < 1e-4) {
      return;
    }
    notifier.state = size;
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
      MapOverlaySheetType.chat => const [0.3, 0.5, 0.88],
      MapOverlaySheetType.explore => const [0.3, 0.5, 0.88],
      MapOverlaySheetType.none => const [0.2, 0.5, 0.88],
      MapOverlaySheetType.createRoadTrip => const [0.3, 0.5, 0.88],
      MapOverlaySheetType.createCityEvent => const [0.3, 0.5, 0.88],
    };
  }
  
  bool get _shouldSnap => true;

  double get _initialSize {
    final snapSizes = _snapSizes;
    return switch (widget.sheetType) {
      MapOverlaySheetType.chat => snapSizes[0], // 初始为 collapsed（阶段一），确保底部导航栏和悬浮按钮显示
      MapOverlaySheetType.explore => snapSizes[0], // 初始为 collapsed（阶段一），确保底部导航栏和悬浮按钮显示
      MapOverlaySheetType.none => snapSizes.first,
      MapOverlaySheetType.createRoadTrip => snapSizes.length > 1 ? snapSizes[1] : snapSizes.first,
      MapOverlaySheetType.createCityEvent => snapSizes.length > 1 ? snapSizes[1] : snapSizes.first,
    };
  }

  @override
  void didUpdateWidget(covariant _MapOverlaySheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sheetType != widget.sheetType) {
      _currentSize = _initialSize;
      // 延迟到下一帧再更新状态，避免在 didUpdateWidget 中直接修改 provider
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _notifyStateChanges(_currentSize);
          DraggableScrollableActuator.reset(context);
        }
      });
    }
  }

  void _notifyStage(double size) {
    final notifier = ref.read(mapOverlaySheetStageProvider.notifier);
    final newStage = _stageForSize(size);
    if (notifier.state != newStage) {
      notifier.state = newStage;
    }
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
                    
                    // 创建 ValueNotifier 用于 tab 切换请求
                    _roadTripTabChangeNotifier ??= ValueNotifier<int>(0);
                    
                    return CreateRoadTripSheet(
                      scrollController: scrollController,
                      mode: mode,
                      embeddedMode: true, // overlay 模式
                      initialRoute: initialRoute,
                      startPositionListenable: selectionController.selectedLatLngListenable,
                      destinationListenable: selectionController.destinationLatLngListenable,
                      tabChangeNotifier: _roadTripTabChangeNotifier, // 传递 ValueNotifier
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
                      onCanSwipeChanged: (canSwipe) {
                        // 接收 _canSwipe 状态变化，通知父组件
                        widget.onRoadTripCanSwipeChanged?.call(canSwipe);
                        if (mounted) {
                          setState(() {
                            _roadTripCanSwipe = canSwipe;
                          });
                        }
                      },
                      onTabIndexChanged: (index) {
                        // 接收 TabController 的 index 变化
                        if (mounted) {
                          setState(() {
                            _roadTripTab = index;
                          });
                        }
                      },
                    );
                  },
                );
              case MapOverlaySheetType.createCityEvent:
                effectiveContent = Consumer(
                  builder: (context, ref, _) {
                    final selectionController = ref.read(mapSelectionControllerProvider.notifier);
                    
                    return CreateCityEventSheet(
                      scrollController: scrollController,
                      embeddedMode: true, // overlay 模式
                      meetingPointPositionListenable: selectionController.selectedLatLngListenable,
                      onCancel: () {
                        final selectionController = ref.read(mapSelectionControllerProvider.notifier);
                        
                        // 立即清理所有选择状态
                        selectionController.setSelectingDestination(false);
                        selectionController.setSelectionSheetOpen(false);
                        selectionController.setSelectedLatLng(null);
                        selectionController.resetMapPadding();
                        
                        // 关闭 overlay
                        ref.read(mapOverlaySheetProvider.notifier).state = MapOverlaySheetType.none;
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
                                  // 关闭 overlay 时，如果是 CreateRoadTripSheet 或 CreateCityEventSheet，需要清理状态
                                  if (widget.sheetType == MapOverlaySheetType.createRoadTrip ||
                                      widget.sheetType == MapOverlaySheetType.createCityEvent) {
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
                        } else if (widget.sheetType == MapOverlaySheetType.createRoadTrip) {
                          // CreateRoadTrip 的 ToggleTabBar（只在 _roadTripCanSwipe 为 true 时显示）
                          if (!_roadTripCanSwipe) {
                            return const SizedBox.shrink();
                          }
                          return ToggleTabBar(
                            selectedIndex: _roadTripTab,
                            firstLabel: loc.road_trip_tab_route,
                            secondLabel: loc.road_trip_tab_waypoints,
                            onChanged: (value) {
                              setState(() => _roadTripTab = value);
                              // 通知 CreateRoadTripSheet 切换 tab
                              _roadTripTabChangeNotifier?.value = value;
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

