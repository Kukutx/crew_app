import 'package:flutter/material.dart';
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
}

/// 🔹 Widget 扩展
extension WidgetExt on Widget {
  /// 快速添加内边距
  Widget paddingAll(double value) => Padding(
        padding: EdgeInsets.all(value),
        child: this,
      );

  /// 快速添加圆角
  Widget withBorderRadius(double radius) => ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: this,
      );

  /// 快速点击事件
  Widget onTap(VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: this,
      );
}
