// widgets/markers_layer.dart
import 'package:crew_app/features/events/data/event.dart';

import 'event_cluster_item.dart';

class MarkersLayer {
  final List<EventClusterItem> clusterItems;
  const MarkersLayer({required this.clusterItems});

  const MarkersLayer.empty() : clusterItems = const [];

  factory MarkersLayer.fromEvents({
    required List<Event> events,
    required void Function(Event) onEventTap,
  }) {
    final items = <EventClusterItem>[
      for (final ev in events)
        EventClusterItem(
          event: ev,
          onTap: () => onEventTap(ev),
        ),
    ];

    return MarkersLayer(clusterItems: items);
  }
}
