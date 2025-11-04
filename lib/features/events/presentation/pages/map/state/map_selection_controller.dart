import 'dart:collection';

import 'package:crew_app/core/network/places/places_service.dart';
import 'package:crew_app/features/events/state/places_providers.dart';
import 'package:crew_app/features/events/presentation/pages/trips/data/road_trip_editor_models.dart';
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
  final RoadTripRouteType? routeType; // 路线类型
  final LatLng? draggingMarkerPosition; // 正在拖拽的标记点位置
  final DraggingMarkerType? draggingMarkerType; // 正在拖拽的标记点类型

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
    RoadTripRouteType? routeType,
    LatLng? draggingMarkerPosition,
    DraggingMarkerType? draggingMarkerType,
    bool clearDraggingMarker = false,
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
    }
  }

  void setDestinationLatLng(LatLng? position) {
    _destinationLatLngNotifier.value = position;
    state = state.copyWith(
      destinationLatLng: position,
      destinationLatLngSet: true,
    );
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
    state = state.copyWith(forwardWaypoints: waypoints);
  }

  void setReturnWaypoints(List<LatLng> waypoints) {
    state = state.copyWith(returnWaypoints: waypoints);
  }

  void setRouteType(RoadTripRouteType? routeType) {
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
