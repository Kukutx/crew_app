import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../error/api_exception.dart';
import 'error_message_extractor.dart';

/// API 请求处理器
/// 提供统一的请求处理逻辑，包括认证、错误处理、响应解析
class ApiRequestHandler {
  final Dio _dio;
  final FirebaseAuth _firebaseAuth;

  ApiRequestHandler({
    required Dio dio,
    required FirebaseAuth firebaseAuth,
  })  : _dio = dio,
        _firebaseAuth = firebaseAuth;

  /// 构建认证头
  Future<Map<String, String>> _buildAuthHeaders({bool required = false}) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      if (required) throw ApiException('User not authenticated');
      return const {};
    }

    final token = await user.getIdToken();
    if (token == null || token.isEmpty) {
      if (required) throw ApiException('Unable to obtain authentication token');
      return const {};
    }
    return {'Authorization': 'Bearer $token'};
  }

  /// 统一的请求执行方法
  Future<T> _executeRequest<T>({
    required Future<Response> Function(Options options) request,
    required bool requiresAuth,
    required T Function(dynamic)? parseResponse,
    required String errorMessage,
    required List<int> successStatusCodes,
  }) async {
    try {
      final headers = await _buildAuthHeaders(required: requiresAuth);
      final response = await request(Options(headers: headers));
      
      return _handleResponse<T>(
        response: response,
        parseResponse: parseResponse,
        errorMessage: errorMessage,
        successStatusCodes: successStatusCodes,
      );
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// 执行 GET 请求
  Future<T> get<T>({
    required String path,
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = false,
    T Function(dynamic)? parseResponse,
  }) => _executeRequest<T>(
    request: (options) => _dio.get(path, queryParameters: queryParameters, options: options),
    requiresAuth: requiresAuth,
    parseResponse: parseResponse,
    errorMessage: 'Failed to load data',
    successStatusCodes: const [200],
  );

  /// 执行 POST 请求
  Future<T> post<T>({
    required String path,
    dynamic data,
    bool requiresAuth = false,
    T Function(dynamic)? parseResponse,
    List<int> successStatusCodes = const [200, 201],
  }) => _executeRequest<T>(
    request: (options) => _dio.post(path, data: data, options: options),
    requiresAuth: requiresAuth,
    parseResponse: parseResponse,
    errorMessage: 'Failed to create/update data',
    successStatusCodes: successStatusCodes,
  );

  /// 执行 PUT 请求
  Future<T> put<T>({
    required String path,
    dynamic data,
    bool requiresAuth = false,
    T Function(dynamic)? parseResponse,
    List<int> successStatusCodes = const [200],
  }) => _executeRequest<T>(
    request: (options) => _dio.put(path, data: data, options: options),
    requiresAuth: requiresAuth,
    parseResponse: parseResponse,
    errorMessage: 'Failed to update data',
    successStatusCodes: successStatusCodes,
  );

  /// 执行 DELETE 请求
  Future<T?> delete<T>({
    required String path,
    bool requiresAuth = false,
    T Function(dynamic)? parseResponse,
    List<int> successStatusCodes = const [200, 204],
  }) async {
    try {
      final headers = await _buildAuthHeaders(required: requiresAuth);
      final response = await _dio.delete(path, options: Options(headers: headers));

      // DELETE 请求可能返回 204 No Content
      if (response.statusCode == 204) return null;

      return _handleResponse<T>(
        response: response,
        parseResponse: parseResponse,
        errorMessage: 'Failed to delete data',
        successStatusCodes: successStatusCodes,
      );
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// 处理响应
  T _handleResponse<T>({
    required Response response,
    T Function(dynamic)? parseResponse,
    required String errorMessage,
    List<int> successStatusCodes = const [200],
  }) {
    if (!successStatusCodes.contains(response.statusCode)) {
      throw ApiException(errorMessage, statusCode: response.statusCode);
    }

    final data = response.data;
    
    // 检查是否是 ApiResponse 格式的错误
    if (data is Map<String, dynamic> && data['success'] == false) {
      final error = data['error'];
      final message = error is Map<String, dynamic> 
          ? (error['message'] as String? ?? 'Request failed')
          : 'Request failed';
      throw ApiException(message, statusCode: response.statusCode);
    }
    
    // 提取实际数据（处理 ApiResponse 包装）
    final actualData = data is Map<String, dynamic> ? (data['data'] ?? data) : data;
    
    // 使用解析函数或直接返回
    if (parseResponse != null) return parseResponse(actualData);
    if (actualData is T) return actualData;
    
    throw ApiException('Unexpected response type', statusCode: response.statusCode);
  }

  /// 处理 DioException
  ApiException _handleDioException(DioException exception) {
    return ApiException(
      ErrorMessageExtractor.extractWithDefault(exception),
      statusCode: exception.response?.statusCode,
    );
  }
}








