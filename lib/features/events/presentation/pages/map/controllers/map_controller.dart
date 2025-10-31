import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:crew_app/features/events/data/event.dart';
import 'package:crew_app/features/events/state/user_location_provider.dart';
import 'package:crew_app/features/events/state/events_providers.dart';

/// 地图控制器，管理地图相关的所有逻辑
class MapController {
  MapController(this.ref);

  final Ref ref;
  GoogleMapController? _mapController;
  bool _mapReady = false;
  bool _movedToSelected = false;

  // Getters
  GoogleMapController? get mapController => _mapController;
  bool get mapReady => _mapReady;
  bool get movedToSelected => _movedToSelected;

  /// 初始化地图控制器
  void initialize() {
    // 监听用户位置变化
    ref.listen<AsyncValue<LatLng?>>(userLocationProvider, (prev, next) {
      final loc = next.value;
      if (!_movedToSelected && loc != null) {
        moveCamera(loc, zoom: 14);
      }
    });
  }

  /// 地图创建回调
  void onMapCreated(GoogleMapController controller) {
    _mapController?.dispose();
    _mapController = controller;
    _mapReady = false;
  }

  /// 地图准备就绪回调
  void onMapReady() {
    if (_mapReady) return;
    _mapReady = true;
    final loc = ref.read(userLocationProvider).value;
    if (!_movedToSelected && loc != null) {
      moveCamera(loc, zoom: 14);
    }
  }

  /// 移动相机到指定位置
  Future<void> moveCamera(LatLng target, {double zoom = 14}) async {
    final controller = _mapController;
    if (controller == null) return;

    try {
      await controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: target, zoom: zoom, bearing: 0, tilt: 0),
        ),
      );
    } catch (_) {
      await controller.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: target, zoom: zoom, bearing: 0, tilt: 0),
        ),
      );
    }
  }

  /// 聚焦到指定事件
  Future<void> focusOnEvent(Event event, {bool showEventCard = true}) async {
    await moveCamera(LatLng(event.latitude, event.longitude), zoom: 14);
    _movedToSelected = true;
  }

  /// 移动到我的位置
  Future<void> moveToMyLocation() async {
    var loc = ref.read(userLocationProvider).value;

    if (loc != null) {
      await moveCamera(loc, zoom: 14);
      loc = await ref.read(userLocationProvider.notifier).refreshNow();
    }
  }

  /// 获取初始中心点
  LatLng getInitialCenter() {
    final userLoc = ref.read(userLocationProvider).value;
    return userLoc ?? const LatLng(48.8566, 2.3522);
  }

  /// 获取事件标记
  Set<Marker> getEventMarkers() {
    final events = ref.read(eventsProvider);
    return events.maybeWhen(
      data: (eventList) => eventList
          .map(
            (event) => Marker(
              markerId: MarkerId(event.id),
              position: LatLng(event.latitude, event.longitude),
              infoWindow: InfoWindow(title: event.title),
              onTap: () => focusOnEvent(event),
            ),
          )
          .toSet(),
      orElse: () => <Marker>{},
    );
  }

  /// 清理资源
  void dispose() {
    _mapController?.dispose();
    _mapController = null;
  }
}

/// MapController的Provider
final mapControllerProvider = Provider<MapController>((ref) {
  final controller = MapController(ref);
  controller.initialize();
  return controller;
});
