// widgets/markers_layer.dart
import 'package:crew_app/features/events/data/event.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../utils/event_clusterer.dart';

class MarkersLayer {
  final Set<Marker> markers;
  const MarkersLayer({required this.markers});

  factory MarkersLayer.fromEvents({
    required List<Event> events,
    required void Function(Event) onEventTap,
    required double zoom,
    required BitmapDescriptor Function(int) clusterIconProvider,
    required void Function(LatLng) onClusterTap,
    EventClusterer clusterer = const EventClusterer(),
  }) {
    final clusters = clusterer.cluster(events, zoom);
    if (clusters.isEmpty) {
      return const MarkersLayer(markers: <Marker>{});
    }

    final markers = <Marker>{};
    var clusterIndex = 0;

    for (final cluster in clusters) {
      if (cluster.count == 1) {
        final ev = cluster.events.first;
        markers.add(
          Marker(
            markerId: MarkerId('event_${ev.id}'),
            position: LatLng(ev.latitude, ev.longitude),
            infoWindow: InfoWindow(title: ev.title, snippet: ev.location),
            consumeTapEvents: true, // 先暂时不显示 InfoWindow，因为点击老是会切换地图信息
            onTap: () => onEventTap(ev),
          ),
        );
        continue;
      }

      final icon = clusterIconProvider(cluster.count);
      markers.add(
        Marker(
          markerId: MarkerId('cluster_${clusterIndex++}_${cluster.count}'),
          position: cluster.position,
          icon: icon,
          consumeTapEvents: true,
          onTap: () => onClusterTap(cluster.position),
          infoWindow: InfoWindow(title: '${cluster.count} 个活动'),
        ),
      );
    }

    return MarkersLayer(markers: markers);
  }
}
