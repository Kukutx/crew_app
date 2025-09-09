// widgets/markers_layer.dart
import 'package:crew_app/features/events/data/event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';


class MarkersLayer extends StatelessWidget {
  final List<Marker> markers;
  const MarkersLayer({super.key, required this.markers});

  factory MarkersLayer.fromEvents({
    required List<Event> events,
    required LatLng? userLoc,
    required void Function(Event) onEventTap,
  }) {
    final list = <Marker>[
      ...events.map((ev) => Marker(
            width: 80,
            height: 80,
            point: LatLng(ev.latitude, ev.longitude),
            child: GestureDetector(
              onTap: () => onEventTap(ev),
              child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
            ),
          )),
      if (userLoc != null)
        Marker(
          point: userLoc,
          width: 80,
          height: 80,
          child: const Icon(Icons.location_pin, color: Colors.blue, size: 40),
        ),
    ];
    return MarkersLayer(markers: list);
  }

  @override
  Widget build(BuildContext context) => MarkerLayer(markers: markers);
}
