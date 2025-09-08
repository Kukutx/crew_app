// lib/features/events/presentation/events_providers.dart
import 'package:crew_app/core/state/di/providers.dart';
import 'package:crew_app/features/events/data/event.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';


final eventsProvider =
    AsyncNotifierProvider<EventsCtrl, List<Event>>(EventsCtrl.new);

class EventsCtrl extends AsyncNotifier<List<Event>> {
  @override
  Future<List<Event>> build() async {
    final api = ref.read(apiServiceProvider);
    return api.getEvents();
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
    // 追加到列表
    final curr = state.value ?? const <Event>[];
    state = AsyncData([...curr, newEv]);
    return newEv;
  }
}
