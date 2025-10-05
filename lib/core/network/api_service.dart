import 'package:crew_app/core/config/environment.dart';
import 'package:dio/dio.dart';

import '../../features/events/data/event.dart';
import '../../features/user/data/authenticated_user_dto.dart';
import '../../features/user/data/user_follow_summary.dart';
import '../error/api_exception.dart';
import 'auth/auth_service.dart';

class ApiService {
  ApiService({
    Dio? dio,
    required AuthService authService,
  })  : _dio = dio ?? Dio(BaseOptions(baseUrl: Env.current)),
        _auth = authService {
    _dio.interceptors.add(
      LogInterceptor(
        request: true,
        responseBody: true,
        error: true,
      ),
    );
  }

  final Dio _dio;
  final AuthService _auth;

  Future<Map<String, String>> _buildAuthHeaders({bool required = false}) async {
    final user = _auth.currentUser;
    if (user == null) {
      if (required) {
        throw ApiException('User not authenticated');
      }
      return const {};
    }

    try {
      final token = await _auth.getIdToken();
      if (token == null || token.isEmpty) {
        if (required) {
          throw ApiException('Unable to obtain authentication token');
        }
        return const {};
      }
      return {'Authorization': 'Bearer $token'};
    } catch (error) {
      if (required) {
        throw ApiException('Failed to acquire authentication token');
      }
      return const {};
    }
  }

