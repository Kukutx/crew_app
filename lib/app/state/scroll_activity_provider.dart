import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

/// 滚动活动状态 Provider
/// 统一管理滚动状态，包含 debounce 逻辑
final scrollActivityProvider = StateNotifierProvider<ScrollActivityNotifier, bool>(
  (ref) => ScrollActivityNotifier(),
);

class ScrollActivityNotifier extends StateNotifier<bool> {
  ScrollActivityNotifier() : super(false);

  Timer? _debounceTimer;

  /// 更新滚动状态
  /// [isScrolling] true 表示正在滚动，false 表示停止滚动
  void updateScrollActivity(bool isScrolling) {
    _debounceTimer?.cancel();
    
    if (isScrolling) {
      if (!state) {
        state = true;
      }
      return;
    }

    // 停止滚动时，延迟 300ms 后更新状态
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      // 如果 timer 仍在运行且 provider 未被销毁，更新状态
      // dispose 方法会取消 timer，所以这里不需要额外检查
      if (state) {
        state = false;
      }
    });
  }

  /// 立即重置滚动状态
  void reset() {
    _debounceTimer?.cancel();
    state = false;
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

