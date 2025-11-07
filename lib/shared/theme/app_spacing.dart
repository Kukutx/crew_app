import 'package:crew_app/shared/utils/responsive_extensions.dart';
import 'package:flutter/material.dart';

/// 应用间距工具类
/// 
/// 提供统一的间距创建方法，自动应用响应式扩展
/// 
/// 使用示例：
/// ```dart
/// // 对称间距
/// Padding(padding: AppSpacing.symmetric(horizontal: AppDesignTokens.spacingLG))
/// 
/// // 所有方向相同间距
/// Padding(padding: AppSpacing.all(AppDesignTokens.spacingMD))
/// 
/// // 单独指定各方向
/// Padding(padding: AppSpacing.only(top: AppDesignTokens.spacingXL))
/// 
/// // SizedBox
/// SizedBox(height: AppSpacing.vertical(AppDesignTokens.spacingMD))
/// SizedBox(width: AppSpacing.horizontal(AppDesignTokens.spacingMD))
/// ```
class AppSpacing {
  AppSpacing._();

  /// 创建对称间距
  /// 
  /// [horizontal] 水平方向间距（左右）
  /// [vertical] 垂直方向间距（上下）
  static EdgeInsets symmetric({
    double? horizontal,
    double? vertical,
  }) {
    return EdgeInsets.symmetric(
      horizontal: horizontal != null ? horizontal.w : 0,
      vertical: vertical != null ? vertical.h : 0,
    );
  }

  /// 创建所有方向相同的间距
  /// 
  /// [value] 间距值（会自动应用响应式扩展）
  static EdgeInsets all(double value) {
    return EdgeInsets.all(value.r);
  }

  /// 创建单独指定各方向的间距
  /// 
  /// [top] 上间距
  /// [bottom] 下间距
  /// [left] 左间距
  /// [right] 右间距
  static EdgeInsets only({
    double? top,
    double? bottom,
    double? left,
    double? right,
  }) {
    return EdgeInsets.only(
      top: top != null ? top.h : 0,
      bottom: bottom != null ? bottom.h : 0,
      left: left != null ? left.w : 0,
      right: right != null ? right.w : 0,
    );
  }

  /// 创建垂直方向的间距（用于 SizedBox height）
  static double vertical(double value) => value.h;

  /// 创建水平方向的间距（用于 SizedBox width）
  static double horizontal(double value) => value.w;
}

