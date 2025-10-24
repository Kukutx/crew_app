import 'package:crew_app/core/error/api_exception.dart';

import '../../../core/network/api_client.dart';
import 'event.dart';

class EventsRepository {
  EventsRepository(this._client);

  final ApiClient _client;

  Future<List<Event>> fetchEvents() async {
    final data = await _client.get('/events');
    final events = _unwrapEventList(data)
        .map(Event.fromJson)
        .toList(growable: false);

    if (events.isNotEmpty || _isKnownEmptyCollection(data)) {
      return events;
    }

    throw ApiException('Unexpected events payload type');
  }

  Future<Event> createEvent({
    required String title,
    required String location,
    required String description,
    required double latitude,
    required double longitude,
  }) async {
    final data = await _client.post(
      '/events',
      requiresAuth: true,
      data: {
        'title': title,
        'location': location,
        'description': description,
        'latitude': latitude,
        'longitude': longitude,
      },
    );

    return Event.fromJson(_unwrapEventObject(data));
  }

  Future<List<Event>> searchEvents(String query) async {
    final data = await _client.get(
      '/events/search',
      queryParameters: {'query': query},
    );

    final events = _unwrapEventList(data)
        .map(Event.fromJson)
        .toList(growable: false);

    if (events.isNotEmpty || _isKnownEmptyCollection(data)) {
      return events;
    }

    throw ApiException('Unexpected events payload type');
  }
}

bool _isKnownEmptyCollection(dynamic data) {
  if (data is List && data.isEmpty) {
    return true;
  }
  if (data is Map<String, dynamic>) {
    for (final key in const ['items', 'data', 'events', 'results', 'value']) {
      final value = data[key];
      if (value == null) {
        continue;
      }
      if (value is List && value.isEmpty) {
        return true;
      }
      if (value is Map<String, dynamic> && _isKnownEmptyCollection(value)) {
        return true;
      }
    }
  }
  return false;
}

List<Map<String, dynamic>> _unwrapEventList(dynamic data) {
  final rawList = _extractEventList(data);
  return rawList
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList(growable: false);
}

Map<String, dynamic> _unwrapEventObject(dynamic data) {
  if (data is Map<String, dynamic>) {
    for (final key in const ['data', 'event', 'result', 'value']) {
      final value = data[key];
      if (value is Map<String, dynamic>) {
        return value;
      }
    }
    return data;
  }
  throw ApiException('Unexpected event payload type');
}

List<dynamic> _extractEventList(dynamic data) {
  if (data is List<dynamic>) {
    return data;
  }
  if (data is Map<String, dynamic>) {
    for (final key in const ['items', 'data', 'events', 'results', 'value']) {
      final value = data[key];
      if (value is List<dynamic>) {
        return value;
      }
      if (value is Map<String, dynamic>) {
        final nested = _extractEventList(value);
        if (nested.isNotEmpty || _isKnownEmptyCollection(value)) {
          return nested;
        }
      }
    }
  }
  if (data == null) {
    return const <dynamic>[];
  }
  throw ApiException('Unexpected events payload type');
}
