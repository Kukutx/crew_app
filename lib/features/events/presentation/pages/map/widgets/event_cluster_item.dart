import 'package:flutter/material.dart';
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:crew_app/features/events/data/event.dart';

class EventClusterItem implements ClusterItem {
  EventClusterItem({
    required this.event,
    this.onTap,
  });

  final Event event;
  final VoidCallback? onTap;

  @override
  LatLng get location => LatLng(event.latitude, event.longitude);

  void triggerTap() => onTap?.call();
}
