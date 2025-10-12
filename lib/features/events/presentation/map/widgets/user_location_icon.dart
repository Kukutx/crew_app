import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<BitmapDescriptor> createUserLocationIcon({
  double size = 128,
  double shadowBlur = 16,
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final center = Offset(size / 2, size / 2);

  final ringRadius = size * 0.32;
  final wedgeHeight = ringRadius * 2.2;
  final wedgeWidth = ringRadius * 1.28;
  final wedgeBottomY = center.dy - ringRadius * 0.18;

  if (shadowBlur > 0) {
    final shadowPaint = Paint()
      ..isAntiAlias = true
      ..color = Colors.black.withOpacity(0.22)
      ..maskFilter = ui.MaskFilter.blur(ui.BlurStyle.normal, shadowBlur);
    canvas.drawOval(
      Rect.fromCenter(
        center: center + Offset(0, ringRadius * 0.85),
        width: ringRadius * 2.8,
        height: ringRadius * 1.5,
      ),
      shadowPaint,
    );
  }

  final wedgeRect = Rect.fromLTWH(
    center.dx - wedgeWidth / 2,
    center.dy - wedgeHeight,
    wedgeWidth,
    wedgeHeight,
  );
  final wedgePath = Path()
    ..moveTo(center.dx, wedgeRect.top)
    ..lineTo(center.dx + wedgeWidth / 2, wedgeBottomY)
    ..quadraticBezierTo(
      center.dx,
      wedgeBottomY - ringRadius * 0.28,
      center.dx - wedgeWidth / 2,
      wedgeBottomY,
    )
    ..close();
  final wedgePaint = Paint()
    ..isAntiAlias = true
    ..shader = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF0B57D0), Color(0xFF4285F4)],
    ).createShader(wedgeRect);
  canvas.drawPath(wedgePath, wedgePaint);

  final outerCircleRect = Rect.fromCircle(center: center, radius: ringRadius);
  final ringPaint = Paint()
    ..isAntiAlias = true
    ..shader = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF0B57D0), Color(0xFF4F8DFD)],
    ).createShader(outerCircleRect);
  canvas.drawCircle(center, ringRadius, ringPaint);

  final rimPaint = Paint()
    ..isAntiAlias = true
    ..style = PaintingStyle.stroke
    ..strokeWidth = ringRadius * 0.22
    ..color = Colors.white.withOpacity(0.92);
  canvas.drawCircle(center, ringRadius - rimPaint.strokeWidth / 2, rimPaint);

  final innerCirclePaint = Paint()
    ..isAntiAlias = true
    ..color = Colors.white;
  canvas.drawCircle(center, ringRadius * 0.58, innerCirclePaint);

  final highlightPaint = Paint()
    ..isAntiAlias = true
    ..shader = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFFFFFFF), Color(0x00FFFFFF)],
    ).createShader(
      Rect.fromCircle(center: center - Offset(ringRadius * 0.2, ringRadius * 0.2), radius: ringRadius),
    );
  canvas.drawCircle(center, ringRadius * 0.62, highlightPaint);

  final bearingIndicator = Path()
    ..moveTo(center.dx, wedgeRect.top + wedgeHeight * 0.28)
    ..lineTo(center.dx + wedgeWidth * 0.24, wedgeBottomY)
    ..lineTo(center.dx - wedgeWidth * 0.24, wedgeBottomY)
    ..close();
  final bearingPaint = Paint()
    ..isAntiAlias = true
    ..color = Colors.white.withOpacity(0.82);
  canvas.drawPath(bearingIndicator, bearingPaint);

  final picture = recorder.endRecording();
  final image = await picture.toImage(size.toInt(), size.toInt());
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  final bytes = byteData!.buffer.asUint8List();
  return BitmapDescriptor.fromBytes(bytes);
}
