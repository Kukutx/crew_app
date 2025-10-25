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
    this.clusterPixelRadius = 120,
    this.maxZoomForClustering = 16,
  });

  final double clusterPixelRadius;
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
    final projected = events
        .map((event) {
          final position = LatLng(event.latitude, event.longitude);
          return _ProjectedEvent(
            event: event,
            position: position,
            pixel: _project(position, worldSize),
          );
        })
        .toList(growable: false);

    final visited = List<bool>.filled(projected.length, false);
    final clusters = <EventCluster>[];
    final radius = clusterPixelRadius;

    for (var i = 0; i < projected.length; i++) {
      if (visited[i]) {
        continue;
      }

      final accumulator = _ClusterAccumulator()..add(projected[i]);
      visited[i] = true;

      for (var j = i + 1; j < projected.length; j++) {
        if (visited[j]) {
          continue;
        }

        final centroid = accumulator.centroidPixel;
        final candidate = projected[j];
        final distance = centroid.distanceTo(candidate.pixel);
        if (distance > radius) {
          continue;
        }

        visited[j] = true;
        accumulator.add(candidate);
      }

      clusters.add(accumulator.toCluster());
    }

    return clusters;
  }

  _Pixel _project(LatLng latLng, double worldSize) {
    final siny = math.sin(latLng.latitude * math.pi / 180).clamp(-0.9999, 0.9999);
    final x = (latLng.longitude + 180) / 360 * worldSize;
    final y = (0.5 - math.log((1 + siny) / (1 - siny)) / (4 * math.pi)) * worldSize;
    return _Pixel(x, y);
  }
}

class _ClusterAccumulator {
  final List<Event> _events = <Event>[];
  double _latSum = 0;
  double _lngSum = 0;
  double _pixelXSum = 0;
  double _pixelYSum = 0;

  void add(_ProjectedEvent projected) {
    final event = projected.event;
    _events.add(event);
    _latSum += projected.position.latitude;
    _lngSum += projected.position.longitude;
    _pixelXSum += projected.pixel.x;
    _pixelYSum += projected.pixel.y;
  }

  _Pixel get centroidPixel {
    final count = _events.length;
    if (count == 0) {
      return const _Pixel(0, 0);
    }
    return _Pixel(_pixelXSum / count, _pixelYSum / count);
  }

  EventCluster toCluster() {
    final count = _events.length;
    final center = LatLng(_latSum / count, _lngSum / count);
    return EventCluster(position: center, events: List<Event>.unmodifiable(_events));
  }
}

class _Pixel {
  const _Pixel(this.x, this.y);
  final double x;
  final double y;

  double distanceTo(_Pixel other) {
    final dx = x - other.x;
    final dy = y - other.y;
    return math.sqrt(dx * dx + dy * dy);
  }
}

class _ProjectedEvent {
  const _ProjectedEvent({
    required this.event,
    required this.position,
    required this.pixel,
  });

  final Event event;
  final LatLng position;
  final _Pixel pixel;
}
