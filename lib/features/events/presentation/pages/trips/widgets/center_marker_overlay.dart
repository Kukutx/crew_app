import 'package:flutter/material.dart';

/// 地图中心固定marker覆盖层
class CenterMarkerOverlay extends StatelessWidget {
  const CenterMarkerOverlay({
    super.key,
    required this.markerColor,
  });

  final Color markerColor;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Marker图标
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: markerColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
            // Marker底部尖角
            CustomPaint(
              size: const Size(20, 20),
              painter: _MarkerPointerPainter(markerColor),
            ),
          ],
        ),
      ),
    );
  }
}

/// Marker底部尖角绘制器
class _MarkerPointerPainter extends CustomPainter {
  _MarkerPointerPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);

    // 绘制白色边框
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(_MarkerPointerPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

