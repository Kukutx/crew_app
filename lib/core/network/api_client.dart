import 'package:dio/dio.dart';

import '../config/environment.dart';
import '../error/api_exception.dart';
import 'auth/auth_service.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';

class ApiClient {
  ApiClient({
    Dio? dio,
    required AuthService authService,
  }) : _dio = dio ?? Dio(BaseOptions(baseUrl: Env.current)) {
    _dio.interceptors.addAll([
      AuthInterceptor(authService: authService),
      ErrorInterceptor(),
      LogInterceptor(
        request: true,
        responseBody: true,
        error: true,
      ),
    ]);
  }

  final Dio _dio;

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool requiresAuth = false,
  }) async {
    final resolvedOptions = _resolveOptions(options, requiresAuth: requiresAuth);
    return _request(
      () => _dio.get<dynamic>(
        path,
        queryParameters: queryParameters,
        options: resolvedOptions,
      ),
    );
  }

  Future<dynamic> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool requiresAuth = false,
  }) async {
    final resolvedOptions = _resolveOptions(options, requiresAuth: requiresAuth);
    return _request(
      () => _dio.post<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: resolvedOptions,
      ),
    );
  }

  Future<dynamic> _request(Future<Response<dynamic>> Function() request) async {
    try {
      final response = await request();
      return response.data;
    } on DioException catch (error) {
      final apiError = error.error;
      if (apiError is ApiException) {
        throw apiError;
      }
      throw ApiException(
        apiError?.toString() ?? 'Request error',
        statusCode: error.response?.statusCode,
      );
    }
  }

  Options _resolveOptions(
    Options? options, {
    required bool requiresAuth,
  }) {
    final resolved = options ?? Options();
    if (!requiresAuth) {
      return resolved;
    }

    final extra = Map<String, dynamic>.from(resolved.extra ?? const {});
    extra['requiresAuth'] = true;
    resolved.extra = extra;
    return resolved;
  }
}
