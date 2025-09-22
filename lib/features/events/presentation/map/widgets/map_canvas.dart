// widgets/map_canvas.dart
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:latlong2/latlong.dart';

/// 地图视图
class MapCanvas extends StatelessWidget {
  final MapController mapController;
  final LatLng initialCenter;
  final VoidCallback? onMapReady;
  final void Function(TapPosition, LatLng)? onLongPress;
  final List<Widget> children;

  const MapCanvas({
    super.key,
    required this.mapController,
    required this.initialCenter,
    this.onMapReady,
    this.onLongPress,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: initialCenter,
        initialZoom: 5,
        onMapReady: () {
          final camera = mapController.camera;
          final bounds = camera.visibleBounds;
          if (bounds != null) {
            unawaited(_prefetchTiles(bounds, camera.zoom));
          }
          onMapReady?.call();
        },
        onLongPress: onLongPress,
        onMapEvent: (event) {
          if (event is MapEventMoveEnd) {
            final camera = mapController.camera;
            final bounds = camera.visibleBounds;
            if (bounds != null) {
              unawaited(_prefetchTiles(bounds, camera.zoom));
            }
          }
        },
      ),
      children: [
        TileLayer(
          urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
          userAgentPackageName: 'com.example.crewapp',
          tileProvider: FMTC.instance('osmTiles').getTileProvider(),
        ),
        ...children,
      ],
    );
  }
}

Future<void> _prefetchTiles(LatLngBounds bounds, double zoom) async {
  final double minZoom = math.max(0, zoom - 1);
  final double maxZoom = math.min(22, math.max(minZoom, zoom + 1));
  final store = FMTC.instance('osmTiles');

  try {
    final dynamic downloader = store.download;
    if (downloader == null) return;

    // ignore: avoid_dynamic_calls
    await downloader.prefetchRegion(
      bounds: bounds,
      minZoom: minZoom,
      maxZoom: maxZoom,
    );
  } catch (error, stackTrace) {
    debugPrint('Failed to prefetch tiles: $error');
    debugPrintStack(stackTrace: stackTrace);
  }
}
