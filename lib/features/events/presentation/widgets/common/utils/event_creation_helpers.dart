import 'package:crew_app/features/events/data/event_common_models.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// 事件创建辅助工具类
class EventCreationHelper {
  EventCreationHelper._();

  /// 格式化坐标为地址字符串
  static String formatCoordinate(LatLng latLng) {
    return '${latLng.latitude.toStringAsFixed(6)}, ${latLng.longitude.toStringAsFixed(6)}';
  }

  /// 格式化坐标为地址字符串（别名，保持向后兼容）
  @Deprecated('使用 formatCoordinate 代替')
  static String formatCoordinateAsAddress(LatLng latLng) {
    return formatCoordinate(latLng);
  }

  /// 构建途径点段列表
  static List<EventWaypointSegment> buildWaypointSegments({
    required List<LatLng> forwardWaypoints,
    required List<LatLng> returnWaypoints,
    required bool isRoundTrip,
  }) {
    return [
      ...forwardWaypoints.asMap().entries.map(
            (entry) => EventWaypointSegment(
              coordinate: '${entry.value.latitude},${entry.value.longitude}',
              direction: EventWaypointDirection.forward,
              order: entry.key,
            ),
          ),
      if (isRoundTrip)
        ...returnWaypoints.asMap().entries.map(
              (entry) => EventWaypointSegment(
                coordinate: '${entry.value.latitude},${entry.value.longitude}',
                direction: EventWaypointDirection.returnTrip,
                order: entry.key,
              ),
            ),
    ];
  }

  /// 获取位置显示标题
  static String getLocationDisplayTitle({
    required String? address,
    required LatLng? position,
    required String defaultTitle,
    int maxLength = 50,
  }) {
    if (address != null && address.trim().isNotEmpty) {
      return address.trim().length > maxLength
          ? '${address.trim().substring(0, maxLength)}...'
          : address.trim();
    }
    if (position != null) {
      return formatCoordinate(position);
    }
    return defaultTitle;
  }
}

