import 'dart:async';

import 'package:crew_app/core/error/api_exception.dart';
import 'package:crew_app/core/state/di/providers.dart';
import 'package:crew_app/features/events/data/event.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

final eventsProvider =
    AsyncNotifierProvider.autoDispose<EventsCtrl, List<Event>>(EventsCtrl.new);

final mapFocusEventProvider = StateProvider<Event?>((ref) => null);

class EventsCtrl extends AsyncNotifier<List<Event>> {
  Timer? _pollingTimer;

  @override
  Future<List<Event>> build() async {
    final events = await _loadEvents();
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
    throw ApiException('Event creation is not supported in this build.');
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

  Future<List<Event>> _loadEvents() async {
    final api = ref.read(apiServiceProvider);
    final summaries = await api.searchEvents();
    return summaries.map(Event.fromSummary).toList(growable: false);
  }

  Future<void> _refreshEvents() async {
    state = await AsyncValue.guard(_loadEvents);
  }

  Future<Event> loadEventDetail(Event event) async {
    final api = ref.read(apiServiceProvider);
    final detail = await api.getEventDetail(event.id);
    final updated = event.copyWithDetail(detail);
    state = state.whenData((events) {
      return events
          .map((item) => item.id == updated.id ? updated : item)
          .toList(growable: false);
    });
    return updated;
  }
}
