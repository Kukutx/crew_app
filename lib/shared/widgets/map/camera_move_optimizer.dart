import 'dart:async';
import 'dart:math' as math;
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// 地图相机移动优化器的控制器接口
/// 用于解耦具体实现
abstract class MapCameraController {
  void updateCenterPosition(LatLng position);
  bool isAtUserLocation({double threshold = 50.0});
}

/// 相机移动优化器，统一处理相机移动事件，减少不必要的更新
class CameraMoveOptimizer {
  CameraMoveOptimizer({
    required this.mapController,
    this.positionUpdateThreshold = 10.0, // 位置更新阈值（米）
    this.zoomUpdateThreshold = 0.5, // 缩放更新阈值
    this.bearingUpdateThreshold = 5.0, // 旋转更新阈值（度）
    this.updateDebounceMs = 100, // 更新防抖时间（毫秒）
  });

  final MapCameraController mapController;
  final double positionUpdateThreshold;
  final double zoomUpdateThreshold;
  final double bearingUpdateThreshold;
  final int updateDebounceMs;

  CameraPosition? _lastNotifiedPosition;
  Timer? _debounceTimer;
  bool _pendingUpdate = false;

  /// 处理相机移动事件
  /// 返回是否需要更新 UI
  bool handleCameraMove(CameraPosition position) {
    // 更新地图中心位置（用于地图选择模式）
    mapController.updateCenterPosition(position.target);

    // 检查是否需要更新
    final shouldUpdate = _shouldUpdate(position);
    if (!shouldUpdate) {
      return false;
    }

    // 使用防抖，避免频繁更新
    _pendingUpdate = true;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(Duration(milliseconds: updateDebounceMs), () {
      if (_pendingUpdate) {
        _lastNotifiedPosition = position;
        _pendingUpdate = false;
      }
    });

    return true;
  }

  /// 判断是否需要更新
  bool _shouldUpdate(CameraPosition position) {
    if (_lastNotifiedPosition == null) {
      return true;
    }

    final last = _lastNotifiedPosition!;

    // 检查位置变化
    final distance = _calculateDistance(
      position.target,
      last.target,
    );
    if (distance > positionUpdateThreshold) {
      return true;
    }

    // 检查缩放变化
    if ((position.zoom - last.zoom).abs() > zoomUpdateThreshold) {
      return true;
    }

    // 检查旋转变化
    final bearingDiff = _calculateBearingDifference(
      position.bearing,
      last.bearing,
    );
    if (bearingDiff > bearingUpdateThreshold) {
      return true;
    }

    return false;
  }

  /// 判断是否应该显示指南针
  bool shouldShowCompass(CameraPosition position) {
    // 检查是否在用户位置附近（50米内）
    final isAtUserLocation = mapController.isAtUserLocation(threshold: 50.0);
    if (isAtUserLocation) {
      return false;
    }

    // 检查地图是否被旋转（bearing 的绝对值 > 5度）
    final bearing = position.bearing;
    final absBearing = bearing.abs();
    final normalizedBearing = absBearing % 360;
    final minBearing = normalizedBearing > 180 ? 360 - normalizedBearing : normalizedBearing;

    return minBearing > bearingUpdateThreshold;
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

  /// 计算两个角度的最小差值
  double _calculateBearingDifference(double bearing1, double bearing2) {
    final diff = (bearing1 - bearing2).abs();
    return diff > 180 ? 360 - diff : diff;
  }

  /// 获取最后通知的位置
  CameraPosition? get lastNotifiedPosition => _lastNotifiedPosition;

  /// 清理资源
  void dispose() {
    _debounceTimer?.cancel();
    _debounceTimer = null;
  }
}

