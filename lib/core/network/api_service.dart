import 'package:crew_app/core/config/environment.dart';
import 'package:dio/dio.dart';

import '../../features/events/data/event_models.dart';
import '../../features/models/event/event_card_dto.dart';
import '../../features/models/event/event_detail_dto.dart';
import '../../features/models/event/event_feed_response_dto.dart';
import '../../features/models/event/event_summary_dto.dart';
import '../../features/models/user/ensure_user_request.dart';
import '../../features/models/user/user_profile_dto.dart';
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

  static const double _fallbackLatitude = 25.0330; // Taipei 101
  static const double _fallbackLongitude = 121.5654;

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
    } on ApiException {
      rethrow;
    } catch (_) {
      if (required) {
        throw ApiException('Failed to acquire authentication token');
      }
      return const {};
    }
  }

  Options _optionsWithHeaders(Map<String, String> headers) {
    if (headers.isEmpty) {
      return const Options();
    }
    return Options(headers: headers);
  }

  Future<UserProfileDto> ensureUserProfile(EnsureUserRequest request) async {
    final headers = await _buildAuthHeaders(required: true);
    try {
      final response = await _dio.post(
        '/users/ensure',
        data: request.toJson(),
        options: _optionsWithHeaders(headers),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = _asJsonObject(response.data);
        return UserProfileDto.fromJson(data);
      }

      throw ApiException(
        'Failed to synchronize user profile',
        statusCode: response.statusCode,
      );
    } on DioException catch (error) {
      final message = _extractErrorMessage(error) ?? 'Request error';
      throw ApiException(
        message,
        statusCode: error.response?.statusCode,
      );
    }
  }

  Future<List<Event>> getEvents({
    double? latitude,
    double? longitude,
    double radiusKm = 50,
    int? limit,
    String? cursor,
    List<String>? tags,
  }) async {
    final queryParameters = <String, dynamic>{
      'lat': (latitude ?? _fallbackLatitude).toStringAsFixed(6),
      'lng': (longitude ?? _fallbackLongitude).toStringAsFixed(6),
      'radius': radiusKm,
      if (limit != null) 'limit': limit,
      if (cursor != null) 'cursor': cursor,
    };

    if (tags != null && tags.isNotEmpty) {
      queryParameters['tags'] = tags;
    }

    final headers = await _buildAuthHeaders();

    try {
      final response = await _dio.get(
        '/events/feed',
        queryParameters: queryParameters,
        options: _optionsWithHeaders(headers),
      );

      if (response.statusCode == 200) {
        final data = _asJsonObject(response.data);
        final feed = EventFeedResponseDto.fromJson(data);
        return feed.events
            .map(Event.fromFeedCard)
            .toList(growable: false);
      }

      throw ApiException(
        'Failed to load events',
        statusCode: response.statusCode,
      );
    } on DioException catch (error) {
      final message = _extractErrorMessage(error) ?? 'Request error';
      throw ApiException(
        message,
        statusCode: error.response?.statusCode,
      );
    }
  }

  Future<Event> getEventDetail(
    String id, {
    Event? current,
  }) async {
    final headers = await _buildAuthHeaders();
    try {
      final response = await _dio.get(
        '/events/$id',
        options: _optionsWithHeaders(headers),
      );

      if (response.statusCode == 200) {
        final data = _asJsonObject(response.data);
        final dto = EventDetailDto.fromJson(data);
        return current?.mergeDetail(dto) ?? Event.fromDetail(dto);
      }

      if (response.statusCode == 404) {
        throw ApiException('Event not found', statusCode: 404);
      }

      throw ApiException(
        'Failed to load event detail',
        statusCode: response.statusCode,
      );
    } on DioException catch (error) {
      final message = _extractErrorMessage(error) ?? 'Request error';
      throw ApiException(
        message,
        statusCode: error.response?.statusCode,
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
    throw ApiException(
      'Event creation is not supported in this API version.',
    );
  }

  Future<UserProfileDto> getUserProfile(String id) async {
    try {
      final response = await _dio.get('/users/$id');
      if (response.statusCode == 200) {
        final data = _asJsonObject(response.data);
        return UserProfileDto.fromJson(data);
      }
      if (response.statusCode == 404) {
        throw ApiException('User not found', statusCode: 404);
      }
      throw ApiException(
        'Failed to load user profile',
        statusCode: response.statusCode,
      );
    } on DioException catch (error) {
      final message = _extractErrorMessage(error) ?? 'Request error';
      throw ApiException(
        message,
        statusCode: error.response?.statusCode,
      );
    }
  }

  Future<void> registerForEvent(String id) async {
    final headers = await _buildAuthHeaders(required: true);
    try {
      final response = await _dio.post(
        '/events/$id/registrations',
        options: _optionsWithHeaders(headers),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      }

      throw ApiException(
        'Failed to register for event',
        statusCode: response.statusCode,
      );
    } on DioException catch (error) {
      final message = _extractErrorMessage(error) ?? 'Request error';
      throw ApiException(
        message,
        statusCode: error.response?.statusCode,
      );
    }
  }

  Future<void> unregisterFromEvent(String id) async {
    final headers = await _buildAuthHeaders(required: true);
    try {
      final response = await _dio.delete(
        '/events/$id/registrations/me',
        options: _optionsWithHeaders(headers),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      }

      throw ApiException(
        'Failed to cancel registration',
        statusCode: response.statusCode,
      );
    } on DioException catch (error) {
      final message = _extractErrorMessage(error) ?? 'Request error';
      throw ApiException(
        message,
        statusCode: error.response?.statusCode,
      );
    }
  }

  Future<void> followUser(String id) async {
    final headers = await _buildAuthHeaders(required: true);
    try {
      final response = await _dio.post(
        '/users/$id/follow',
        options: _optionsWithHeaders(headers),
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      }
      throw ApiException(
        'Failed to follow user',
        statusCode: response.statusCode,
      );
    } on DioException catch (error) {
      final message = _extractErrorMessage(error) ?? 'Request error';
      throw ApiException(
        message,
        statusCode: error.response?.statusCode,
      );
    }
  }

  Future<void> unfollowUser(String id) async {
    final headers = await _buildAuthHeaders(required: true);
    try {
      final response = await _dio.delete(
        '/users/$id/follow',
        options: _optionsWithHeaders(headers),
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      }
      throw ApiException(
        'Failed to unfollow user',
        statusCode: response.statusCode,
      );
    } on DioException catch (error) {
      final message = _extractErrorMessage(error) ?? 'Request error';
      throw ApiException(
        message,
        statusCode: error.response?.statusCode,
      );
    }
  }

  Future<List<Event>> searchEvents(
    String query, {
    double? minLng,
    double? minLat,
    double? maxLng,
    double? maxLat,
    DateTime? from,
    DateTime? to,
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return const <Event>[];
    }

    final queryParameters = <String, dynamic>{'q': trimmed};

    void addParam(String key, double? value) {
      if (value != null) {
        queryParameters[key] = value;
      }
    }

    addParam('minLng', minLng);
    addParam('minLat', minLat);
    addParam('maxLng', maxLng);
    addParam('maxLat', maxLat);

    if (from != null) {
      queryParameters['from'] = from.toIso8601String();
    }
    if (to != null) {
      queryParameters['to'] = to.toIso8601String();
    }

    final headers = await _buildAuthHeaders();

    try {
      final response = await _dio.get(
        '/events',
        queryParameters: queryParameters,
        options: _optionsWithHeaders(headers),
      );

      if (response.statusCode == 200) {
        final list = _asJsonList(response.data);
        return list
            .map(EventSummaryDto.fromJson)
            .map(Event.fromSummary)
            .toList(growable: false);
      }

      throw ApiException(
        'Failed to search events',
        statusCode: response.statusCode,
      );
    } on DioException catch (error) {
      final message = _extractErrorMessage(error) ?? 'Request error';
      throw ApiException(
        message,
        statusCode: error.response?.statusCode,
      );
    }
  }

  String? _extractErrorMessage(DioException exception) {
    final data = exception.response?.data;
    if (data is Map<String, dynamic>) {
      final title = data['title'];
      if (title is String && title.isNotEmpty) {
        return title;
      }

      final detail = data['detail'];
      if (detail is String && detail.isNotEmpty) {
        return detail;
      }

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

  Map<String, dynamic> _asJsonObject(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    throw ApiException('Unexpected response format');
  }

  List<Map<String, dynamic>> _asJsonList(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList(growable: false);
    }
    if (data is Map<String, dynamic>) {
      final possibleKeys = ['items', 'data', 'events', 'results', 'value'];
      for (final key in possibleKeys) {
        final value = data[key];
        if (value is List) {
          return value
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .toList(growable: false);
        }
      }
    }
    throw ApiException('Unexpected response format');
  }
}
