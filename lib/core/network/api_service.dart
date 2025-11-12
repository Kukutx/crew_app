import 'package:crew_app/core/config/environment.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../features/events/data/event.dart';
import '../../features/user/data/authenticated_user_dto.dart';
import 'api_request_handler.dart';
import 'response_parser.dart';

class ApiService {
  ApiService({Dio? dio, required FirebaseAuth firebaseAuth})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: Env.current,
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 30),
                sendTimeout: const Duration(seconds: 30),
              ),
            ),
        _firebaseAuth = firebaseAuth {
    // 添加重试拦截器（在日志拦截器之前）
    _dio.interceptors.add(_RetryInterceptor(_dio));

    // 只在开发环境启用日志
    if (Env.isDevelopment) {
      _dio.interceptors.add(
        LogInterceptor(
          request: true,
          responseBody: true,
          error: true,
          requestBody: false,
          requestHeader: false,
          responseHeader: false,
        ),
      );
    }

    // 初始化请求处理器
    _requestHandler = ApiRequestHandler(dio: _dio, firebaseAuth: _firebaseAuth);
  }

  final Dio _dio;
  final FirebaseAuth _firebaseAuth;
  late final ApiRequestHandler _requestHandler;

  /// 公开的请求处理器访问方法
  /// 用于其他服务（如 LocationApiService）调用 API
  ApiRequestHandler get requestHandler => _requestHandler;

  /// 获取当前登录用户的详细信息
  /// 使用 /users/me 端点，返回完整的用户资料
  Future<AuthenticatedUserDto> getAuthenticatedUserDetail() async {
    return _requestHandler.get<AuthenticatedUserDto>(
      path: '/users/me',
      requiresAuth: true,
      parseResponse: (data) {
        // 后端返回的是 ApiResponse<UserProfileDto>，需要提取 data 字段
        if (data is Map<String, dynamic>) {
          // 如果响应是包装在 ApiResponse 中，提取 data 字段
          final responseData = data['data'] ?? data;
          if (responseData is Map<String, dynamic>) {
            // 从 UserProfileDto 中提取 uid（FirebaseUid）
            final uid = responseData['firebaseUid'] as String?;
            if (uid != null) {
              return AuthenticatedUserDto(uid: uid);
            }
          }
          // 兼容旧格式（直接是 AuthenticatedUserDto）
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
        final list = ResponseParser.extractList(data);
        return ResponseParser.toMapList(list).map(Event.fromJson).toList(growable: false);
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
      parseResponse: (data) => Event.fromJson(ResponseParser.extractObject(data)),
    );
  }

  Future<List<Event>> searchEvents(String query) async {
    return _requestHandler.get<List<Event>>(
      path: '/events/search',
      queryParameters: {'query': query},
      parseResponse: (data) {
        final list = ResponseParser.extractList(data);
        return ResponseParser.toMapList(list).map(Event.fromJson).toList(growable: false);
      },
    );
  }

  /// 更新当前用户信息
  /// 
  /// [displayName] 显示名称
  /// [bio] 简介
  /// [avatarUrl] 头像URL
  /// [coverImageUrl] 封面图片URL
  /// [gender] 性别（female, male, custom, undisclosed）
  /// [customGender] 自定义性别（当 gender 为 custom 时使用）
  /// [city] 城市
  /// [countryCode] 国家代码（ISO 格式，如 "CN"）
  /// [tags] 标签列表
  Future<Map<String, dynamic>> updateUserProfile({
    String? displayName,
    String? bio,
    String? avatarUrl,
    String? coverImageUrl,
    String? gender,
    String? customGender,
    String? city,
    String? countryCode,
    List<String>? tags,
  }) async {
    return _requestHandler.put<Map<String, dynamic>>(
      path: '/users/me',
      requiresAuth: true,
      data: {
        if (displayName != null) 'displayName': displayName,
        if (bio != null) 'bio': bio,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
        if (coverImageUrl != null) 'coverImageUrl': coverImageUrl,
        if (gender != null) 'gender': gender,
        if (customGender != null) 'customGender': customGender,
        if (city != null) 'city': city,
        if (countryCode != null) 'countryCode': countryCode,
        if (tags != null) 'tags': tags,
      },
      parseResponse: (data) {
        // 后端返回 ApiResponse<UserProfileDto>，需要提取 data 字段
        if (data is Map<String, dynamic>) {
          final responseData = data['data'] ?? data;
          if (responseData is Map<String, dynamic>) {
            return responseData;
          }
        }
        throw Exception('Unexpected user profile payload type');
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
