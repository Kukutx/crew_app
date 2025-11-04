/// JSON 数据解析辅助工具类
/// 提供通用的 JSON 到 Dart 类型转换方法
class JsonParserHelper {
  /// 将动态值解析为字符串
  static String? parseString(dynamic value) => value?.toString();

  /// 将动态值解析为 double
  static double? parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  /// 将动态值解析为 int
  static int? parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  /// 将动态值解析为 bool
  static bool? parseBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is num) return value != 0;
    final lower = value.toString().toLowerCase();
    if (lower == 'true' || lower == 'yes' || lower == '1') {
      return true;
    }
    if (lower == 'false' || lower == 'no' || lower == '0') {
      return false;
    }
    return null;
  }

  /// 将动态值解析为 DateTime
  static DateTime? parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }

  /// 将动态值解析为字符串列表
  static List<String> parseStringList(dynamic value) {
    Iterable<dynamic>? list;
    if (value is Iterable<dynamic>) {
      list = value;
    } else if (value != null) {
      list = const [];
    }
    if (list == null) return const <String>[];
    return list
        .map((item) => item?.toString())
        .where((item) => item != null)
        .map((item) => item!.trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }

  /// 将动态值转换为 Map
  static Map<String, dynamic>? asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    return null;
  }
}
