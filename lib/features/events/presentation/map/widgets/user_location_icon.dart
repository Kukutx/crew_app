import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<BitmapDescriptor> createUserLocationIcon({
  double size = 120,
  Color fillColor = const Color(0xFF1A73E8),
  Color arrowColor = Colors.white,
  Color borderColor = Colors.white,
  double borderWidth = 8,
  double shadowBlur = 12,
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final center = Offset(size / 2, size / 2);

  if (shadowBlur > 0) {
    final shadowPath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: size / 2));
    canvas.drawShadow(
      shadowPath,
      Colors.black.withOpacity(0.45),
      shadowBlur,
      true,
    );
  }

  final fillPaint = Paint()
    ..isAntiAlias = true
    ..color = fillColor;
  canvas.drawCircle(center, size / 2, fillPaint);

  if (borderWidth > 0) {
    final strokePaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..color = borderColor;
    canvas.drawCircle(center, size / 2 - borderWidth / 2, strokePaint);
  }

  final arrowHeight = size * 0.6;
  final arrowWidth = arrowHeight * 0.6;
  final arrowPath = Path()
    ..moveTo(center.dx, center.dy - arrowHeight / 2)
    ..lineTo(center.dx + arrowWidth / 2, center.dy + arrowHeight / 2)
    ..lineTo(center.dx, center.dy + arrowHeight / 3)
    ..lineTo(center.dx - arrowWidth / 2, center.dy + arrowHeight / 2)
    ..close();

  final arrowPaint = Paint()
    ..isAntiAlias = true
    ..style = PaintingStyle.fill
    ..color = arrowColor;
  canvas.drawPath(arrowPath, arrowPaint);

  final picture = recorder.endRecording();
  final image = await picture.toImage(size.toInt(), size.toInt());
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  final bytes = byteData!.buffer.asUint8List();
  return BitmapDescriptor.fromBytes(bytes);
}
