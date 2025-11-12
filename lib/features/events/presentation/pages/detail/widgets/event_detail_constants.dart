import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 事件详情页常量定义
class EventDetailConstants {
  // 动画相关
  static const Duration headerStretchDuration = Duration(milliseconds: 220);
  static const Duration headerStretchResetDuration = Duration(milliseconds: 180);
  static const Duration fullscreenTransitionDuration = Duration(milliseconds: 220);
  
  // 尺寸相关
  static const double baseHeaderHeight = 280.0;
  static const double extraStretchHeight = 140.0;
  static const double maxCornerRadius = 28.0;
  static const double fullScreenTriggerOffset = 160.0;
  static const double topGradientHeight = 72.0;
  
  // 滚动相关
  static const double verticalDragVelocityThreshold = 650.0;
  
  // UI 间距
  static const double cardHorizontalMargin = 8.0;
  static const double cardPadding = 16.0;
  static const double sectionSpacing = 10.0;
  static const double bottomSpacing = 120.0;
  
  // 渐变透明度
  static const double gradientOpacityMin = 0.25;
  static const double gradientOpacityMax = 0.8;
  
  // 分享相关
  static const String shareImageNamePrefix = 'crew_event_';
  static const String shareImageMimeType = 'image/png';
  
  // 系统 UI
  static const SystemUiOverlayStyle transparentStatusBar = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  );
}

