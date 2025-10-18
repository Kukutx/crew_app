import 'dart:async';

import 'package:crew_app/core/state/di/providers.dart';
import 'package:crew_app/features/events/data/event.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'user_location_provider.dart';

final eventsProvider =
    AsyncNotifierProvider.autoDispose<EventsCtrl, List<Event>>(EventsCtrl.new);

final mapFocusEventProvider = StateProvider<Event?>((ref) => null);

class EventsCtrl extends AsyncNotifier<List<Event>> {
  Timer? _pollingTimer;

  @override
  Future<List<Event>> build() async {
    final api = ref.read(apiServiceProvider);
    Map<String, dynamic>? query;
    final location = await ref.read(userLocationProvider.future);
    if (location != null) {
      const delta = 0.75;
      double clamp(double value, double min, double max) =>
          value < min ? min : (value > max ? max : value);
      final minLat = clamp(location.latitude - delta, -90, 90);
      final maxLat = clamp(location.latitude + delta, -90, 90);
      final minLng = clamp(location.longitude - delta, -180, 180);
      final maxLng = clamp(location.longitude + delta, -180, 180);
      query = {
        'minLat': minLat,
        'maxLat': maxLat,
        'minLng': minLng,
        'maxLng': maxLng,
        'from': DateTime.now().toUtc().toIso8601String(),
      };
    }

    final events = await api.getEvents(queryParameters: query);
    state = AsyncData(events);
    _startPolling();
    return events;
  }

  Future<Event> createEvent({
    required String title,
    required String description,
    required LatLng pos,
    required String locationName,
  }) async {
    final api = ref.read(apiServiceProvider);
    final newEv = await api.createEvent(
      title,
      locationName,
      description,
      pos.latitude,
      pos.longitude,
    );
    await _refreshEvents();
    return newEv;
  }

  // 每隔30 秒自动刷新
  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => unawaited(_refreshEvents()),
    );
    ref.onDispose(() {
      _pollingTimer?.cancel();
      _pollingTimer = null;
    });
  }

  Future<void> _refreshEvents() async {
    final api = ref.read(apiServiceProvider);
    Map<String, dynamic>? query;
    final location = await ref.read(userLocationProvider.future);
    if (location != null) {
      const delta = 0.75;
      double clamp(double value, double min, double max) =>
          value < min ? min : (value > max ? max : value);
      final minLat = clamp(location.latitude - delta, -90, 90);
      final maxLat = clamp(location.latitude + delta, -90, 90);
      final minLng = clamp(location.longitude - delta, -180, 180);
      final maxLng = clamp(location.longitude + delta, -180, 180);
      query = {
        'minLat': minLat,
        'maxLat': maxLat,
        'minLng': minLng,
        'maxLng': maxLng,
        'from': DateTime.now().toUtc().toIso8601String(),
      };
    }

    state = await AsyncValue.guard(() => api.getEvents(queryParameters: query));
  }
}
