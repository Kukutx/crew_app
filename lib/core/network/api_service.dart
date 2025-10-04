import 'package:crew_app/core/config/environment.dart';
import 'package:dio/dio.dart';

import '../../features/events/data/event.dart';
import '../../features/user/data/authenticated_user_dto.dart';
import '../error/api_exception.dart';
import 'auth/auth_service.dart';

class ApiService {
  ApiService({
    Dio? dio,
    required AuthService authService,
  })  : _dio = dio ?? Dio(BaseOptions(baseUrl: Env.current)),
        _auth = authService {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final headers = await _auth.authHeader();
          options.headers.addAll(headers);
          handler.next(options);
        },
      ),
    );

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

  Future<AuthenticatedUserDto> getAuthenticatedUserDetail() async {
    try {
      final response = await _dio.get('/User/GetAuthenticatedUserDetail');
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
        return (response.data as List)
            .map((e) => Event.fromJson(e))
            .toList();
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
      final response = await _dio.post('/events', data: {
        'title': title,
        'location': location,
        'description': description,
        'latitude': lat,
        'longitude': lng,
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Event.fromJson(response.data);
      }
      throw ApiException(
        'Failed to create event',
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

  Future<List<Event>> searchEvents(String query) async {
    try {
      final response = await _dio.get(
        '/events/search',
        queryParameters: {'query': query},
      );

      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((e) => Event.fromJson(e)).toList();
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
