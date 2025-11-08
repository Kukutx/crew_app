import 'package:intl/intl.dart';

class NumberFormatHelper {
  static final NumberFormat currency = NumberFormat.simpleCurrency(locale: 'de_DE');
  static final NumberFormat _bubbleCurrency = NumberFormat.currency(
    locale: 'de_DE',
    symbol: '€',
    decimalDigits: 0,
  );
  static final NumberFormat _compactCurrency =
      NumberFormat.compactSimpleCurrency(locale: 'de_DE', name: 'EUR');

  static String shortCurrency(double value) {
    if (value >= 1000) {
      return _compactCurrency.format(value);
    }
    return _bubbleCurrency.format(value);
  }

  /// 格式化货币，超过1000时使用紧凑格式
  static String formatCurrencyCompactIfLarge(double value) {
    if (value >= 1000) {
      return _compactCurrency.format(value);
    }
    return currency.format(value);
  }
}
