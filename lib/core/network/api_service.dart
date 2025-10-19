import 'package:crew_app/core/config/environment.dart';
import 'package:crew_app/core/error/api_exception.dart';
import 'package:crew_app/core/network/auth/auth_service.dart';
import 'package:crew_app/features/models/event/event_card_dto.dart';
import 'package:crew_app/features/models/event/event_detail_dto.dart';
import 'package:crew_app/features/models/event/event_feed_response_dto.dart';
import 'package:crew_app/features/models/event/event_summary_dto.dart';
import 'package:dio/dio.dart';

class ApiService {
  ApiService({
    Dio? dio,
    required AuthService authService,
  })  : _dio = dio ?? Dio(BaseOptions(baseUrl: Env.current)),
        _auth = authService {
    _dio.options.headers['Accept'] = 'application/json';
    _dio.options.headers['x-api-version'] = '1.0';
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

  Future<List<EventSummaryDto>> searchEvents({
    double? minLng,
    double? minLat,
    double? maxLng,
    double? maxLat,
    DateTime? from,
    DateTime? to,
    String? query,
  }) async {
    try {
      final headers = await _buildAuthHeaders();
      final params = <String, dynamic>{
        if (minLng != null) 'minLng': minLng,
        if (minLat != null) 'minLat': minLat,
        if (maxLng != null) 'maxLng': maxLng,
        if (maxLat != null) 'maxLat': maxLat,
        if (from != null) 'from': from.toIso8601String(),
        if (to != null) 'to': to.toIso8601String(),
        if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
      };

      final response = await _dio.get(
        'events',
        queryParameters: params.isEmpty ? null : params,
        options: Options(headers: headers),
      );
      if (response.statusCode == 200) {
        return _parseEventSummaries(response.data);
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

  Future<EventFeedResponseDto> getEventFeed({
    required double latitude,
    required double longitude,
    required double radiusKm,
    int limit = 20,
    String? cursor,
    List<String>? tags,
  }) async {
    try {
      final headers = await _buildAuthHeaders();
      final params = <String, dynamic>{
        'lat': latitude,
        'lng': longitude,
        'radius': radiusKm,
        'limit': limit,
        if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
      };
      if (tags != null && tags.isNotEmpty) {
        params['tags'] = tags;
      }

      final response = await _dio.get(
        'events/feed',
        queryParameters: params,
        options: Options(headers: headers, listFormat: ListFormat.multi),
      );

      if (response.statusCode == 200) {
        final data = _asJsonMap(
          response.data,
          'Unexpected event feed payload type',
        );
        return EventFeedResponseDto.fromJson(data);
      }

      if (response.statusCode == 304) {
        return EventFeedResponseDto(
          events: const <EventCardDto>[],
          nextCursor: cursor,
        );
      }

      throw ApiException(
        'Failed to load event feed',
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

  Future<EventDetailDto> getEventDetail(String id) async {
    try {
      final headers = await _buildAuthHeaders();
      final response = await _dio.get(
        'events/$id',
        options: Options(headers: headers),
      );
      if (response.statusCode == 200) {
        final data = _asJsonMap(
          response.data,
          'Unexpected event detail payload type',
        );
        return EventDetailDto.fromJson(data);
      }
      throw ApiException(
        'Failed to load event detail',
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

  Future<void> registerForEvent(String id) async {
    final headers = await _buildAuthHeaders(required: true);
    try {
      final response = await _dio.post(
        'events/$id/registrations',
        options: Options(headers: headers),
      );
      if (response.statusCode == 204) {
        return;
      }
      throw ApiException(
        'Failed to register for event',
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

  Future<void> cancelEventRegistration(String id) async {
    final headers = await _buildAuthHeaders(required: true);
    try {
      final response = await _dio.delete(
        'events/$id/registrations/me',
        options: Options(headers: headers),
      );
      if (response.statusCode == 204) {
        return;
      }
      throw ApiException(
        'Failed to cancel registration',
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

  List<EventSummaryDto> _parseEventSummaries(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map>()
          .map((item) => EventSummaryDto.fromJson(
                Map<String, dynamic>.from(item),
              ))
          .toList(growable: false);
    }
    if (data is Map<String, dynamic>) {
      final value = data['events'] ?? data['items'] ?? data['data'];
      if (value != null) {
        return _parseEventSummaries(value);
      }
    }
    if (data == null) {
      return const <EventSummaryDto>[];
    }
    throw ApiException('Unexpected events payload type');
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

  Map<String, dynamic> _asJsonMap(dynamic data, String errorMessage) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    throw ApiException(errorMessage);
  }
}
