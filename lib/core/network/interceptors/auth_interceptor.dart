import 'package:dio/dio.dart';

import '../auth/auth_service.dart';
import '../../error/api_exception.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({required AuthService authService}) : _authService = authService;

  final AuthService _authService;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final requiresAuth = options.extra['requiresAuth'] == true;
    final currentUser = _authService.currentUser;

    if (currentUser == null) {
      if (requiresAuth) {
        handler.reject(
          DioException(
            requestOptions: options,
            type: DioExceptionType.unknown,
            error: ApiException('User not authenticated', statusCode: 401),
          ),
        );
        return;
      }

      handler.next(options);
      return;
    }

    _authService.authHeader().then((header) {
      if (header.isNotEmpty) {
        options.headers.addAll(header);
      }
      handler.next(options);
    }).catchError((error, stackTrace) {
      if (requiresAuth) {
        handler.reject(
          DioException(
            requestOptions: options,
            type: DioExceptionType.unknown,
            error: ApiException(
              'Failed to acquire authentication token',
              statusCode: 401,
            ),
          ),
        );
        return;
      }

      handler.next(options);
    });
  }
}
