// widgets/markers_layer.dart
import 'package:crew_app/features/events/data/event.dart';
import 'package:crew_app/features/events/state/user_location_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MarkersLayer {
  final Set<Marker> markers;
  const MarkersLayer({required this.markers});

  factory MarkersLayer.fromEvents({
    required List<Event> events,
    required UserLocation? userLocation,
    BitmapDescriptor? userLocationIcon,
    required void Function(Event) onEventTap,
  }) {
    final markers = <Marker>{
      for (final ev in events)
        Marker(
          markerId: MarkerId('event_${ev.id}'),
          position: LatLng(ev.latitude, ev.longitude),
          infoWindow: InfoWindow(title: ev.title, snippet: ev.location),
          onTap: () => onEventTap(ev),
        ),
    };

    if (userLocation != null && userLocationIcon != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('user_location'),
          position: userLocation.position,
          icon: userLocationIcon,
          flat: true,
          anchor: const Offset(0.5, 0.5),
          rotation: userLocation.heading,
          zIndex: 1000,
        ),
      );
    }

    return MarkersLayer(markers: markers);
  }
}
