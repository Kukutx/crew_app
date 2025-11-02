// widgets/markers_layer.dart
import 'package:crew_app/features/events/data/event.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MarkersLayer {
  final Set<Marker> markers;
  const MarkersLayer({required this.markers});

  factory MarkersLayer.fromEvents({
    required List<Event> events,
    required void Function(Event) onEventTap,
    ClusterManagerId? clusterManagerId,
  }) {
    final markers = <Marker>{
      for (final ev in events)
        Marker(
          markerId: MarkerId('event_${ev.id}'),
          position: LatLng(ev.latitude, ev.longitude),
          infoWindow: InfoWindow(title: ev.title, snippet: ev.location),
          clusterManagerId: clusterManagerId,
          consumeTapEvents: true,           // 先暂时不显示 InfoWindow
          onTap: () => onEventTap(ev),
        ),
    };

    return MarkersLayer(markers: markers);
  }
}
