import 'dart:collection';

import 'package:crew_app/core/network/places/places_service.dart';
import 'package:crew_app/features/events/state/places_providers.dart';
import 'package:crew_app/features/events/data/event_common_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// 正在拖拽的标记点类型
enum DraggingMarkerType {
  start, // 起点
  destination, // 终点
  forwardWaypoint, // 去程途经点
  returnWaypoint, // 返程途经点
}

@immutable
class MapSelectionState {
  const MapSelectionState({
    this.selectedLatLng,
    this.destinationLatLng,
    this.isSelectingDestination = false,
    this.isSelectionSheetOpen = false,
    this.mapPadding = EdgeInsets.zero,
    this.isAddingWaypoint = false,
    this.isAddingForwardWaypoint = true,
    this.pendingWaypoint,
    this.forwardWaypoints = const [],
    this.returnWaypoints = const [],
    this.routeType,
    this.draggingMarkerPosition,
    this.draggingMarkerType,
    this.isMapPickerMode = false,
    this.isPickingStartLocation = true,
    this.currentTabIndex = 0,
  });

  final LatLng? selectedLatLng;
  final LatLng? destinationLatLng;
  final bool isSelectingDestination;
  final bool isSelectionSheetOpen;
  final EdgeInsets mapPadding;
  final bool isAddingWaypoint;
  final bool isAddingForwardWaypoint;
  final LatLng? pendingWaypoint; // 临时存储新添加的途经点
  final List<LatLng> forwardWaypoints; // 去程途经点
  final List<LatLng> returnWaypoints; // 返程途经点
  final EventRouteType? routeType; // 路线类型
  final LatLng? draggingMarkerPosition; // 正在拖拽的标记点位置
  final DraggingMarkerType? draggingMarkerType; // 正在拖拽的标记点类型
  final bool isMapPickerMode; // 是否正在进行地图选择模式
  final bool isPickingStartLocation; // 是否正在选择起点（true）还是终点（false）
  final int currentTabIndex; // 当前tab索引（0=路线，1=途径点）

  MapSelectionState copyWith({
    LatLng? selectedLatLng,
    bool selectedLatLngSet = false,
    LatLng? destinationLatLng,
    bool destinationLatLngSet = false,
    bool? isSelectingDestination,
    bool? isSelectionSheetOpen,
    EdgeInsets? mapPadding,
    bool? isAddingWaypoint,
    bool? isAddingForwardWaypoint,
    LatLng? pendingWaypoint,
    bool clearPendingWaypoint = false,
    List<LatLng>? forwardWaypoints,
    List<LatLng>? returnWaypoints,
    EventRouteType? routeType,
    LatLng? draggingMarkerPosition,
    DraggingMarkerType? draggingMarkerType,
    bool clearDraggingMarker = false,
    bool? isMapPickerMode,
    bool? isPickingStartLocation,
    int? currentTabIndex,
  }) {
    return MapSelectionState(
      selectedLatLng:
          selectedLatLngSet ? selectedLatLng : this.selectedLatLng,
      destinationLatLng:
          destinationLatLngSet ? destinationLatLng : this.destinationLatLng,
      isSelectingDestination:
          isSelectingDestination ?? this.isSelectingDestination,
      isSelectionSheetOpen:
          isSelectionSheetOpen ?? this.isSelectionSheetOpen,
      mapPadding: mapPadding ?? this.mapPadding,
      isAddingWaypoint: isAddingWaypoint ?? this.isAddingWaypoint,
      isAddingForwardWaypoint: isAddingForwardWaypoint ?? this.isAddingForwardWaypoint,
      pendingWaypoint: clearPendingWaypoint ? null : (pendingWaypoint ?? this.pendingWaypoint),
      forwardWaypoints: forwardWaypoints ?? this.forwardWaypoints,
      returnWaypoints: returnWaypoints ?? this.returnWaypoints,
      routeType: routeType ?? this.routeType,
      draggingMarkerPosition: clearDraggingMarker ? null : (draggingMarkerPosition ?? this.draggingMarkerPosition),
      draggingMarkerType: clearDraggingMarker ? null : (draggingMarkerType ?? this.draggingMarkerType),
      isMapPickerMode: isMapPickerMode ?? this.isMapPickerMode,
      isPickingStartLocation: isPickingStartLocation ?? this.isPickingStartLocation,
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
    );
  }
}

class MapSelectionController extends StateNotifier<MapSelectionState> {
  MapSelectionController(this._ref) : super(const MapSelectionState());

  final Ref _ref;
  final ValueNotifier<LatLng?> _selectedLatLngNotifier =
      ValueNotifier<LatLng?>(null);
  final ValueNotifier<LatLng?> _destinationLatLngNotifier =
      ValueNotifier<LatLng?>(null);
  final Map<String, Future<List<NearbyPlace>>> _nearbyPlacesCache =
      HashMap<String, Future<List<NearbyPlace>>>();

  ValueNotifier<LatLng?> get selectedLatLngListenable =>
      _selectedLatLngNotifier;
  ValueNotifier<LatLng?> get destinationLatLngListenable =>
      _destinationLatLngNotifier;

  PlacesService get _placesService =>
      _ref.read(placesServiceProvider);

