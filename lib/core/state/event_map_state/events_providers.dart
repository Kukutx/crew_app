// lib/features/events/presentation/events_providers.dart
import 'dart:async';

import 'package:crew_app/core/state/di/providers.dart';
import 'package:crew_app/features/events/data/event.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';


final eventsProvider =
    AutoDisposeAsyncNotifierProvider<EventsCtrl, List<Event>>(EventsCtrl.new);

class EventsCtrl extends AutoDisposeAsyncNotifier<List<Event>> {
  Timer? _pollingTimer;

  @override
  Future<List<Event>> build() async {
    final api = ref.read(apiServiceProvider);
    final events = await api.getEvents();
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
      title, locationName, description, pos.latitude, pos.longitude,
    );
    await _refreshEvents();
    return newEv;
  }

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
    state = await AsyncValue.guard(() => api.getEvents());
  }
}
