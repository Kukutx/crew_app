import 'package:intl/intl.dart';

/// 数字格式化辅助工具
/// 提供货币格式化相关的方法
class NumberFormatHelper {
  NumberFormatHelper._(); // 私有构造函数，防止实例化

  // 标准货币格式（带小数）
  static final NumberFormat _standardCurrency = NumberFormat.simpleCurrency(locale: 'de_DE');
  
  // 整数货币格式（不带小数）
  static final NumberFormat _integerCurrency = NumberFormat.currency(
    locale: 'de_DE',
    symbol: '€',
    decimalDigits: 0,
  );
  
  // 紧凑货币格式
  static final NumberFormat _compactCurrency =
      NumberFormat.compactSimpleCurrency(locale: 'de_DE', name: 'EUR');

  /// 格式化货币（标准格式，带小数）
  /// 
  /// 示例: 123.45 → "€123.45"
  static String formatCurrency(double value) {
    return _standardCurrency.format(value);
  }

  /// 格式化货币（整数格式，不带小数）
  /// 
  /// 示例: 123.45 → "€123"
  static String formatCurrencyInteger(double value) {
    return _integerCurrency.format(value);
  }

  /// 格式化货币（智能格式）
  /// 超过1000时使用紧凑格式，否则使用整数格式
  /// 
  /// 示例: 
  /// - 123.45 → "€123"
  /// - 1234.56 → "€1K"
  static String formatCurrencyCompact(double value, {bool useIntegerForSmall = true}) {
    if (value >= 1000) {
      return _compactCurrency.format(value);
    }
    return useIntegerForSmall 
        ? _integerCurrency.format(value)
        : _standardCurrency.format(value);
  }
}
