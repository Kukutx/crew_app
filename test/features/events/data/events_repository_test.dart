import 'package:crew_app/core/error/api_exception.dart';
import 'package:crew_app/core/network/api_client.dart';
import 'package:crew_app/features/events/data/event.dart';
import 'package:crew_app/features/events/data/events_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeApiClient implements ApiClient {
  FakeApiClient({this.getHandler, this.postHandler});

  final Future<dynamic> Function(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool requiresAuth,
  })?
      getHandler;

  final Future<dynamic> Function(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool requiresAuth,
  })?
      postHandler;

  String? lastGetPath;
  Map<String, dynamic>? lastGetQueryParameters;
  bool? lastGetRequiresAuth;

  String? lastPostPath;
  dynamic lastPostData;
  Map<String, dynamic>? lastPostQueryParameters;
  bool? lastPostRequiresAuth;

  dynamic getResponse;
  dynamic postResponse;

  @override
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool requiresAuth = false,
  }) async {
    lastGetPath = path;
    lastGetQueryParameters = queryParameters;
    lastGetRequiresAuth = requiresAuth;
    if (getHandler != null) {
      return getHandler!(
        path,
        queryParameters: queryParameters,
        options: options,
        requiresAuth: requiresAuth,
      );
    }
    return getResponse;
  }

  @override
  Future<dynamic> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool requiresAuth = false,
  }) async {
    lastPostPath = path;
    lastPostData = data;
    lastPostQueryParameters = queryParameters;
    lastPostRequiresAuth = requiresAuth;
    if (postHandler != null) {
      return postHandler!(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        requiresAuth: requiresAuth,
      );
    }
    return postResponse;
  }
}

void main() {
  group('EventsRepository', () {
    const eventPayload = {
      'id': '1',
      'title': 'Morning Ride',
      'location': 'Central Park',
      'description': 'Join us for a ride',
      'latitude': 12.3,
      'longitude': 45.6,
      'media': {
        'images': <String>[],
      },
    };

    test('fetchEvents parses data list', () async {
      final fakeClient = FakeApiClient()
        ..getResponse = {
          'data': [eventPayload],
        };
      final repository = EventsRepository(fakeClient);

      final events = await repository.fetchEvents();

      expect(events, hasLength(1));
      expect(events.first, isA<Event>());
      expect(events.first.title, equals('Morning Ride'));
      expect(fakeClient.lastGetPath, equals('/events'));
      expect(fakeClient.lastGetRequiresAuth, isFalse);
    });

    test('createEvent posts payload with auth', () async {
      final fakeClient = FakeApiClient()
        ..postResponse = {
          'data': eventPayload,
        };
      final repository = EventsRepository(fakeClient);

      final event = await repository.createEvent(
        title: 'Morning Ride',
        description: 'Join us for a ride',
        latitude: 12.3,
        longitude: 45.6,
        location: 'Central Park',
      );

      expect(event.title, equals('Morning Ride'));
      expect(fakeClient.lastPostPath, equals('/events'));
      expect(fakeClient.lastPostRequiresAuth, isTrue);
      expect(fakeClient.lastPostData, equals({
        'title': 'Morning Ride',
        'location': 'Central Park',
        'description': 'Join us for a ride',
        'latitude': 12.3,
        'longitude': 45.6,
      }));
    });

    test('searchEvents forwards query parameter', () async {
      final fakeClient = FakeApiClient()
        ..getResponse = {
          'data': [eventPayload],
        };
      final repository = EventsRepository(fakeClient);

      final results = await repository.searchEvents('ride');

      expect(results, hasLength(1));
      expect(fakeClient.lastGetPath, equals('/events/search'));
      expect(fakeClient.lastGetQueryParameters, equals({'query': 'ride'}));
      expect(fakeClient.lastGetRequiresAuth, isFalse);
    });

    test('throws ApiException on unexpected payload', () async {
      final fakeClient = FakeApiClient()
        ..getResponse = {'unexpected': 'value'};
      final repository = EventsRepository(fakeClient);

      expect(repository.fetchEvents, throwsA(isA<ApiException>()));
    });
  });
}
