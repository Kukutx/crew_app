// widgets/breathing_marker_overlay.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:crew_app/features/events/presentation/pages/map/state/map_selection_controller.dart';

/// 呼吸动画标记点覆盖层
/// 在地图上显示拖拽时的呼吸动画效果
/// 使用 CustomPainter 在地图上绘制呼吸动画圆圈
class BreathingMarkerOverlay extends StatefulWidget {
  const BreathingMarkerOverlay({
    super.key,
    required this.draggingPosition,
    required this.draggingType,
    required this.cameraPosition,
  });

  final LatLng? draggingPosition;
  final DraggingMarkerType? draggingType;
  final CameraPosition? cameraPosition;

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
    // 如果开始拖拽，启动动画
    if (widget.draggingPosition != null && oldWidget.draggingPosition == null) {
      _animationController.repeat();
    }
    // 如果停止拖拽，停止动画
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

  @override
  Widget build(BuildContext context) {
    if (widget.draggingPosition == null || widget.draggingType == null) {
      return const SizedBox.shrink();
    }

    final markerColor = _getMarkerColor(widget.draggingType);

    return AnimatedBuilder(
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
      final radius = circle['radius']! as double;
      final circleOpacity = circle['opacity']! as double;

      final paint = Paint()
        ..color = color.withOpacity(circleOpacity)
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
  Offset _latLngToScreen(LatLng latLng, CameraPosition camera, Size size) {
    // 简化的墨卡托投影计算
    final zoom = camera.zoom;
    final center = camera.target;

    // 计算缩放比例
    final scale = 256.0 * math.pow(2.0, zoom).toDouble();

    // 墨卡托投影函数
    double mercatorX(double lng) {
      return lng / 360.0 + 0.5;
    }

    double mercatorY(double lat) {
      final sinLat = math.sin(lat * math.pi / 180.0);
      return 0.5 - math.log((1 + sinLat) / (1 - sinLat)) / (4 * math.pi);
    }

    // 计算中心点和目标点的墨卡托坐标
    final centerX = mercatorX(center.longitude);
    final centerY = mercatorY(center.latitude);
    final pointX = mercatorX(latLng.longitude);
    final pointY = mercatorY(latLng.latitude);

    // 计算屏幕坐标（相对于中心点的偏移）
    final dx = (pointX - centerX) * scale;
    final dy = (pointY - centerY) * scale;

    // 转换为屏幕坐标（考虑地图旋转和倾斜）
    final screenX = size.width / 2 + dx;
    final screenY = size.height / 2 + dy;

    return Offset(screenX, screenY);
  }

  @override
  bool shouldRepaint(_BreathingMarkerPainter oldDelegate) {
    return oldDelegate.position != position ||
        oldDelegate.cameraPosition != cameraPosition ||
        oldDelegate.scale != scale ||
        oldDelegate.opacity != opacity;
  }
}

