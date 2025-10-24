import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Utility to build cached bitmap descriptors for cluster markers.
class ClusterIconRenderer {
  ClusterIconRenderer({Color? backgroundColor, Color? textColor})
      : _backgroundColor = backgroundColor ?? const Color(0xFF3F51B5),
        _textColor = textColor ?? Colors.white;

  final Map<int, BitmapDescriptor> _cache = <int, BitmapDescriptor>{};
  final Color _backgroundColor;
  final Color _textColor;

  /// Returns a circular marker bitmap containing the cluster size.
  Future<BitmapDescriptor> getBitmap(int count) async {
    if (_cache.containsKey(count)) {
      return _cache[count]!;
    }

    final descriptor = await _createBitmap(count);
    _cache[count] = descriptor;
    return descriptor;
  }

  Future<BitmapDescriptor> _createBitmap(int count) async {
    const size = 140.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final center = const Offset(size / 2, size / 2);

    final paint = Paint()
      ..color = _backgroundColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, size / 2, paint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: _formatCount(count),
        style: TextStyle(
          color: _textColor,
          fontSize: count >= 100 ? 40 : 48,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )
      ..layout();

    final offset = center - Offset(textPainter.width / 2, textPainter.height / 2);
    textPainter.paint(canvas, offset);

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
  }

  String _formatCount(int count) {
    if (count < 1000) {
      return count.toString();
    }
    if (count < 10000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return '${(count / 1000).floor()}K';
  }
}
