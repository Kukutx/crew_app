import 'package:crew_app/features/events/presentation/widgets/city_events/data/city_event_editor_models.dart';
import 'package:crew_app/features/events/presentation/widgets/trips/data/road_trip_editor_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Events API Service（统一的事件 API 服务）
class EventsApiService {
  /// 创建自驾游活动
  Future<String> createRoadTrip(RoadTripDraft draft) async {
    // TODO: 实现真实的 API 调用
    await Future.delayed(const Duration(milliseconds: 600));
    return 'road_trip_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// 创建城市活动
  Future<String> createCityEvent(CityEventDraft draft) async {
    // TODO: 实现真实的 API 调用
    await Future.delayed(const Duration(milliseconds: 600));
    return 'city_event_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// 更新自驾游活动
  Future<void> updateRoadTrip(String id, RoadTripDraft draft) async {
    // TODO: 实现真实的 API 调用
    await Future.delayed(const Duration(milliseconds: 600));
  }

  /// 更新城市活动
  Future<void> updateCityEvent(String id, CityEventDraft draft) async {
    // TODO: 实现真实的 API 调用
    await Future.delayed(const Duration(milliseconds: 600));
  }
}

/// Events API Service Provider（统一的 Provider）
final eventsApiServiceProvider = Provider<EventsApiService>((ref) => EventsApiService());

