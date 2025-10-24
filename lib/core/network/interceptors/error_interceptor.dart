import 'package:dio/dio.dart';

import '../../error/api_exception.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.error is ApiException) {
      handler.reject(err);
      return;
    }

    final message = _extractErrorMessage(err) ?? 'Request error';
    handler.reject(
      err.copyWith(
        error: ApiException(
          message,
          statusCode: err.response?.statusCode,
        ),
      ),
    );
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