  void setSelectedLatLng(LatLng? position) {
    _selectedLatLngNotifier.value = position;
    state = state.copyWith(
      selectedLatLng: position,
      selectedLatLngSet: true,
    );
    if (position == null) {
      setDestinationLatLng(null);
      // 如果清除起点，且呼吸效果指向起点，清除呼吸效果
      if (state.draggingMarkerType == DraggingMarkerType.start) {
        clearDraggingMarker();
      }
    }
  }

  void setDestinationLatLng(LatLng? position) {
    _destinationLatLngNotifier.value = position;
    state = state.copyWith(
      destinationLatLng: position,
      destinationLatLngSet: true,
    );
    // 如果清除终点，且呼吸效果指向终点，清除呼吸效果
    if (position == null && state.draggingMarkerType == DraggingMarkerType.destination) {
      clearDraggingMarker();
    }
  }

  void setSelectingDestination(bool value) {
    state = state.copyWith(isSelectingDestination: value);
  }

  void setSelectionSheetOpen(bool value) {
    state = state.copyWith(isSelectionSheetOpen: value);
  }

  void setMapPadding(EdgeInsets padding) {
    state = state.copyWith(mapPadding: padding);
  }

  void resetMapPadding() {
    state = state.copyWith(mapPadding: EdgeInsets.zero);
  }

  void setAddingWaypoint(bool value, {bool isForward = true}) {
    state = state.copyWith(
      isAddingWaypoint: value,
      isAddingForwardWaypoint: isForward,
    );
  }

  void setPendingWaypoint(LatLng? waypoint) {
    state = state.copyWith(
      pendingWaypoint: waypoint,
      clearPendingWaypoint: waypoint == null,
    );
  }

  void setForwardWaypoints(List<LatLng> waypoints) {
    // 检查呼吸效果是否指向被移除的去程途经点
    if (state.draggingMarkerType == DraggingMarkerType.forwardWaypoint &&
        state.draggingMarkerPosition != null) {
      final markerStillExists = waypoints.any((wp) =>
          wp.latitude == state.draggingMarkerPosition!.latitude &&
          wp.longitude == state.draggingMarkerPosition!.longitude);
      if (!markerStillExists) {
        // 途经点被移除了，清除呼吸效果
        state = state.copyWith(
          forwardWaypoints: waypoints,
          clearDraggingMarker: true,
        );
        return;
      }
    }
    state = state.copyWith(forwardWaypoints: waypoints);
  }

  void setReturnWaypoints(List<LatLng> waypoints) {
    // 检查呼吸效果是否指向被移除的返程途经点
    if (state.draggingMarkerType == DraggingMarkerType.returnWaypoint &&
        state.draggingMarkerPosition != null) {
      final markerStillExists = waypoints.any((wp) =>
          wp.latitude == state.draggingMarkerPosition!.latitude &&
          wp.longitude == state.draggingMarkerPosition!.longitude);
      if (!markerStillExists) {
        // 途经点被移除了，清除呼吸效果
        state = state.copyWith(
          returnWaypoints: waypoints,
          clearDraggingMarker: true,
        );
        return;
      }
    }
    state = state.copyWith(returnWaypoints: waypoints);
  }

  void setRouteType(EventRouteType? routeType) {
    state = state.copyWith(routeType: routeType);
  }

  void resetSelection() {
    setSelectingDestination(false);
    setAddingWaypoint(false);
    setSelectedLatLng(null);
    setDestinationLatLng(null);
    setForwardWaypoints([]);
    setReturnWaypoints([]);
    setRouteType(null);
    clearDraggingMarker();
  }

  void setDraggingMarker(LatLng position, DraggingMarkerType type) {
    state = state.copyWith(
      draggingMarkerPosition: position,
      draggingMarkerType: type,
    );
  }

  void clearDraggingMarker() {
    state = state.copyWith(clearDraggingMarker: true);
  }

  void setMapPickerMode(bool value, {bool isSelectingStart = true}) {
    state = state.copyWith(
      isMapPickerMode: value,
      isPickingStartLocation: isSelectingStart,
    );
  }

  void setCurrentTabIndex(int index) {
    state = state.copyWith(currentTabIndex: index);
  }

  Future<List<NearbyPlace>> getNearbyPlaces(LatLng position) {
    final key = _cacheKey(position);
    final cached = _nearbyPlacesCache[key];
    if (cached != null) {
      return cached;
    }

    final future = _loadNearbyPlaces(position).then(
      (value) => value,
      onError: (Object error, StackTrace stackTrace) {
        _nearbyPlacesCache.remove(key);
        throw error;
      },
    );
    _nearbyPlacesCache[key] = future;
    return future;
  }

  void clearNearbyPlacesCache() {
    _nearbyPlacesCache.clear();
  }

  String _cacheKey(LatLng position) {
    return '${position.latitude.toStringAsFixed(5)}_${position.longitude.toStringAsFixed(5)}';
  }

  Future<List<NearbyPlace>> _loadNearbyPlaces(LatLng position) async {
    final results = await _placesService.searchNearbyPlaces(
      position,
      radius: 200,
      maxResults: 10,
    );
    return results;
  }

  @override
  void dispose() {
    _selectedLatLngNotifier.dispose();
    _destinationLatLngNotifier.dispose();
    super.dispose();
  }
}

final mapSelectionControllerProvider =
    StateNotifierProvider.autoDispose<MapSelectionController, MapSelectionState>(
  (ref) => MapSelectionController(ref),
);
