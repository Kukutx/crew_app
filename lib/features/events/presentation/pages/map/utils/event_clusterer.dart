// utils/event_clusterer.dart
import 'dart:math' as math;

import 'package:crew_app/features/events/data/event.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class EventCluster {
  EventCluster({required this.position, required List<Event> events})
      : events = List<Event>.unmodifiable(events);

  final LatLng position;
  final List<Event> events;

  int get count => events.length;
}

class EventClusterer {
  const EventClusterer({
    this.clusterPixelSize = 140,
    this.maxZoomForClustering = 16,
  });

  final double clusterPixelSize;
  final double maxZoomForClustering;

  List<EventCluster> cluster(List<Event> events, double zoom) {
    if (events.isEmpty) {
      return const <EventCluster>[];
    }

    if (zoom >= maxZoomForClustering) {
      return events
          .map(
            (event) => EventCluster(
              position: LatLng(event.latitude, event.longitude),
              events: <Event>[event],
            ),
          )
          .toList(growable: false);
    }

    final worldSize = 256 * math.pow(2.0, zoom).toDouble();
    final gridSize = clusterPixelSize;
    final buckets = <_GridKey, _ClusterBucket>{};

    for (final event in events) {
      final latLng = LatLng(event.latitude, event.longitude);
      final pixel = _project(latLng, worldSize);
      final key = _GridKey(
        (pixel.x / gridSize).floor(),
        (pixel.y / gridSize).floor(),
      );
      final bucket = buckets.putIfAbsent(key, _ClusterBucket.new);
      bucket.add(event, latLng);
    }

    return buckets.values
        .map((bucket) => bucket.toCluster())
        .toList(growable: false);
  }

  _Pixel _project(LatLng latLng, double worldSize) {
    final siny = math.sin(latLng.latitude * math.pi / 180).clamp(-0.9999, 0.9999);
    final x = (latLng.longitude + 180) / 360 * worldSize;
    final y = (0.5 - math.log((1 + siny) / (1 - siny)) / (4 * math.pi)) * worldSize;
    return _Pixel(x, y);
  }
}

class _ClusterBucket {
  final List<Event> _events = <Event>[];
  double _latSum = 0;
  double _lngSum = 0;

  void add(Event event, LatLng position) {
    _events.add(event);
    _latSum += position.latitude;
    _lngSum += position.longitude;
  }

  EventCluster toCluster() {
    final count = _events.length;
    final center = LatLng(_latSum / count, _lngSum / count);
    return EventCluster(position: center, events: _events);
  }
}

class _GridKey {
  const _GridKey(this.x, this.y);
  final int x;
  final int y;

  @override
  bool operator ==(Object other) {
    return other is _GridKey && other.x == x && other.y == y;
  }

  @override
  int get hashCode => Object.hash(x, y);
}

class _Pixel {
  const _Pixel(this.x, this.y);
  final double x;
  final double y;
}
