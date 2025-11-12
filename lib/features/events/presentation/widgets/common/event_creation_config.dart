import 'package:crew_app/core/network/places/places_service.dart';
import 'package:crew_app/features/events/presentation/pages/map/controllers/location_selection_manager.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// 事件创建类型
enum EventCreationType {
  cityEvent,  // 城市活动
  roadTrip,   // 自驾游
}

/// 事件创建配置
class EventCreationConfig {
  const EventCreationConfig({
    required this.type,
    required this.showRouteTab,
    required this.showMaxMembers,
    required this.locationMode,
    this.initialRoute,
  });

  final EventCreationType type;
  final bool showRouteTab;        // 是否显示路线/途径点 Tab
  final bool showMaxMembers;      // 是否显示人数限制
  final LocationSelectionMode locationMode; // 位置选择模式
  final QuickRoadTripResult? initialRoute;   // 初始路线（自驾游）

  /// 城市活动配置
  static const cityEvent = EventCreationConfig(
    type: EventCreationType.cityEvent,
    showRouteTab: false,
    showMaxMembers: true,
    locationMode: LocationSelectionMode.singlePoint,
  );

  /// 自驾游配置
  static EventCreationConfig roadTrip({QuickRoadTripResult? initialRoute}) => EventCreationConfig(
    type: EventCreationType.roadTrip,
    showRouteTab: true,
    showMaxMembers: false,
    locationMode: LocationSelectionMode.startAndDestination,
    initialRoute: initialRoute,
  );
}

/// 位置选择模式
enum LocationSelectionMode {
  singlePoint,           // 单点（集合点）
  startAndDestination,   // 起点+终点
}

/// 单个位置的数据（封装位置相关的所有信息）
class LocationData {
  const LocationData({
    required this.title,
    required this.subtitle,
    this.onTap,
    this.onSearch,
    this.position,
    this.addressFuture,
    this.nearbyFuture,
  });

  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final VoidCallback? onSearch;
  final LatLng? position;
  final Future<String?>? addressFuture;
  final Future<List<NearbyPlace>>? nearbyFuture;
}

/// 位置选择页面数据
class LocationSelectionPageData {
  const LocationSelectionPageData({
    required this.titleKey,
    required this.subtitleKey,
    required this.firstLocation,
    this.secondLocation,
  });

  final String titleKey;
  final String subtitleKey;
  final LocationData firstLocation;
  final LocationData? secondLocation;
}

