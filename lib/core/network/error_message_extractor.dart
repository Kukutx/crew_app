import 'package:dio/dio.dart';

/// 统一的错误消息提取工具
/// 用于从 DioException 中提取用户友好的错误消息
class ErrorMessageExtractor {
  /// 从 DioException 中提取错误消息
  /// 
  /// 优先级：
  /// 1. response.data['message'] (字符串)
  /// 2. response.data['error'] (字符串)
  /// 3. response.data['error']['message'] (嵌套对象)
  /// 4. exception.message
  static String? extract(DioException exception) {
    final data = exception.response?.data;
    if (data is Map<String, dynamic>) {
      // 尝试提取 message 字段
      final message = data['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }

      // 尝试提取 error 字段（可能是字符串或对象）
      final error = data['error'];
      if (error is String && error.isNotEmpty) {
        return error;
      }
      
      // 如果 error 是对象，尝试提取其中的 message
      if (error is Map<String, dynamic>) {
        final nestedMessage = error['message'];
        if (nestedMessage is String && nestedMessage.isNotEmpty) {
          return nestedMessage;
        }
      }
    }
    
    // 回退到异常消息
    return exception.message;
  }

  /// 提取错误消息，如果无法提取则返回默认消息
  static String extractWithDefault(
    DioException exception, {
    String defaultMessage = 'Request error',
  }) {
    return extract(exception) ?? defaultMessage;
  }
}



