import 'package:dio/dio.dart';

import '../error/api_exception.dart';
import 'auth/auth_service.dart';
import 'error_message_extractor.dart';

/// API 请求处理器
/// 提供统一的请求处理逻辑，包括认证、错误处理、响应解析
class ApiRequestHandler {
  final Dio _dio;
  final AuthService _auth;

  ApiRequestHandler({
    required Dio dio,
    required AuthService auth,
  })  : _dio = dio,
        _auth = auth;

  /// 构建认证头
  /// 
  /// [required] 如果为 true，当用户未认证时抛出异常
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

  /// 执行 GET 请求
  /// 
  /// [path] 请求路径
  /// [queryParameters] 查询参数
  /// [requiresAuth] 是否需要认证
  /// [parseResponse] 响应解析函数，如果为 null 则返回原始数据
  Future<T> get<T>({
    required String path,
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = false,
    T Function(dynamic)? parseResponse,
  }) async {
    try {
      final headers = requiresAuth
          ? await _buildAuthHeaders(required: true)
          : await _buildAuthHeaders();

      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );

      return _handleResponse<T>(
        response: response,
        parseResponse: parseResponse,
        errorMessage: 'Failed to load data',
      );
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// 执行 POST 请求
  /// 
  /// [path] 请求路径
  /// [data] 请求体数据
  /// [requiresAuth] 是否需要认证
  /// [parseResponse] 响应解析函数，如果为 null 则返回原始数据
  /// [successStatusCodes] 成功状态码列表，默认为 [200, 201]
  Future<T> post<T>({
    required String path,
    dynamic data,
    bool requiresAuth = false,
    T Function(dynamic)? parseResponse,
    List<int> successStatusCodes = const [200, 201],
  }) async {
    try {
      final headers = requiresAuth
          ? await _buildAuthHeaders(required: true)
          : await _buildAuthHeaders();

      final response = await _dio.post(
        path,
        data: data,
        options: Options(headers: headers),
      );

      return _handleResponse<T>(
        response: response,
        parseResponse: parseResponse,
        errorMessage: 'Failed to create/update data',
        successStatusCodes: successStatusCodes,
      );
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// 执行 PUT 请求
  /// 
  /// [path] 请求路径
  /// [data] 请求体数据
  /// [requiresAuth] 是否需要认证
  /// [parseResponse] 响应解析函数，如果为 null 则返回原始数据
  /// [successStatusCodes] 成功状态码列表，默认为 [200]
  Future<T> put<T>({
    required String path,
    dynamic data,
    bool requiresAuth = false,
    T Function(dynamic)? parseResponse,
    List<int> successStatusCodes = const [200],
  }) async {
    try {
      final headers = requiresAuth
          ? await _buildAuthHeaders(required: true)
          : await _buildAuthHeaders();

      final response = await _dio.put(
        path,
        data: data,
        options: Options(headers: headers),
      );

      return _handleResponse<T>(
        response: response,
        parseResponse: parseResponse,
        errorMessage: 'Failed to update data',
        successStatusCodes: successStatusCodes,
      );
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// 执行 DELETE 请求
  /// 
  /// [path] 请求路径
  /// [requiresAuth] 是否需要认证
  /// [parseResponse] 响应解析函数，如果为 null 则返回原始数据
  /// [successStatusCodes] 成功状态码列表，默认为 [200, 204]
  Future<T?> delete<T>({
    required String path,
    bool requiresAuth = false,
    T Function(dynamic)? parseResponse,
    List<int> successStatusCodes = const [200, 204],
  }) async {
    try {
      final headers = requiresAuth
          ? await _buildAuthHeaders(required: true)
          : await _buildAuthHeaders();

      final response = await _dio.delete(
        path,
        options: Options(headers: headers),
      );

      // DELETE 请求可能返回 204 No Content，此时 response.data 可能为 null
      if (response.statusCode == 204) {
        return null;
      }

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
    if (successStatusCodes.contains(response.statusCode)) {
      final data = response.data;
      
      // 检查是否是 ApiResponse 格式
      if (data is Map<String, dynamic>) {
        final success = data['success'] as bool?;
        
        // 如果 success 为 false，说明是错误响应
        if (success == false) {
          final error = data['error'];
          if (error is Map<String, dynamic>) {
            final errorMessage = error['message'] as String? ?? 'An error occurred';
            throw ApiException(
              errorMessage,
              statusCode: response.statusCode,
            );
          }
          throw ApiException(
            'Request failed',
            statusCode: response.statusCode,
          );
        }
        
        // 如果 success 为 true 或未设置，提取 data 字段
        final responseData = data['data'] ?? data;
        
        if (parseResponse != null) {
          return parseResponse(responseData);
        }
        
        // 如果没有提供解析函数，尝试直接返回数据
        if (responseData is T) {
          return responseData;
        }
        
        throw ApiException(
          'Unexpected response type',
          statusCode: response.statusCode,
        );
      }
      
      // 如果不是 Map，直接处理
      if (parseResponse != null) {
        return parseResponse(data);
      }
      
      // 如果没有提供解析函数，尝试直接返回数据
      if (data is T) {
        return data;
      }
      
      throw ApiException(
        'Unexpected response type',
        statusCode: response.statusCode,
      );
    }

    throw ApiException(
      errorMessage,
      statusCode: response.statusCode,
    );
  }

  /// 处理 DioException
  ApiException _handleDioException(DioException exception) {
    final message = ErrorMessageExtractor.extractWithDefault(exception);
    return ApiException(
      message,
      statusCode: exception.response?.statusCode,
    );
  }
}








