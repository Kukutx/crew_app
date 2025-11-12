import 'dart:async';

import 'package:crew_app/core/network/places/places_service.dart';
import 'package:crew_app/features/events/presentation/widgets/common/components/map_overlay_sheet_providers.dart';
import 'package:crew_app/features/events/presentation/widgets/common/components/map_selection_controller.dart';
import 'package:crew_app/features/events/presentation/pages/map/controllers/map_controller.dart';
import 'package:crew_app/features/events/state/places_providers.dart';
import 'package:crew_app/features/events/presentation/widgets/trips/managers/base_location_manager.dart';
import 'package:crew_app/features/events/presentation/widgets/trips/state/road_trip_form_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// 自驾游位置管理器
/// 
/// 统一管理起点和终点的位置操作
class RoadTripLocationManager extends BaseLocationManager {
  final RoadTripFormState state;
  final VoidCallback onStateChanged;
  final bool embeddedMode;

  RoadTripLocationManager({
    required super.ref,
    required this.state,
    required this.onStateChanged,
    this.embeddedMode = true,
  });

  /// 更新起点位置
  void updateStartLocation(LatLng? position) {
    state.startLatLng = position;
    if (position != null) {
      state.startAddressFuture = _loadAddress(position);
      state.startNearbyFuture = _loadNearbyPlaces(position);
    } else {
      state.startAddressFuture = null;
      state.startNearbyFuture = null;
      state.startAddress = null;
    }
    onStateChanged();
  }

  /// 更新终点位置
  void updateDestinationLocation(LatLng? position) {
    state.destinationLatLng = position;
    if (position != null) {
      state.destinationAddressFuture = _loadAddress(position);
      state.destinationNearbyFuture = _loadNearbyPlaces(position);
    } else {
      state.destinationAddressFuture = null;
      state.destinationNearbyFuture = null;
      state.destinationAddress = null;
    }
    onStateChanged();
  }

  /// 加载地址（使用基类的公共方法）
  Future<String?> _loadAddress(LatLng latLng) async {
    final address = await loadAddress(latLng);
    if (address != null && address.trim().isNotEmpty) {
      // 根据坐标更新对应的地址字段
      if (state.startLatLng == latLng) {
        state.startAddress = address;
      } else if (state.destinationLatLng == latLng) {
        state.destinationAddress = address;
      }
      onStateChanged();
    }
    return address;
  }

  /// 加载附近地点（使用基类的公共方法）
  Future<List<NearbyPlace>> _loadNearbyPlaces(LatLng latLng) async {
    return loadNearbyPlaces(latLng);
  }

  /// 清空起点
  void clearStart() {
    final selectionController = ref.read(mapSelectionControllerProvider.notifier);
    selectionController.setSelectedLatLng(null);
    selectionController.setSelectingDestination(false);
    selectionController.setForwardWaypoints([]);
    selectionController.setReturnWaypoints([]);

    updateStartLocation(null);
    // 同步清空终点
    updateDestinationLocation(null);
  }

  /// 清空终点
  void clearDestination() {
    final selectionController = ref.read(mapSelectionControllerProvider.notifier);
    selectionController.setDestinationLatLng(null);
    selectionController.setSelectingDestination(false);
    selectionController.setForwardWaypoints([]);
    selectionController.setReturnWaypoints([]);

    updateDestinationLocation(null);
  }

  /// 编辑起点（定位到地图）
  Future<void> editStartLocation() async {
    final selectionController = ref.read(mapSelectionControllerProvider.notifier);
    final mapController = ref.read(mapControllerProvider);

    if (state.startLatLng != null) {
      selectionController.setDraggingMarker(
        state.startLatLng!,
        DraggingMarkerType.start,
      );
      await mapController.moveCamera(state.startLatLng!, zoom: 14);
      if (embeddedMode) {
        ref.read(mapOverlaySheetProvider.notifier).state = MapOverlaySheetType.createRoadTrip;
      }
      return;
    }

    await _restartSelectionFlow(skipStart: false);
  }

  /// 编辑终点（定位到地图）
  Future<void> editDestinationLocation() async {
    final selectionController = ref.read(mapSelectionControllerProvider.notifier);
    final mapController = ref.read(mapControllerProvider);

    if (state.destinationLatLng != null) {
      selectionController.setDraggingMarker(
        state.destinationLatLng!,
        DraggingMarkerType.destination,
      );
      await mapController.moveCamera(state.destinationLatLng!, zoom: 14);
      if (embeddedMode) {
        ref.read(mapOverlaySheetProvider.notifier).state = MapOverlaySheetType.createRoadTrip;
      }
      return;
    }

    selectionController.setSelectingDestination(true);
    if (embeddedMode) {
      ref.read(mapOverlaySheetProvider.notifier).state = MapOverlaySheetType.createRoadTrip;
    }

    if (state.startLatLng != null) {
      unawaited(mapController.moveCamera(state.startLatLng!, zoom: 6));
    }
  }

  /// 重新开始选择流程
  Future<void> _restartSelectionFlow({required bool skipStart}) async {
    final selectionController = ref.read(mapSelectionControllerProvider.notifier);
    final mapController = ref.read(mapControllerProvider);

    if (embeddedMode) {
      if (skipStart && state.startLatLng != null) {
        selectionController.setSelectingDestination(true);
        if (state.destinationLatLng != null) {
          unawaited(mapController.moveCamera(state.destinationLatLng!, zoom: 12));
        } else {
          selectionController.setDestinationLatLng(null);
          unawaited(mapController.moveCamera(state.startLatLng!, zoom: 6));
        }
      } else {
        selectionController.setSelectingDestination(false);
        selectionController.setSelectedLatLng(state.startLatLng);
        if (state.startLatLng != null) {
          unawaited(mapController.moveCamera(state.startLatLng!, zoom: 12));
        }
      }
      ref.read(mapOverlaySheetProvider.notifier).state = MapOverlaySheetType.createRoadTrip;
    }
  }
}

