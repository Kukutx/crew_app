// widgets/map_canvas.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
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
        onMapReady: onMapReady,
        onLongPress: onLongPress,
      ),
      children: [
        TileLayer(
          urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
          userAgentPackageName: 'com.example.crewapp',
          tileProvider: NetworkTileProvider(),    // 禁用磁盘缓存（如果不需要可删）
        ),
        ...children,
      ],
    );
  }
}