  Future<AuthenticatedUserDto> getAuthenticatedUserDetail() async {
    try {
      final headers = await _buildAuthHeaders(required: true);
      final response = await _dio.get(
        '/User/GetAuthenticatedUserDetail',
        options: Options(headers: headers),
      );
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          return AuthenticatedUserDto.fromJson(data);
        }
        throw ApiException('Unexpected user payload type');
      }
      throw ApiException(
        'Failed to load user detail',
        statusCode: response.statusCode,
      );
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      final message = _extractErrorMessage(e) ?? 'Request error';
      throw ApiException(
        message,
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<List<UserFollowSummary>> getFollowers(String uid) async {
    final path = '/api/users/${Uri.encodeComponent(uid)}/followers';
    try {
      final response = await _dio.get(path);
      if (response.statusCode == 200 || response.statusCode == 204) {
        final items = _unwrapObjectList(response.data)
            .map(UserFollowSummary.fromJson)
            .toList(growable: false);
        if (items.isNotEmpty || _isKnownEmptyCollection(response.data)) {
          return items;
        }
        throw ApiException('Unexpected followers payload type');
      }
      throw ApiException(
        'Failed to load followers',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      final message = _extractErrorMessage(e) ?? 'Request error';
      throw ApiException(
        message,
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<List<UserFollowSummary>> getFollowing(String uid) async {
    final path = '/api/users/${Uri.encodeComponent(uid)}/following';
    try {
      final response = await _dio.get(path);
      if (response.statusCode == 200 || response.statusCode == 204) {
        final items = _unwrapObjectList(response.data)
            .map(UserFollowSummary.fromJson)
            .toList(growable: false);
        if (items.isNotEmpty || _isKnownEmptyCollection(response.data)) {
          return items;
        }
        throw ApiException('Unexpected following payload type');
      }
      throw ApiException(
        'Failed to load following',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      final message = _extractErrorMessage(e) ?? 'Request error';
      throw ApiException(
        message,
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<void> followUser(String uid) async {
    final path = '/api/users/${Uri.encodeComponent(uid)}/followers';
    try {
      final headers = await _buildAuthHeaders(required: true);
      final response = await _dio.post(
        path,
        options: Options(headers: headers),
      );
      if (!_isSuccessStatus(response.statusCode)) {
        throw ApiException(
          'Failed to follow user',
          statusCode: response.statusCode,
        );
      }
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      final message = _extractErrorMessage(e) ?? 'Request error';
      throw ApiException(
        message,
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<void> unfollowUser(String uid) async {
    final path = '/api/users/${Uri.encodeComponent(uid)}/followers';
    try {
      final headers = await _buildAuthHeaders(required: true);
      final response = await _dio.delete(
        path,
        options: Options(headers: headers),
      );
      if (!_isSuccessStatus(response.statusCode)) {
        throw ApiException(
          'Failed to unfollow user',
          statusCode: response.statusCode,
        );
      }
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      final message = _extractErrorMessage(e) ?? 'Request error';
      throw ApiException(
        message,
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<List<Event>> getEvents() async {
    try {
      final response = await _dio.get('/events');
      if (response.statusCode == 200) {
        final events = _unwrapEventList(response.data)
            .map(Event.fromJson)
            .toList(growable: false);
        if (events.isNotEmpty || _isKnownEmptyCollection(response.data)) {
          return events;
        }
        throw ApiException('Unexpected events payload type');
      }
      throw ApiException(
        'Failed to load events',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      final message = _extractErrorMessage(e) ?? 'Request error';
      throw ApiException(
        message,
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<List<Event>> getUserFavorites(String uid) async {
    final path = '/api/users/${Uri.encodeComponent(uid)}/favorites';
    try {
      final headers = await _buildAuthHeaders();
      final response = await _dio.get(
        path,
        options: Options(headers: headers.isEmpty ? null : headers),
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        final events = _unwrapEventList(response.data)
            .map(Event.fromJson)
            .toList(growable: false);
        if (events.isNotEmpty || _isKnownEmptyCollection(response.data)) {
          return events;
        }
        throw ApiException('Unexpected favorites payload type');
      }
      throw ApiException(
        'Failed to load favorites',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      final message = _extractErrorMessage(e) ?? 'Request error';
      throw ApiException(
        message,
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<void> addFavoriteEvent(String uid, String eventId) async {
    final path =
        '/api/users/${Uri.encodeComponent(uid)}/favorites/${Uri.encodeComponent(eventId)}';
    try {
      final headers = await _buildAuthHeaders(required: true);
      final response = await _dio.post(
        path,
        options: Options(headers: headers),
      );
      if (!_isSuccessStatus(response.statusCode)) {
        throw ApiException(
          'Failed to add favorite',
          statusCode: response.statusCode,
        );
      }
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      final message = _extractErrorMessage(e) ?? 'Request error';
      throw ApiException(
        message,
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<void> removeFavoriteEvent(String uid, String eventId) async {
    final path =
        '/api/users/${Uri.encodeComponent(uid)}/favorites/${Uri.encodeComponent(eventId)}';
    try {
      final headers = await _buildAuthHeaders(required: true);
      final response = await _dio.delete(
        path,
        options: Options(headers: headers),
      );
      if (!_isSuccessStatus(response.statusCode)) {
        throw ApiException(
          'Failed to remove favorite',
          statusCode: response.statusCode,
        );
      }
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      final message = _extractErrorMessage(e) ?? 'Request error';
      throw ApiException(
        message,
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<Event> createEvent(
    String title,
    String location,
    String description,
    double lat,
    double lng,
  ) async {
    try {
      final headers = await _buildAuthHeaders(required: true);
      final response = await _dio.post(
        '/events',
        data: {
          'title': title,
          'location': location,
          'description': description,
          'latitude': lat,
          'longitude': lng,
        },
        options: Options(headers: headers),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Event.fromJson(_unwrapEventObject(response.data));
      }
      throw ApiException(
        'Failed to create event',
        statusCode: response.statusCode,
      );
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      final message = _extractErrorMessage(e) ?? 'Request error';
      throw ApiException(
        message,
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<List<Event>> searchEvents(String query) async {
    try {
      final response = await _dio.get(
        '/events/search',
        queryParameters: {'query': query},
      );

      if (response.statusCode == 200) {
        final events = _unwrapEventList(response.data)
            .map(Event.fromJson)
            .toList(growable: false);
        if (events.isNotEmpty || _isKnownEmptyCollection(response.data)) {
          return events;
        }
        throw ApiException('Unexpected events payload type');
      }
      throw ApiException(
        'Failed to load events',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      final message = _extractErrorMessage(e) ?? 'Request error';
      throw ApiException(
        message,
        statusCode: e.response?.statusCode,
      );
    }
  }

String? _extractErrorMessage(DioException exception) {
    final data = exception.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
      final error = data['error'];
      if (error is String && error.isNotEmpty) {
        return error;
      }
    }
    return exception.message;
  }
}

bool _isSuccessStatus(int? statusCode) {
  if (statusCode == null) {
    return false;
  }
  return statusCode >= 200 && statusCode < 300;
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

List<Map<String, dynamic>> _unwrapObjectList(dynamic data) {
  if (data is List) {
    return data
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
  }
  if (data is Map<String, dynamic>) {
    for (final key in const ['items', 'data', 'results', 'value']) {
      final value = data[key];
      if (value is List) {
        return value
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList(growable: false);
      }
      if (value is Map<String, dynamic>) {
        final nested = _unwrapObjectList(value);
        if (nested.isNotEmpty || _isKnownEmptyCollection(value)) {
          return nested;
        }
      }
    }
  }
  if (data == null) {
    return const <Map<String, dynamic>>[];
  }
  throw ApiException('Unexpected payload type');
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
