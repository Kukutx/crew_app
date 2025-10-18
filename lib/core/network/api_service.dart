import 'package:crew_app/core/config/environment.dart';
import 'package:dio/dio.dart';

import '../../features/events/data/event.dart';
import '../../features/models/events/event_models.dart';
import '../../features/models/user/ensure_user_request.dart';
import '../../features/models/user/user_profile_dto.dart';
import '../error/api_exception.dart';
import 'auth/auth_service.dart';

class ApiService {
  ApiService({
    Dio? dio,
    required AuthService authService,
  })  : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: Env.current,
                headers: const {'Accept': 'application/json'},
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 20),
                sendTimeout: const Duration(seconds: 20),
                responseType: ResponseType.json,
              ),
            ),
        _auth = authService;

  final Dio _dio;
  final AuthService _auth;

  Map<String, String> get _versionHeaders => const {'x-api-version': '1.0'};

  Future<Map<String, String>> _buildAuthHeaders({bool required = false}) async {
    final user = _auth.currentUser;
    if (user == null) {
      if (required) {
        throw ApiException('User not authenticated');
      }
      return const <String, String>{};
    }

    try {
      final token = await _auth.getIdToken();
      if (token == null || token.isEmpty) {
        if (required) {
          throw ApiException('Unable to obtain authentication token');
        }
        return const <String, String>{};
      }
      return {'Authorization': 'Bearer $token'};
    } catch (error) {
      if (required) {
        throw ApiException('Failed to acquire authentication token');
      }
      return const <String, String>{};
    }
  }

  Future<UserProfileDto> ensureAuthenticatedUser(
    EnsureUserRequest request,
  ) async {
    try {
      final headers = {
        ..._versionHeaders,
        ...await _buildAuthHeaders(required: true),
        'Content-Type': 'application/json',
      };

      final response = await _dio.post(
        '/users/ensure',
        data: request.toJson(),
        options: Options(headers: headers),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          return UserProfileDto.fromJson(data);
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

  Future<List<Event>> getEvents({Map<String, dynamic>? queryParameters}) async {
    try {
      final headers = {
        ..._versionHeaders,
        ...await _buildAuthHeaders(),
      };

      final response = await _dio.get(
        '/events',
        queryParameters: queryParameters ??
            <String, dynamic>{
              'minLat': -90,
              'maxLat': 90,
              'minLng': -180,
              'maxLng': 180,
            },
        options: Options(headers: headers),
      );
      if (response.statusCode == 200) {
        final events = _unwrapEventList(response.data)
            .map(EventSummaryDto.fromJson)
            .map((dto) => dto.toEvent())
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

  Future<Event> createEvent(
    String title,
    String location,
    String description,
    double lat,
    double lng,
  ) async {
    try {
      final headers = {
        ..._versionHeaders,
        ...await _buildAuthHeaders(required: true),
        'Content-Type': 'application/json',
      };
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
      final headers = {
        ..._versionHeaders,
        ...await _buildAuthHeaders(),
      };

      final response = await _dio.get(
        '/events',
        queryParameters: {
          'q': query,
          'minLat': -90,
          'maxLat': 90,
          'minLng': -180,
          'maxLng': 180,
        },
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        final events = _unwrapEventList(response.data)
            .map(EventSummaryDto.fromJson)
            .map((dto) => dto.toEvent())
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
