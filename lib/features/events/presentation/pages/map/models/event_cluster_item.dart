import 'package:crew_app/features/events/data/event.dart';
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Cluster item adapter for [Event].
class EventClusterItem with ClusterItem {
  EventClusterItem(this.event)
      : _location = LatLng(event.latitude, event.longitude);

  final Event event;
  final LatLng _location;

  @override
  LatLng get location => _location;
}
