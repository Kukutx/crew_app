import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crew_app/features/events/data/event.dart';
import 'package:crew_app/features/events/presentation/pages/map/state/events_map_search_controller.dart';
import 'package:crew_app/features/events/presentation/pages/map/controllers/map_controller.dart';
import 'package:crew_app/features/events/presentation/pages/map/controllers/event_carousel_manager.dart';

/// 搜索管理器
class SearchManager {
  SearchManager(this.ref);

  final Ref ref;
  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;

  // Getters
  TextEditingController get searchController => _searchController;
  FocusNode get searchFocusNode => _searchFocusNode;

  /// 初始化搜索管理器
  void initialize() {
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
    _searchFocusNode.addListener(_onSearchFocusChanged);
  }

  /// 搜索框焦点变化处理
  void _onSearchFocusChanged() {
    final hasFocus = _searchFocusNode.hasFocus;
    final notifier = ref.read(eventsMapSearchControllerProvider.notifier);
    
    if (hasFocus) {
      notifier.onFocusChanged(true);
      final text = _searchController.text.trim();
      if (text.isEmpty) return;
      
      final state = ref.read(eventsMapSearchControllerProvider);
      if (state.query != text && !state.isLoading) {
        notifier.onQueryChanged(text);
      }
    } else {
      notifier.onFocusChanged(false);
    }
  }

  /// 查询变化处理
  void onQueryChanged(String raw) {
    ref.read(eventsMapSearchControllerProvider.notifier).onQueryChanged(raw);
  }

  /// 搜索提交处理
  void onSearchSubmitted(String keyword) {
    ref.read(eventsMapSearchControllerProvider.notifier).onSubmitted(keyword);
  }

  /// 清除搜索
  void clearSearch() {
    _searchController.clear();
    ref.read(eventsMapSearchControllerProvider.notifier).clear();
  }

  /// 处理搜索结果点击
  void onSearchResultTap(Event event, BuildContext context) {
    FocusScope.of(context).unfocus();
    final notifier = ref.read(eventsMapSearchControllerProvider.notifier);
    notifier.selectResult(event);
    _searchController.text = event.title;
    
    // 聚焦到事件并显示卡片
    final mapController = ref.read(mapControllerProvider);
    mapController.focusOnEvent(event);
    final carouselManager = ref.read(eventCarouselManagerProvider);
    carouselManager.showEventCard(event);
  }

  /// 处理点击外部区域
  void onOutsideTap() {
    if (_searchFocusNode.hasFocus) {
      _searchFocusNode.unfocus();
    } else {
      final state = ref.read(eventsMapSearchControllerProvider);
      if (state.showResults) {
        ref.read(eventsMapSearchControllerProvider.notifier).hideResults();
      }
    }
  }

  /// 清理资源
  void dispose() {
    _searchFocusNode.removeListener(_onSearchFocusChanged);
    _searchFocusNode.dispose();
    _searchController.dispose();
  }
}

/// SearchManager的Provider
final searchManagerProvider = Provider<SearchManager>((ref) {
  final manager = SearchManager(ref);
  manager.initialize();
  return manager;
});
