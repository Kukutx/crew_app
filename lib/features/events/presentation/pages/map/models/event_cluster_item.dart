import 'package:crew_app/features/events/data/event.dart';
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class EventClusterItem with ClusterItem {
  EventClusterItem(this.event);

  final Event event;

  @override
  LatLng get location => LatLng(event.latitude, event.longitude);
}
