import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:crew_app/features/events/data/event.dart';
import 'package:crew_app/features/events/state/events_providers.dart';
import 'package:crew_app/features/events/presentation/pages/map/controllers/map_controller.dart';
import 'package:crew_app/features/events/presentation/pages/detail/events_detail_page.dart';

/// 事件轮播管理器
class EventCarouselManager {
  EventCarouselManager(this.ref);

  final Ref ref;
  late final PageController _pageController;
  bool _isVisible = false;
  List<Event> _events = const <Event>[];

  // Getters
  PageController get pageController => _pageController;
  bool get isVisible => _isVisible;
  List<Event> get events => _events;

  /// 初始化轮播管理器
  void initialize() {
    _pageController = PageController();
  }

  /// 显示事件卡片
  void showEventCard(Event event) {
    final asyncEvents = ref.read(eventsProvider);
    final list = asyncEvents.maybeWhen(
      data: (events) => events,
      orElse: () => const <Event>[],
    );
    
    final selectedIndex = list.indexWhere((e) => e.id == event.id);
    if (selectedIndex == -1) {
      _events = <Event>[event];
      _isVisible = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pageController.hasClients) {
          _pageController.jumpToPage(0);
        }
      });
    } else {
      _events = list;
      _isVisible = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pageController.hasClients) {
          _pageController.jumpToPage(selectedIndex);
        }
      });
    }
  }

  /// 隐藏事件卡片
  void hideEventCard() {
    _isVisible = false;
    _events = const <Event>[];
  }

  /// 处理页面变化
  void onPageChanged(int index) {
    if (index < 0 || index >= _events.length) return;
    final event = _events[index];
    final mapController = ref.read(mapControllerProvider);
    mapController.moveCamera(LatLng(event.latitude, event.longitude), zoom: 14);
  }

  /// 打开事件详情
  Future<void> openEventDetails(Event event, BuildContext context) async {
    final navigator = Navigator.of(context);
    final result = await navigator.push<Event>(
      MaterialPageRoute(builder: (_) => EventDetailPage(event: event)),
    );
    if (result != null) {
      final mapController = ref.read(mapControllerProvider);
      mapController.focusOnEvent(result);
      showEventCard(result);
    }
  }

  /// 清理资源
  void dispose() {
    _pageController.dispose();
  }
}

/// EventCarouselManager的Provider
final eventCarouselManagerProvider = Provider<EventCarouselManager>((ref) {
  final manager = EventCarouselManager(ref);
  manager.initialize();
  return manager;
});
