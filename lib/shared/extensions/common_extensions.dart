import 'package:flutter/material.dart';
import '../utils/text_truncate_helper.dart';

///是用来给现有类添加新功能的方法，而不需要继承或修改原始类。它们很适合给内置类型或第三方库类型增加自定义方法。

/// 🔹 String 扩展
extension StringExt on String {
  /// 首字母大写
  String capitalize() {
    if (isEmpty) return '';
    return this[0].toUpperCase() + substring(1);
  }

  /// 是否为数字
  bool get isNumeric => double.tryParse(this) != null;

  /// 去除所有空格
  String get noSpace => replaceAll(' ', '');

  /// 截断文本（从末尾截断）
  /// 
  /// [maxLength] 最大长度（包含省略符号）
  /// [ellipsis] 省略符号，默认为 ".."
  /// 
  /// 示例：
  /// ```dart
  /// '这是一个很长的地址'.truncate(maxLength: 8); // '这是一个..'
  /// ```
  String truncate({
    required int maxLength,
    String ellipsis = '..',
  }) {
    return TextTruncateHelper.truncate(
      this,
      maxLength: maxLength,
      ellipsis: ellipsis,
    );
  }

  /// 从开头截断文本
  /// 
  /// [maxLength] 最大长度（包含省略符号）
  /// [ellipsis] 省略符号，默认为 ".."
  /// 
  /// 示例：
  /// ```dart
  /// '这是一个很长的地址'.truncateStart(maxLength: 8); // '..长的地址'
  /// ```
  String truncateStart({
    required int maxLength,
    String ellipsis = '..',
  }) {
    return TextTruncateHelper.truncateStart(
      this,
      maxLength: maxLength,
      ellipsis: ellipsis,
    );
  }

  /// 从中间截断文本
  /// 
  /// [maxLength] 最大长度（包含省略符号）
  /// [ellipsis] 省略符号，默认为 ".."
  /// 
  /// 示例：
  /// ```dart
  /// '这是一个很长的地址文本'.truncateMiddle(maxLength: 10); // '这是一个..文本'
  /// ```
  String truncateMiddle({
    required int maxLength,
    String ellipsis = '..',
  }) {
    return TextTruncateHelper.truncateMiddle(
      this,
      maxLength: maxLength,
      ellipsis: ellipsis,
    );
  }
}

/// 🔹 List 扩展
extension ListExt<T> on List<T> {
  /// 安全获取元素
  T? safeGet(int index) => (index >= 0 && index < length) ? this[index] : null;

  /// 转换为字符串，带分隔符
  String joinWith(String separator) => map((e) => e.toString()).join(separator);
}

/// 🔹 int 扩展
extension IntExt on int {
  /// 是否偶数
  bool get isEvenNum => this % 2 == 0;

  /// 是否奇数
  bool get isOddNum => this % 2 != 0;

  /// 转换为 Duration
  Duration get seconds => Duration(seconds: this);

  /// 将较大的数字格式化为更紧凑的展示形式，例如 1.2k
  String toCompactString() {
    final n = this;
    final absValue = n.abs();
    if (absValue < 1000) return toString();

    final sign = n.isNegative ? '-' : '';
    final valueInThousands = absValue / 1000;

    // 1k 到 9.9k 显示一位小数，其余直接取整
    final formatted = absValue < 10000
        ? (valueInThousands * 10).floor() / 10
        : valueInThousands.floor();

    return '$sign${formatted.toStringAsFixed(formatted % 1 == 0 ? 0 : 1)}k';
  }
}

/// 🔹 Widget 扩展
extension WidgetExt on Widget {
  /// 快速添加内边距
  Widget paddingAll(double value) =>
      Padding(padding: EdgeInsets.all(value), child: this);

  /// 快速添加圆角
  Widget withBorderRadius(double radius) =>
      ClipRRect(borderRadius: BorderRadius.circular(radius), child: this);

  /// 快速点击事件
  Widget onTap(VoidCallback onTap) =>
      GestureDetector(onTap: onTap, child: this);
}
