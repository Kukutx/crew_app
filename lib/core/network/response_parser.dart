import '../error/api_exception.dart';

/// 响应数据解析器
/// 用于统一处理API响应的数据解包逻辑
class ResponseParser {
  /// 已知的可能包含列表数据的键名
  static const _listKeys = ['items', 'data', 'events', 'results', 'value'];

  /// 已知的可能包含对象数据的键名
  static const _objectKeys = ['data', 'event', 'result', 'value'];

  /// 从响应数据中提取列表
  /// 
  /// 支持以下格式：
  /// - 直接是 List
  /// - Map 中包含列表字段（items, data, events, results, value）
  /// - 嵌套 Map 中的列表
  static List<dynamic> extractList(dynamic data) {
    if (data is List<dynamic>) {
      return data;
    }

    if (data is Map<String, dynamic>) {
      // 尝试从已知键中提取列表
      for (final key in _listKeys) {
        final value = data[key];
        if (value is List<dynamic>) {
          return value;
        }
        // 递归处理嵌套的 Map
        if (value is Map<String, dynamic>) {
          final nested = extractList(value);
          if (nested.isNotEmpty || isKnownEmptyCollection(value)) {
            return nested;
          }
        }
      }
    }

    // 如果数据为 null，返回空列表
    if (data == null) {
      return const <dynamic>[];
    }

    throw ApiException('Unexpected list payload type');
  }

  /// 从响应数据中提取对象
  /// 
  /// 支持以下格式：
  /// - 直接是 Map<String, dynamic>
  /// - Map 中包含对象字段（data, event, result, value）
  static Map<String, dynamic> extractObject(dynamic data) {
    if (data is Map<String, dynamic>) {
      // 尝试从已知键中提取对象
      for (final key in _objectKeys) {
        final value = data[key];
        if (value is Map<String, dynamic>) {
          return value;
        }
      }
      // 如果没有找到嵌套对象，直接返回原数据
      return data;
    }

    throw ApiException('Unexpected object payload type');
  }

  /// 检查是否是已知的空集合格式
  /// 
  /// 用于区分"空列表"和"数据格式错误"
  static bool isKnownEmptyCollection(dynamic data) {
    if (data is List && data.isEmpty) {
      return true;
    }

    if (data is Map<String, dynamic>) {
      for (final key in _listKeys) {
        final value = data[key];
        if (value == null) {
          continue;
        }
        if (value is List && value.isEmpty) {
          return true;
        }
        if (value is Map<String, dynamic> && isKnownEmptyCollection(value)) {
          return true;
        }
      }
    }

    return false;
  }

  /// 将列表数据转换为类型安全的 Map 列表
  static List<Map<String, dynamic>> toMapList(List<dynamic> list) {
    return list
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
  }

  /// 从响应数据中提取并转换事件列表
  /// 
  /// 这是为了兼容现有的 Event 解析逻辑
  static List<Map<String, dynamic>> extractEventList(dynamic data) {
    try {
      final rawList = extractList(data);
      return toMapList(rawList);
    } catch (e) {
      // 如果提取失败，尝试直接处理
      if (data is List) {
        return toMapList(data);
      }
      rethrow;
    }
  }

  /// 从响应数据中提取并转换事件对象
  /// 
  /// 这是为了兼容现有的 Event 解析逻辑
  static Map<String, dynamic> extractEventObject(dynamic data) {
    return extractObject(data);
  }

  /// 从响应数据中提取 data 字段
  /// 
  /// 用于提取 ApiResponse<T> 中的 data 字段
  static dynamic extractData(dynamic data) {
    if (data is Map<String, dynamic>) {
      // 优先从 data 字段提取
      if (data.containsKey('data')) {
        return data['data'];
      }
      // 如果没有 data 字段，直接返回原数据
      return data;
    }
    return data;
  }
}

