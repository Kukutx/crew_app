import 'package:crew_app/core/network/places/places_service.dart';
import 'package:crew_app/features/events/presentation/widgets/common/components/map_selection_controller.dart';
import 'package:crew_app/features/events/presentation/widgets/trips/managers/base_location_manager.dart';
import 'package:crew_app/features/events/presentation/widgets/trips/state/road_trip_form_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// 自驾游途径点管理器
/// 
/// 统一管理途径点的添加、删除、重排序等操作
class RoadTripWaypointManager extends BaseLocationManager {
  final RoadTripFormState state;
  final VoidCallback onStateChanged;

  RoadTripWaypointManager({
    required WidgetRef ref,
    required this.state,
    required this.onStateChanged,
  }) : super(ref);

  /// 添加途径点地址到缓存
  void addWaypointAddress(LatLng location, PlaceDetails? place) {
    final key = '${location.latitude}_${location.longitude}';
    if (!state.waypointAddressFutures.containsKey(key)) {
      state.waypointAddressFutures[key] = _loadAddress(location);
      state.waypointAddressFutures[key]!.then((address) {
        if (address != null && address.trim().isNotEmpty) {
          state.waypointAddressCache[key] = address.trim();
          onStateChanged();
        }
      });
    } else if (place != null) {
      final address = place.formattedAddress ?? place.displayName;
      if (address.trim().isNotEmpty) {
        state.waypointAddressCache[key] = address.trim();
        onStateChanged();
      }
    }
  }

  /// 加载地址（使用基类的公共方法）
  Future<String?> _loadAddress(LatLng latLng) async {
    return loadAddress(latLng);
  }

  /// 更新 MapSelectionController 中的途径点
  void updateMapSelectionController({required bool isForward}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = ref.read(mapSelectionControllerProvider.notifier);
      if (isForward) {
        controller.setForwardWaypoints(state.forwardWaypoints);
      } else {
        controller.setReturnWaypoints(state.returnWaypoints);
      }
      controller.setWaypointNotes(state.waypointNotes);
    });
  }

  /// 重建地址缓存（用于重排序后）
  void rebuildAddressCache() {
    final newAddressCache = <String, String>{};
    final newAddressFutures = <String, Future<String?>>{};

    for (final wp in state.forwardWaypoints) {
      final key = '${wp.latitude}_${wp.longitude}';
      if (state.waypointAddressCache.containsKey(key)) {
        newAddressCache[key] = state.waypointAddressCache[key]!;
      }
      if (state.waypointAddressFutures.containsKey(key)) {
        newAddressFutures[key] = state.waypointAddressFutures[key]!;
      }
    }

    for (final wp in state.returnWaypoints) {
      final key = '${wp.latitude}_${wp.longitude}';
      if (state.waypointAddressCache.containsKey(key)) {
        newAddressCache[key] = state.waypointAddressCache[key]!;
      }
      if (state.waypointAddressFutures.containsKey(key)) {
        newAddressFutures[key] = state.waypointAddressFutures[key]!;
      }
    }

    state.waypointAddressCache.clear();
    state.waypointAddressCache.addAll(newAddressCache);
    state.waypointAddressFutures.clear();
    state.waypointAddressFutures.addAll(newAddressFutures);
  }

  /// 添加途径点
  void addWaypoint(PlaceDetails place, {required bool isForward}) {
    final location = place.location;
    if (location == null) return;

    if (isForward) {
      state.forwardWaypoints.add(location);
    } else {
      state.returnWaypoints.add(location);
    }

    addWaypointAddress(location, place);
    updateMapSelectionController(isForward: isForward);
    onStateChanged();
  }

  /// 删除途径点
  void removeWaypoint(int index, {required bool isForward}) {
    final waypoints = isForward ? state.forwardWaypoints : state.returnWaypoints;
    if (index < 0 || index >= waypoints.length) return;

    final removed = waypoints[index];
    final key = '${removed.latitude}_${removed.longitude}';

    waypoints.removeAt(index);
    state.waypointAddressCache.remove(key);
    state.waypointAddressFutures.remove(key);
    state.waypointNotes.remove(key);

    updateMapSelectionController(isForward: isForward);
    onStateChanged();
  }

  /// 重排序途径点
  void reorderWaypoints(int oldIndex, int newIndex, {required bool isForward}) {
    if (oldIndex == newIndex) return;

    final waypoints = isForward ? state.forwardWaypoints : state.returnWaypoints;
    if (oldIndex < 0 || oldIndex >= waypoints.length) return;
    if (newIndex < 0 || newIndex >= waypoints.length) return;

    final item = waypoints.removeAt(oldIndex);
    waypoints.insert(newIndex, item);
    rebuildAddressCache();

    updateMapSelectionController(isForward: isForward);
    onStateChanged();
  }

  /// 同步途径点列表（从外部状态同步到内部状态）
  void syncWaypoints(List<LatLng> newWaypoints, {required bool isForward}) {
    final currentWaypoints = isForward ? state.forwardWaypoints : state.returnWaypoints;

    bool hasChange = false;
    if (newWaypoints.length != currentWaypoints.length) {
      hasChange = true;
    } else {
      for (int i = 0; i < newWaypoints.length; i++) {
        if (newWaypoints[i] != currentWaypoints[i]) {
          hasChange = true;
          break;
        }
      }
    }

    if (!hasChange) return;

    currentWaypoints.clear();
    currentWaypoints.addAll(newWaypoints);

    for (final wp in newWaypoints) {
      final key = '${wp.latitude}_${wp.longitude}';
      if (!state.waypointAddressCache.containsKey(key) &&
          !state.waypointAddressFutures.containsKey(key)) {
        state.waypointAddressFutures[key] = _loadAddress(wp);
        state.waypointAddressFutures[key]!.then((address) {
          if (address != null && address.trim().isNotEmpty) {
            state.waypointAddressCache[key] = address.trim();
            onStateChanged();
          }
        });
      }
    }

    onStateChanged();
  }
}

