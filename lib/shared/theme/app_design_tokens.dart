import 'package:flutter/material.dart';

/// 应用设计 Token 系统
/// 
/// 统一管理应用的设计规范，包括间距、圆角、字体大小、图标大小、阴影等
/// 
/// 使用示例：
/// ```dart
/// // 间距
/// SizedBox(height: AppDesignTokens.spacingMD.h)
/// Padding(padding: EdgeInsets.all(AppDesignTokens.spacingLG.r))
/// 
/// // 圆角
/// BorderRadius.circular(AppDesignTokens.radiusMD.r)
/// 
/// // 字体大小
/// TextStyle(fontSize: AppDesignTokens.fontSizeLG.sp)
/// 
/// // 图标大小
/// Icon(Icons.place, size: AppDesignTokens.iconSizeMD.sp)
/// 
/// // 阴影
/// BoxDecoration(boxShadow: AppDesignTokens.shadowMD)
/// ```
class AppDesignTokens {
  AppDesignTokens._();

  // ==================== 间距系统（基于 4px 网格） ====================
  
  /// 极小间距：4px
  static const double spacingXS = 4.0;
  
  /// 小间距：8px
  static const double spacingSM = 8.0;
  
  /// 中间距：12px
  static const double spacingMD = 12.0;
  
  /// 大间距：16px
  static const double spacingLG = 16.0;
  
  /// 超大间距：20px
  static const double spacingXL = 20.0;
  
  /// 特大间距：24px
  static const double spacingXXL = 24.0;
  
  /// 巨大间距：32px
  static const double spacingXXXL = 32.0;

  // ==================== 圆角系统 ====================
  
  /// 小圆角：8px（用于小标签、按钮等）
  static const double radiusSM = 8.0;
  
  /// 中圆角：12px（用于卡片、输入框等，主要使用）
  static const double radiusMD = 12.0;
  
  /// 大圆角：16px（用于大卡片、Sheet 等）
  static const double radiusLG = 16.0;
  
  /// 超大圆角：20px（用于底部 Sheet、大卡片等）
  static const double radiusXL = 20.0;
  
  /// 圆形：999px（用于圆形头像、FAB 等）
  static const double radiusRound = 999.0;

  // ==================== 图标大小系统 ====================
  
  /// 极小图标：16px
  static const double iconSizeXS = 16.0;
  
  /// 小图标：20px（用于列表项、标签等）
  static const double iconSizeSM = 20.0;
  
  /// 中图标：24px（主要使用）
  static const double iconSizeMD = 24.0;
  
  /// 大图标：32px
  static const double iconSizeLG = 32.0;
  
  /// 超大图标：48px（用于地图标记等）
  static const double iconSizeXL = 48.0;

  // ==================== 字体大小系统 ====================
  
  /// 极小字体：10px
  static const double fontSizeXS = 10.0;
  
  /// 小字体：12px（用于辅助文本、标签等）
  static const double fontSizeSM = 12.0;
  
  /// 中字体：14px（用于正文、输入框等，主要使用）
  static const double fontSizeMD = 14.0;
  
  /// 大字体：16px（用于强调文本）
  static const double fontSizeLG = 16.0;
  
  /// 超大字体：18px
  static const double fontSizeXL = 18.0;
  
  /// 特大字体：20px（用于标题）
  static const double fontSizeXXL = 20.0;

  // ==================== 阴影系统 ====================
  
  /// 小阴影（用于卡片悬浮效果）
  static List<BoxShadow> get shadowSM => [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];
  
  /// 中阴影（用于卡片、按钮等，主要使用）
  static List<BoxShadow> get shadowMD => [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ];
  
  /// 大阴影（用于底部 Sheet、模态框等）
  static List<BoxShadow> get shadowLG => [
        BoxShadow(
          color: Colors.black.withOpacity(0.15),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ];
  
  /// 超大阴影（用于浮动按钮、重要卡片等）
  static List<BoxShadow> get shadowXL => [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 24,
          offset: const Offset(0, 12),
        ),
      ];

  // ==================== 边框宽度 ====================
  
  /// 细边框：1px
  static const double borderWidthThin = 1.0;
  
  /// 中边框：1.5px
  static const double borderWidthMedium = 1.5;
  
  /// 粗边框：2px
  static const double borderWidthThick = 2.0;
}

