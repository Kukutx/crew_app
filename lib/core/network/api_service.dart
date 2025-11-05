import 'dart:async';

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
  })  : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: Env.current,
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 30),
                sendTimeout: const Duration(seconds: 30),
              ),
            ),
        _auth = authService {
    // 添加重试拦截器（在日志拦截器之前）
    _dio.interceptors.add(_RetryInterceptor());

    // 只在开发环境启用日志，避免在生产环境泄露敏感信息
    // 生产环境日志可能包含：
    // - 认证Token
    // - 用户个人信息
    // - API密钥
    if (Env.isDevelopment) {
      _dio.interceptors.add(
        LogInterceptor(
          request: true,
          responseBody: true,
          error: true,
          requestBody: false, // 不记录请求体（可能包含敏感信息）
          requestHeader: false, // 不记录请求头（可能包含Authorization Token）
          responseHeader: false, // 不记录响应头
        ),
      );
    }
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

/// 自定义重试拦截器，用于在网络错误时自动重试请求
class _RetryInterceptor extends Interceptor {
  /// 最大重试次数
  static const int _maxRetries = 3;
  
  /// 重试间隔
  static const Duration _retryInterval = Duration(seconds: 1);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // 获取重试次数
    final retryCount = err.requestOptions.extra['retryCount'] as int? ?? 0;

    // 判断是否应该重试
    if (_shouldRetry(err) && retryCount < _maxRetries) {
      // 等待重试间隔
      await Future.delayed(_retryInterval);

      // 更新重试次数
      final newOptions = err.requestOptions;
      newOptions.extra['retryCount'] = retryCount + 1;

      try {
        // 重新发送请求
        final response = await err.requestOptions.dio.fetch(newOptions);
        handler.resolve(response);
        return;
      } catch (e) {
        // 如果重试失败，继续错误处理流程
        if (e is DioException) {
          handler.reject(e);
        } else {
          handler.reject(
            DioException(
              requestOptions: newOptions,
              error: e,
            ),
          );
        }
        return;
      }
    }

    // 不重试或达到最大重试次数，继续错误处理流程
    handler.next(err);
  }

  /// 判断是否应该重试
  /// 
  /// 仅在以下情况重试：
  /// - 连接超时
  /// - 接收超时
  /// - 发送超时
  /// - 网络错误（无响应）
  /// - 5xx 服务器错误（可重试的服务器错误）
  bool _shouldRetry(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return true;
      case DioExceptionType.badResponse:
        // 只对5xx服务器错误重试，不对4xx客户端错误重试
        final statusCode = err.response?.statusCode;
        if (statusCode != null && statusCode >= 500 && statusCode < 600) {
          return true;
        }
        return false;
      default:
        return false;
    }
  }
