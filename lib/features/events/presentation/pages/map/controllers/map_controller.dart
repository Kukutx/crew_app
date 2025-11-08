import 'dart:async';
import 'dart:math' as math;
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
  LatLng? _currentCenterPosition;

  // Getters
  GoogleMapController? get mapController => _mapController;
  bool get mapReady => _mapReady;
  bool get movedToSelected => _movedToSelected;
  
  /// 获取地图当前中心位置
  Future<LatLng?> getCenterPosition() async {
    return _currentCenterPosition;
  }
  
  /// 更新地图中心位置（在 onCameraMove 时调用）
  void updateCenterPosition(LatLng position) {
    _currentCenterPosition = position;
  }

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

  /// 获取谷歌地图夜间版样式JSON
  static String get darkThemeStyle => '''
[
  {
    "elementType": "geometry",
    "stylers": [{"color": "#1d2c4d"}]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#ffffff"}]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [{"color": "#1d2c4d"}]
  },
  {
    "featureType": "administrative",
    "elementType": "geometry.stroke",
    "stylers": [{"color": "#4b6878"}]
  },
  {
    "featureType": "administrative.land_parcel",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#64779e"}]
  },
  {
    "featureType": "administrative.province",
    "elementType": "geometry.stroke",
    "stylers": [{"color": "#4b6878"}]
  },
  {
    "featureType": "landscape.man_made",
    "elementType": "geometry.stroke",
    "stylers": [{"color": "#4b6878"}]
  },
  {
    "featureType": "landscape.natural",
    "elementType": "geometry",
    "stylers": [{"color": "#023e58"}]
  },
  {
    "featureType": "poi",
    "elementType": "geometry",
    "stylers": [{"color": "#283d6a"}]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#6c9a63"}]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry.fill",
    "stylers": [{"color": "#023e58"}]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#6c9a63"}]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [{"color": "#304a7d"}]
  },
  {
    "featureType": "road",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#98a5be"}]
  },
  {
    "featureType": "road",
    "elementType": "labels.text.stroke",
    "stylers": [{"color": "#1d2c4d"}]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [{"color": "#2c6675"}]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry.stroke",
    "stylers": [{"color": "#255763"}]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#b0d5ce"}]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.stroke",
    "stylers": [{"color": "#023e58"}]
  },
  {
    "featureType": "transit",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#98a5be"}]
  },
  {
    "featureType": "transit",
    "elementType": "labels.text.stroke",
    "stylers": [{"color": "#1d2c4d"}]
  },
  {
    "featureType": "transit.line",
    "elementType": "geometry.fill",
    "stylers": [{"color": "#283d6a"}]
  },
  {
    "featureType": "transit.station",
    "elementType": "geometry",
    "stylers": [{"color": "#3a4762"}]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [{"color": "#0e1626"}]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#4e6d70"}]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.stroke",
    "stylers": [{"color": "#0e1626"}]
  }
]
''';

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

  /// 调整相机以包含多个位置点
  /// [points] 要包含的位置点列表
  /// [padding] 边距（像素），默认为 50
  Future<void> fitBounds(List<LatLng> points, {double padding = 50}) async {
    final controller = _mapController;
    if (controller == null || points.isEmpty) return;

    // 如果只有一个点，使用 moveCamera
    if (points.length == 1) {
      await moveCamera(points.first, zoom: 14);
      return;
    }

    // 计算边界框
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final point in points) {
      minLat = minLat < point.latitude ? minLat : point.latitude;
      maxLat = maxLat > point.latitude ? maxLat : point.latitude;
      minLng = minLng < point.longitude ? minLng : point.longitude;
      maxLng = maxLng > point.longitude ? maxLng : point.longitude;
    }

    // 创建边界框
    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    try {
      await controller.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, padding),
      );
    } catch (_) {
      await controller.moveCamera(
        CameraUpdate.newLatLngBounds(bounds, padding),
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

  /// 计算两个经纬度之间的距离（米）
  double _calculateDistance(LatLng a, LatLng b) {
    const double earthRadius = 6371000; // 地球半径（米）
    final double dLat = (b.latitude - a.latitude) * math.pi / 180.0;
    final double dLon = (b.longitude - a.longitude) * math.pi / 180.0;
    final double sinDLat = math.sin(dLat / 2);
    final double sinDLon = math.sin(dLon / 2);
    final double a1 = sinDLat * sinDLat +
        math.cos(a.latitude * math.pi / 180.0) *
            math.cos(b.latitude * math.pi / 180.0) *
            sinDLon *
            sinDLon;
    final double c = 2 * math.atan2(math.sqrt(a1), math.sqrt(1 - a1));
    return earthRadius * c;
  }

  /// 判断地图中心是否在用户位置附近
  /// [threshold] 距离阈值（米），默认 50 米
  bool isAtUserLocation({double threshold = 50.0}) {
    final userLoc = ref.read(userLocationProvider).value;
    if (userLoc == null || _currentCenterPosition == null) {
      return false;
    }
    final distance = _calculateDistance(userLoc, _currentCenterPosition!);
    return distance <= threshold;
  }

  /// 回正地图（使用当前相机位置信息）
  /// [currentZoom] 当前缩放级别
  /// [currentTilt] 当前倾斜角度
  Future<void> resetBearing({
    required double currentZoom,
    required double currentTilt,
  }) async {
    final controller = _mapController;
    if (controller == null || _currentCenterPosition == null) return;

    try {
      await controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _currentCenterPosition!,
            zoom: currentZoom,
            bearing: 0,
            tilt: currentTilt,
          ),
        ),
      );
    } catch (_) {
      await controller.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _currentCenterPosition!,
            zoom: currentZoom,
            bearing: 0,
            tilt: currentTilt,
          ),
        ),
      );
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

