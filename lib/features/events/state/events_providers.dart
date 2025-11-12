import 'dart:async';

import 'package:crew_app/core/state/providers/api_provider_helper.dart';
import 'package:crew_app/core/state/di/providers.dart';
import 'package:crew_app/features/events/data/event.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

final eventsProvider =
    AsyncNotifierProvider.autoDispose<EventsCtrl, List<Event>>(EventsCtrl.new);

final mapFocusEventProvider = StateProvider<Event?>((ref) => null);

class EventsCtrl extends AsyncNotifier<List<Event>> {
  Timer? _pollingTimer;
  Future<List<Event>>? _loadingEvents;
  bool _isDisposed = false;

  @override
  Future<List<Event>> build() async {
    // 对于 AsyncNotifier，build() 方法应该直接返回数据
    // AsyncNotifier 会自动处理 state 的设置，不需要手动设置 state
    final events = await _loadEvents();
    
    // 注册销毁回调
    ref.onDispose(() {
      _isDisposed = true;
      _pollingTimer?.cancel();
      _pollingTimer = null;
    });
    
    // 延迟启动轮询，避免在 build() 期间修改 provider
    Future.microtask(() {
      if (!_isDisposed) {
        _startPolling();
      }
    });
    
    return events;
  }

  Future<Event> createEvent({
    required String title,
    required String description,
    required LatLng pos,
    required String locationName,
  }) async {
    final api = ref.read(apiServiceProvider);
    final newEv = await api.createEvent(
      title,
      locationName,
      description,
      pos.latitude,
      pos.longitude,
    );
    await _refreshEvents();
    return newEv;
  }

  /// 加载事件列表（带去重机制）
  /// 
  /// 注意：这个方法在 build() 中被调用，所以不能修改 state
  /// AsyncNotifier 会自动处理 state 的设置
  Future<List<Event>> _loadEvents() async {
    // 如果正在加载，返回现有的 Future，避免重复请求
    if (_loadingEvents != null) {
      return _loadingEvents!;
    }

    _loadingEvents = ApiProviderHelper.callApi(
      ref,
      (api) => api.getEvents(),
    );

    try {
      final events = await _loadingEvents!;
      return events;
    } finally {
      _loadingEvents = null;
    }
  }

  /// 每隔30秒自动刷新
  void _startPolling() {
    if (_isDisposed) return;
    
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) {
        if (!_isDisposed) {
          _refreshEvents();
        }
      },
    );
  }

  /// 刷新事件列表（带去重机制）
  Future<void> _refreshEvents() async {
    if (_isDisposed) return;
    
    // 如果正在加载，跳过本次刷新，避免重复请求
    if (_loadingEvents != null) {
      return;
    }

    state = await ApiProviderHelper.guardApiCall(
      ref,
      (api) => api.getEvents(),
    );
  }
}
