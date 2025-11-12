// widgets/breathing_marker_overlay.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:crew_app/features/events/presentation/widgets/common/components/map_selection_controller.dart';

/// 呼吸动画标记点覆盖层
/// 在地图上显示拖拽时的呼吸动画效果
/// 使用 CustomPainter 在地图上绘制呼吸动画圆圈
/// 
/// 注意：呼吸效果和标记点的生命周期是强制关联的
/// 只有当对应的标记点存在时，才会显示呼吸效果
class BreathingMarkerOverlay extends StatefulWidget {
  const BreathingMarkerOverlay({
    super.key,
    required this.draggingPosition,
    required this.draggingType,
    required this.cameraPosition,
    required this.selectionState,
  });

  final LatLng? draggingPosition;
  final DraggingMarkerType? draggingType;
  final CameraPosition? cameraPosition;
  final MapSelectionState selectionState;

  @override
  State<BreathingMarkerOverlay> createState() => _BreathingMarkerOverlayState();
}

class _BreathingMarkerOverlayState extends State<BreathingMarkerOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // 缩放动画：从 1.0 到 1.8，再回到 1.0
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.8)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.8, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_animationController);

    // 透明度动画：从 0.4 到 0.0
    _opacityAnimation = Tween<double>(begin: 0.4, end: 0.0)
        .chain(CurveTween(curve: Curves.easeOut))
        .animate(_animationController);

    if (widget.draggingPosition != null) {
      _animationController.repeat();
    }
  }

  @override
  void didUpdateWidget(BreathingMarkerOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 如果开始选择标记点，启动动画
    if (widget.draggingPosition != null && oldWidget.draggingPosition == null) {
      _animationController.repeat();
    }
    // 如果停止选择标记点，停止动画
    if (widget.draggingPosition == null && oldWidget.draggingPosition != null) {
      _animationController.stop();
      _animationController.reset();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getMarkerColor(DraggingMarkerType? type) {
    switch (type) {
      case DraggingMarkerType.start:
        return Colors.blue; // Azure 色
      case DraggingMarkerType.destination:
        return Colors.green; // 绿色
      case DraggingMarkerType.forwardWaypoint:
      case DraggingMarkerType.returnWaypoint:
        return Colors.orange; // 黄色/橙色
      default:
        return Colors.blue;
    }
  }

  /// 检查对应的标记点是否存在
  /// 这是防御性检查，确保呼吸效果和标记点的生命周期强制关联
  bool _isMarkerExists() {
    if (widget.draggingPosition == null || widget.draggingType == null) {
      return false;
    }

    final state = widget.selectionState;
    final position = widget.draggingPosition!;

    switch (widget.draggingType!) {
      case DraggingMarkerType.start:
        // 检查起点是否存在
        return state.selectedLatLng != null &&
            state.selectedLatLng!.latitude == position.latitude &&
            state.selectedLatLng!.longitude == position.longitude;
      
      case DraggingMarkerType.destination:
        // 检查终点是否存在
        return state.destinationLatLng != null &&
            state.destinationLatLng!.latitude == position.latitude &&
            state.destinationLatLng!.longitude == position.longitude;
      
      case DraggingMarkerType.forwardWaypoint:
        // 检查去程途经点是否存在
        return state.forwardWaypoints.any((wp) =>
            wp.latitude == position.latitude &&
            wp.longitude == position.longitude);
      
      case DraggingMarkerType.returnWaypoint:
        // 检查返程途经点是否存在
        return state.returnWaypoints.any((wp) =>
            wp.latitude == position.latitude &&
            wp.longitude == position.longitude);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 第一层检查：基本参数是否存在
    if (widget.draggingPosition == null || widget.draggingType == null) {
      return const SizedBox.shrink();
    }

    // 第二层检查（防御性）：对应的标记点是否存在
    // 这确保了呼吸效果和标记点的生命周期强制关联
    if (!_isMarkerExists()) {
      return const SizedBox.shrink();
    }

    final markerColor = _getMarkerColor(widget.draggingType);

    return IgnorePointer(
      // 不阻止地图交互，只显示视觉效果
      ignoring: true,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return CustomPaint(
            painter: _BreathingMarkerPainter(
              position: widget.draggingPosition!,
              cameraPosition: widget.cameraPosition,
              color: markerColor,
              scale: _scaleAnimation.value,
              opacity: _opacityAnimation.value,
            ),
            child: const SizedBox.expand(),
          );
        },
      ),
    );
  }
}

