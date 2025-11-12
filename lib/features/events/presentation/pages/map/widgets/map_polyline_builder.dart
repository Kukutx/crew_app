// widgets/map_polyline_builder.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:crew_app/features/events/presentation/pages/map/state/map_selection_controller.dart';
import 'package:crew_app/features/events/data/event_common_models.dart';

/// 地图路线构建器，统一管理所有 polyline 的创建逻辑
class MapPolylineBuilder {
  /// 构建所有 polylines
  static Set<Polyline> buildPolylines(MapSelectionState selectionState) {
    final polylines = <Polyline>{};
    final selected = selectionState.selectedLatLng;
    final destination = selectionState.destinationLatLng;

    if (selected == null || destination == null) {
      return polylines;
    }

    final routeType = selectionState.routeType;
    final forwardWaypoints = selectionState.forwardWaypoints;
    final returnWaypoints = selectionState.returnWaypoints;

    if (routeType == EventRouteType.roundTrip) {
      // 往返路线：分为两条独立的贝塞尔曲线
      _addPolyline(
        polylines: polylines,
        polylineId: const PolylineId('route_polyline_forward'),
        points: [selected, ...forwardWaypoints, destination],
        color: Colors.blue,
      );

      _addPolyline(
        polylines: polylines,
        polylineId: const PolylineId('route_polyline_return'),
        points: [destination, ...returnWaypoints.reversed, selected],
        color: Colors.orange,
      );
    } else {
      // 单程路线：起点 -> 去程途经点 -> 终点
      _addPolyline(
        polylines: polylines,
        polylineId: const PolylineId('route_polyline'),
        points: [selected, ...forwardWaypoints, destination],
        color: Colors.blue,
      );
    }

    return polylines;
  }

  /// 添加 polyline
  static void _addPolyline({
    required Set<Polyline> polylines,
    required PolylineId polylineId,
    required List<LatLng> points,
    required Color color,
  }) {
    if (points.length < 2) return;

    final curvedPoints = _generateCurvedRoute(points);
    polylines.add(
      Polyline(
        polylineId: polylineId,
        points: curvedPoints,
        color: color,
        width: 4,
        geodesic: true,
        patterns: [
          PatternItem.dash(20),
          PatternItem.gap(10),
        ],
      ),
    );
  }

  /// 生成带弧度的路线点（使用贝塞尔曲线插值）
  static List<LatLng> _generateCurvedRoute(List<LatLng> points) {
    if (points.length < 2) return points;

    final curvedPoints = <LatLng>[];
    curvedPoints.add(points.first);

    // 对每两个相邻点之间进行贝塞尔曲线插值
    for (int i = 0; i < points.length - 1; i++) {
      final start = points[i];
      final end = points[i + 1];

      // 计算中间控制点（用于创建弧度）
      final midLat = (start.latitude + end.latitude) / 2;
      final midLng = (start.longitude + end.longitude) / 2;

      // 计算垂直于两点连线的偏移量，创建弧度效果
      final dx = end.longitude - start.longitude;
      final dy = end.latitude - start.latitude;
      final distance = math.sqrt(dx * dx + dy * dy);

      if (distance > 0) {
        // 计算垂直方向（用于创建弧度）
        final perpDx = -dy / distance;
        final perpDy = dx / distance;

        // 弧度强度（可以根据距离调整）
        final curveStrength = math.min(distance * 0.3, 0.5); // 最大弧度不超过0.5度

        // 控制点位置（在中间点的基础上向垂直方向偏移）
        final controlLat = midLat + perpDy * curveStrength;
        final controlLng = midLng + perpDx * curveStrength;

        // 使用二次贝塞尔曲线生成中间点
        final controlPoint = LatLng(controlLat, controlLng);
        final segmentPoints = _bezierCurve(start, controlPoint, end, segments: 10);

        // 添加中间点（跳过第一个点，因为已经添加了起点）
        curvedPoints.addAll(segmentPoints.skip(1));
      } else {
        // 如果距离为0，直接添加终点
        curvedPoints.add(end);
      }
    }

    return curvedPoints;
  }

  /// 生成二次贝塞尔曲线点
  static List<LatLng> _bezierCurve(
    LatLng start,
    LatLng control,
    LatLng end, {
    int segments = 10,
  }) {
    final points = <LatLng>[];

    for (int i = 0; i <= segments; i++) {
      final t = i / segments;
      final lat = _bezierValue(start.latitude, control.latitude, end.latitude, t);
      final lng = _bezierValue(start.longitude, control.longitude, end.longitude, t);
      points.add(LatLng(lat, lng));
    }

    return points;
  }

  /// 计算贝塞尔曲线上的值
  static double _bezierValue(double p0, double p1, double p2, double t) {
    final oneMinusT = 1 - t;
    return oneMinusT * oneMinusT * p0 + 2 * oneMinusT * t * p1 + t * t * p2;
  }
}

