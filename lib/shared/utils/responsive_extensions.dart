/// 响应式布局扩展工具类
/// 
/// 使用 flutter_screenutil 实现屏幕适配
/// 基准尺寸：390x844 (iPhone 13)
/// 
/// 使用示例：
/// ```dart
/// // 响应式宽度
/// Container(width: 100.w, height: 50.h)
/// 
/// // 响应式字体
/// Text('Hello', style: TextStyle(fontSize: 16.sp))
/// 
/// // 响应式圆角
/// BorderRadius.circular(8.r)
/// 
/// // 响应式间距
/// EdgeInsets.all(12.r)
/// ```
library;

// 直接导出 flutter_screenutil 的所有扩展
export 'package:flutter_screenutil/flutter_screenutil.dart';
