/// 文本截断工具类
/// 
/// 用于处理文本过长的情况，支持多种截断方式：
/// - 从末尾截断（默认）：显示前面部分，后面用".."
/// - 从开头截断：显示后面部分，前面用".."
/// - 中间截断：显示前后部分，中间用".."
/// 
/// 使用示例：
/// ```dart
/// // 从末尾截断（默认）
/// TextTruncateHelper.truncate('很长的地址文本', 10); // '很长的地址..'
/// 
/// // 从开头截断
/// TextTruncateHelper.truncateStart('很长的地址文本', 10); // '..址文本'
/// 
/// // 中间截断
/// TextTruncateHelper.truncateMiddle('很长的地址文本', 10); // '很长的..文本'
/// ```

class TextTruncateHelper {
  /// 默认的省略符号
  static const String _defaultEllipsis = '..';

  /// 从末尾截断文本（默认方式）
  /// 
  /// [text] 要截断的文本
  /// [maxLength] 最大长度（包含省略符号）
  /// [ellipsis] 省略符号，默认为 ".."
  /// 
  /// 返回：如果文本长度超过 [maxLength]，则返回截断后的文本加上省略符号
  ///       否则返回原文本
  /// 
  /// 示例：
  /// ```dart
  /// TextTruncateHelper.truncate('这是一个很长的地址', 8); // '这是一个..'
  /// TextTruncateHelper.truncate('短文本', 10); // '短文本'
  /// ```
  static String truncate(
    String text, {
    required int maxLength,
    String ellipsis = _defaultEllipsis,
  }) {
    if (text.length <= maxLength) {
      return text;
    }

    if (maxLength <= ellipsis.length) {
      return ellipsis;
    }

    final truncatedLength = maxLength - ellipsis.length;
    return '${text.substring(0, truncatedLength)}$ellipsis';
  }

  /// 从开头截断文本
  /// 
  /// [text] 要截断的文本
  /// [maxLength] 最大长度（包含省略符号）
  /// [ellipsis] 省略符号，默认为 ".."
  /// 
  /// 返回：如果文本长度超过 [maxLength]，则返回省略符号加上文本的末尾部分
  ///       否则返回原文本
  /// 
  /// 示例：
  /// ```dart
  /// TextTruncateHelper.truncateStart('这是一个很长的地址', 8); // '..长的地址'
  /// ```
  static String truncateStart(
    String text, {
    required int maxLength,
    String ellipsis = _defaultEllipsis,
  }) {
    if (text.length <= maxLength) {
      return text;
    }

    if (maxLength <= ellipsis.length) {
      return ellipsis;
    }

    final truncatedLength = maxLength - ellipsis.length;
    final startIndex = text.length - truncatedLength;
    return '$ellipsis${text.substring(startIndex)}';
  }

  /// 从中间截断文本
  /// 
  /// [text] 要截断的文本
  /// [maxLength] 最大长度（包含省略符号）
  /// [ellipsis] 省略符号，默认为 ".."
  /// 
  /// 返回：如果文本长度超过 [maxLength]，则返回文本开头部分 + 省略符号 + 文本末尾部分
  ///       否则返回原文本
  /// 
  /// 示例：
  /// ```dart
  /// TextTruncateHelper.truncateMiddle('这是一个很长的地址文本', 10); // '这是一个..文本'
  /// ```
  static String truncateMiddle(
    String text, {
    required int maxLength,
    String ellipsis = _defaultEllipsis,
  }) {
    if (text.length <= maxLength) {
      return text;
    }

    if (maxLength <= ellipsis.length) {
      return ellipsis;
    }

    final availableLength = maxLength - ellipsis.length;
    final frontLength = availableLength ~/ 2;
    final backLength = availableLength - frontLength;

    final frontPart = text.substring(0, frontLength);
    final backPart = text.substring(text.length - backLength);

    return '$frontPart$ellipsis$backPart';
  }

  /// 智能截断文本（根据文本类型自动选择截断方式）
  /// 
  /// 对于地址类文本，通常使用末尾截断更合适
  /// 
  /// [text] 要截断的文本
  /// [maxLength] 最大长度（包含省略符号）
  /// [ellipsis] 省略符号，默认为 ".."
  /// 
  /// 返回：截断后的文本
  static String smartTruncate(
    String text, {
    required int maxLength,
    String ellipsis = _defaultEllipsis,
  }) {
    // 默认使用末尾截断，适合地址等文本
    return truncate(text, maxLength: maxLength, ellipsis: ellipsis);
  }
}

