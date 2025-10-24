import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ClusterIconBuilder {
  ClusterIconBuilder({this.size = 160});

  final int size;
  final Map<_ClusterIconKey, Future<BitmapDescriptor>> _cache = {};

  Future<BitmapDescriptor> build({
    required int count,
    required Color backgroundColor,
    required Color textColor,
  }) {
    final key = _ClusterIconKey(count, backgroundColor, textColor, size);
    final cached = _cache[key];
    if (cached != null) {
      return cached;
    }

    final future = _createBitmap(
      count: count,
      backgroundColor: backgroundColor,
      textColor: textColor,
    );
    _cache[key] = future;
    return future;
  }

  Future<BitmapDescriptor> _createBitmap({
    required int count,
    required Color backgroundColor,
    required Color textColor,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..isAntiAlias = true;

    final double radius = size / 2;
    final Offset center = Offset(radius, radius);

    // Draw outer border
    paint.color = Colors.white;
    canvas.drawCircle(center, radius.toDouble(), paint);

    // Draw inner circle
    paint.color = backgroundColor;
    final double innerRadius = radius * 0.84;
    canvas.drawCircle(center, innerRadius, paint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: count.toString(),
        style: TextStyle(
          color: textColor,
          fontSize: innerRadius * 0.7,
          fontWeight: FontWeight.w600,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();

    final Offset textOffset = center - Offset(textPainter.width / 2, textPainter.height / 2);
    textPainter.paint(canvas, textOffset);

    final picture = recorder.endRecording();
    final image = await picture.toImage(size, size);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
  }
}

@immutable
class _ClusterIconKey {
  const _ClusterIconKey(this.count, this.backgroundColor, this.textColor, this.size);

  final int count;
  final Color backgroundColor;
  final Color textColor;
  final int size;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _ClusterIconKey &&
        other.count == count &&
        other.backgroundColor == backgroundColor &&
        other.textColor == textColor &&
        other.size == size;
  }

  @override
  int get hashCode => Object.hash(count, backgroundColor, textColor, size);
}
