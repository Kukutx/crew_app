import 'dart:async';

import 'package:crew_app/core/state/di/providers.dart';
import 'package:crew_app/features/events/data/event.dart';
import 'package:crew_app/features/events/data/events_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

final eventsRepositoryProvider = Provider<EventsRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return EventsRepository(client);
});

final eventsProvider =
    AsyncNotifierProvider.autoDispose<EventsCtrl, List<Event>>(EventsCtrl.new);

final mapFocusEventProvider = StateProvider<Event?>((ref) => null);

class EventsCtrl extends AsyncNotifier<List<Event>> {
  Timer? _pollingTimer;

  EventsRepository get _repository => ref.read(eventsRepositoryProvider);

  @override
  Future<List<Event>> build() async {
    final events = await _repository.fetchEvents();
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
    final newEv = await _repository.createEvent(
      title: title,
      description: description,
      latitude: pos.latitude,
      longitude: pos.longitude,
      location: locationName,
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
    state = await AsyncValue.guard(_repository.fetchEvents);
  }
}
