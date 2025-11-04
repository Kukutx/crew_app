// widgets/map_canvas.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:crew_app/features/events/presentation/pages/map/controllers/map_controller.dart';

/// 地图视图
class MapCanvas extends StatelessWidget {
  final LatLng initialCenter;
  final double initialZoom;
  final ValueChanged<GoogleMapController>? onMapCreated;
  final VoidCallback? onMapReady;
  final ValueChanged<LatLng>? onTap;
  final ValueChanged<LatLng>? onLongPress;
  final ValueChanged<CameraPosition>? onCameraMove;
  final VoidCallback? onCameraIdle;
  final Set<Marker> markers;
  final Set<ClusterManager> clusterManagers;
  final Set<Polyline> polylines;
  final bool showUserLocation;
  final EdgeInsets mapPadding;

  const MapCanvas({
    super.key,
    required this.initialCenter,
    this.initialZoom = 5,
    this.onMapCreated,
    this.onMapReady,
    this.onTap,
    this.onLongPress,
    this.onCameraMove,
    this.onCameraIdle,
    this.markers = const <Marker>{},
    this.clusterManagers = const <ClusterManager>{},
    this.polylines = const <Polyline>{},
    this.showUserLocation = false,
    this.mapPadding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: initialCenter,
        zoom: initialZoom,
      ),
      onMapCreated: (controller) {
        onMapCreated?.call(controller);
        onMapReady?.call();
      },
      onTap: onTap,
      onLongPress: onLongPress,
      onCameraMove: onCameraMove,
      onCameraIdle: onCameraIdle,
      markers: markers,
      clusterManagers: clusterManagers,
      polylines: polylines,
      myLocationEnabled: showUserLocation,
      zoomControlsEnabled: false,
      mapToolbarEnabled: true,
      compassEnabled: true,
      rotateGesturesEnabled: true,
      tiltGesturesEnabled: true,
      scrollGesturesEnabled: true,
      zoomGesturesEnabled: true,
      padding: mapPadding,
      style: MapController.darkThemeStyle,
    );
  }
}

