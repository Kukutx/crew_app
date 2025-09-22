// lib/features/events/presentation/events_providers.dart
import 'dart:async';
import 'dart:convert';

import 'package:crew_app/core/state/di/providers.dart';
import 'package:crew_app/core/state/settings/settings_providers.dart';
import 'package:crew_app/features/events/data/event.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

final eventsProvider =
    AutoDisposeAsyncNotifierProvider<EventsCtrl, List<Event>>(EventsCtrl.new);

class EventsCtrl extends AutoDisposeAsyncNotifier<List<Event>> {
  static const _cacheKey = 'events_cache_v1';

  Timer? _pollingTimer;

  @override
  Future<List<Event>> build() async {
    final cached = _loadCachedEvents();
    if (cached != null) {
      state = AsyncData(cached);
    }

    List<Event>? latest;

    try {
      latest = await _fetchEvents();
      state = AsyncData(latest);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace, previous: state);
    }

    _startPolling();
    return latest ?? cached ?? const <Event>[];
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
    state = const AsyncLoading<List<Event>>().copyWithPrevious(state);
    try {
      final events = await _fetchEvents();
      state = AsyncData(events);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace, previous: state);
    }
  }

  List<Event>? _loadCachedEvents() {
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      final raw = prefs.getString(_cacheKey);
      if (raw == null || raw.isEmpty) return null;
      final data = jsonDecode(raw) as List<dynamic>;
      return data
          .map((e) => Event.fromJson(Map<String, dynamic>.from(e as Map<String, dynamic>)))
          .toList();
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveEvents(List<Event> events) async {
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      final raw = jsonEncode(events.map((e) => e.toJson()).toList());
      await prefs.setString(_cacheKey, raw);
    } catch (_) {
      // Ignore persistence errors; cache is a best-effort optimisation.
    }
  }

  Future<List<Event>> _fetchEvents() async {
    final api = ref.read(apiServiceProvider);
    final events = await api.getEvents();
    await _saveEvents(events);
    return events;
  }
}
