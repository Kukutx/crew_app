import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../network/api_service.dart';
import '../di/providers.dart';

/// API Provider 辅助工具
/// 提供通用的 API 调用辅助方法，减少重复代码
class ApiProviderHelper {
  /// 使用 AsyncValue.guard 执行 API 调用
  /// 
  /// 这是一个通用的辅助方法，用于在 Provider 中安全地执行 API 调用
  /// 
  /// 示例：
  /// ```dart
  /// state = await ApiProviderHelper.guardApiCall(
  ///   ref,
  ///   (api) => api.getEvents(),
  /// );
  /// ```
  static Future<AsyncValue<T>> guardApiCall<T>(
    Ref ref,
    Future<T> Function(ApiService) apiCall,
  ) async {
    final api = ref.read(apiServiceProvider);
    return AsyncValue.guard(() => apiCall(api));
  }

  /// 执行 API 调用并返回结果
  /// 
  /// 这是一个简化的辅助方法，直接返回 API 调用的结果
  /// 
  /// 示例：
  /// ```dart
  /// final events = await ApiProviderHelper.callApi(
  ///   ref,
  ///   (api) => api.getEvents(),
  /// );
  /// ```
  static Future<T> callApi<T>(
    Ref ref,
    Future<T> Function(ApiService) apiCall,
  ) async {
    final api = ref.read(apiServiceProvider);
    return apiCall(api);
  }
}