/// 绘制呼吸动画圆圈的 CustomPainter
class _BreathingMarkerPainter extends CustomPainter {
  _BreathingMarkerPainter({
    required this.position,
    required this.cameraPosition,
    required this.color,
    required this.scale,
    required this.opacity,
  });

  final LatLng position;
  final CameraPosition? cameraPosition;
  final Color color;
  final double scale;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    if (cameraPosition == null) return;

    // 计算屏幕坐标
    final screenPoint = _latLngToScreen(position, cameraPosition!, size);

    // 绘制多个呼吸圆圈（从内到外）
    final circles = [
      {'radius': 20.0 * scale, 'opacity': 0.6 * opacity},
      {'radius': 35.0 * scale, 'opacity': 0.4 * opacity},
      {'radius': 50.0 * scale, 'opacity': 0.2 * opacity},
    ];

    for (final circle in circles) {
      final radius = circle['radius'] as double;
      final circleOpacity = circle['opacity'] as double;

      final paint = Paint()
        ..color = color.withValues(alpha: circleOpacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      canvas.drawCircle(
        Offset(screenPoint.dx, screenPoint.dy),
        radius,
        paint,
      );
    }
  }

  /// 将经纬度坐标转换为屏幕坐标
  /// 使用标准的墨卡托投影，考虑地图的旋转和倾斜
  Offset _latLngToScreen(LatLng latLng, CameraPosition camera, Size size) {
    final zoom = camera.zoom;
    final center = camera.target;
    final bearing = camera.bearing;
    final tilt = camera.tilt;

    // Google Maps 使用的标准墨卡托投影
    // 计算世界坐标（像素）
    double worldX(double lng) {
      return (lng + 180.0) / 360.0 * 256.0 * math.pow(2.0, zoom).toDouble();
    }

    double worldY(double lat) {
      final latRad = lat * math.pi / 180.0;
      final mercN = math.log(math.tan((math.pi / 4) + (latRad / 2)));
      return (128.0 - (mercN * 128.0 / math.pi)) * math.pow(2.0, zoom).toDouble();
    }

    // 计算中心点和目标点的世界坐标
    final centerWorldX = worldX(center.longitude);
    final centerWorldY = worldY(center.latitude);
    final pointWorldX = worldX(latLng.longitude);
    final pointWorldY = worldY(latLng.latitude);

    // 计算相对于中心点的像素偏移
    final dx = pointWorldX - centerWorldX;
    final dy = pointWorldY - centerWorldY;

    // 考虑地图旋转（bearing）
    final bearingRad = bearing * math.pi / 180.0;
    final cosBearing = math.cos(bearingRad);
    final sinBearing = math.sin(bearingRad);
    
    // 旋转后的偏移
    final rotatedDx = dx * cosBearing - dy * sinBearing;
    final rotatedDy = dx * sinBearing + dy * cosBearing;

    // 考虑地图倾斜（tilt）- 简化处理，主要影响垂直方向
    final tiltRad = tilt * math.pi / 180.0;
    final tiltFactor = math.cos(tiltRad);
    final adjustedDy = rotatedDy * tiltFactor;

    // 转换为屏幕坐标（屏幕中心为原点）
    final screenX = size.width / 2 + rotatedDx;
    final screenY = size.height / 2 + adjustedDy;

    return Offset(screenX, screenY);
  }

  @override
  bool shouldRepaint(_BreathingMarkerPainter oldDelegate) {
    // 优化：只在关键属性变化时重绘
    if (oldDelegate.position != position ||
        oldDelegate.scale != scale ||
        oldDelegate.opacity != opacity) {
      return true;
    }
    
    // 相机位置变化时，需要及时更新以保持呼吸效果位置准确
    if (cameraPosition != null && oldDelegate.cameraPosition != null) {
      final oldPos = oldDelegate.cameraPosition!;
      final newPos = cameraPosition!;
      // 任何相机变化都需要重绘，确保呼吸效果跟随地图移动
      if (oldPos.target != newPos.target ||
          (newPos.zoom - oldPos.zoom).abs() > 0.01 ||
          (newPos.bearing - oldPos.bearing).abs() > 0.1 ||
          (newPos.tilt - oldPos.tilt).abs() > 0.1) {
        return true;
      }
      return false;
    }
    
    return oldDelegate.cameraPosition != cameraPosition;
  }
}

