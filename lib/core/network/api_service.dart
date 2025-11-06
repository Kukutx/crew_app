import 'package:crew_app/core/config/environment.dart';
import 'package:dio/dio.dart';

import '../../features/events/data/event.dart';
import '../../features/user/data/authenticated_user_dto.dart';
import 'api_request_handler.dart';
import 'auth/auth_service.dart';
import 'response_parser.dart';

class ApiService {
  ApiService({Dio? dio, required AuthService authService})
      : _dio = dio ??
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
    _dio.interceptors.add(_RetryInterceptor(_dio));

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

    // 初始化请求处理器
    _requestHandler = ApiRequestHandler(dio: _dio, auth: _auth);
  }

  final Dio _dio;
  final AuthService _auth;
  late final ApiRequestHandler _requestHandler;

  Future<AuthenticatedUserDto> getAuthenticatedUserDetail() async {
    return _requestHandler.get<AuthenticatedUserDto>(
      path: '/User/GetAuthenticatedUserDetail',
      requiresAuth: true,
      parseResponse: (data) {
        if (data is Map<String, dynamic>) {
          return AuthenticatedUserDto.fromJson(data);
        }
        throw Exception('Unexpected user payload type');
      },
    );
  }

  Future<List<Event>> getEvents() async {
    return _requestHandler.get<List<Event>>(
      path: '/events',
      parseResponse: (data) {
        final eventList = ResponseParser.extractEventList(data);
        final events = eventList.map(Event.fromJson).toList(growable: false);
        
        // 验证数据有效性
        if (events.isNotEmpty || ResponseParser.isKnownEmptyCollection(data)) {
          return events;
        }
        throw Exception('Unexpected events payload type');
      },
    );
  }

  Future<Event> createEvent(
    String title,
    String location,
    String description,
    double lat,
    double lng,
  ) async {
    return _requestHandler.post<Event>(
      path: '/events',
      data: {
        'title': title,
        'location': location,
        'description': description,
        'latitude': lat,
        'longitude': lng,
      },
      requiresAuth: true,
      parseResponse: (data) {
        final eventData = ResponseParser.extractEventObject(data);
        return Event.fromJson(eventData);
      },
    );
  }

  Future<List<Event>> searchEvents(String query) async {
    return _requestHandler.get<List<Event>>(
      path: '/events/search',
      queryParameters: {'query': query},
      parseResponse: (data) {
        final eventList = ResponseParser.extractEventList(data);
        final events = eventList.map(Event.fromJson).toList(growable: false);
        
        // 验证数据有效性
        if (events.isNotEmpty || ResponseParser.isKnownEmptyCollection(data)) {
          return events;
        }
        throw Exception('Unexpected events payload type');
      },
    );
  }
}

/// 自定义重试拦截器，用于在网络错误时自动重试请求
class _RetryInterceptor extends Interceptor {
  /// 最大重试次数
  static const int _maxRetries = 3;

  /// 重试间隔
  static const Duration _retryInterval = Duration(seconds: 1);

  final Dio _dio;

  _RetryInterceptor(this._dio);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // 获取重试次数
    final retryCount = err.requestOptions.extra['retryCount'] as int? ?? 0;

    // 判断是否应该重试
    if (_shouldRetry(err) && retryCount < _maxRetries) {
      // 等待重试间隔
      await Future.delayed(_retryInterval);

      // 更新重试次数
      final newOptions = err.requestOptions.copyWith(
        extra: {
          ...err.requestOptions.extra,
          'retryCount': retryCount + 1,
        },
      );

      try {
        // 重新发送请求
        final response = await _dio.fetch(newOptions);
        handler.resolve(response);
        return;
      } catch (e) {
        // 如果重试失败，继续错误处理流程
        if (e is DioException) {
          handler.reject(e);
        } else {
          handler.reject(DioException(requestOptions: newOptions, error: e));
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
}
