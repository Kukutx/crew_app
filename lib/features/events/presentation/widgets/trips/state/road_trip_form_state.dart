import 'package:crew_app/core/network/places/places_service.dart';
import 'package:crew_app/features/events/data/event_common_models.dart';
import 'package:crew_app/features/events/presentation/widgets/trips/road_trip_editor_page.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// 自驾游表单状态
/// 
/// 管理自驾游创建表单的所有状态
class RoadTripFormState {
  // ==== 控制器 ====
  final TextEditingController titleController;
  final TextEditingController tagInputController;
  final TextEditingController storyController;
  final TextEditingController disclaimerController;

  // ==== 编辑器状态 ====
  RoadTripEditorState editorState;

  // ==== 位置信息 ====
  LatLng? startLatLng;
  LatLng? destinationLatLng;
  String? startAddress;
  String? destinationAddress;
  Future<String?>? startAddressFuture;
  Future<String?>? destinationAddressFuture;
  Future<List<NearbyPlace>>? startNearbyFuture;
  Future<List<NearbyPlace>>? destinationNearbyFuture;

  // ==== 路线 ====
  EventRouteType routeType;
  final List<LatLng> forwardWaypoints;
  final List<LatLng> returnWaypoints;
  final Map<String, String> waypointAddressCache;
  final Map<String, Future<String?>> waypointAddressFutures;
  final Map<String, String> waypointNotes;

  // ==== 团队/费用 ====
  int maxMembers;
  double? price;
  EventPricingType pricingType;

  // ==== 偏好 ====
  final List<String> tags;

  // ==== 创建状态 ====
  bool isCreating;

  // ==== 页面状态 ====
  bool canSwipe;
  int currentRoutePage;
  int? activeScrollablePageIndex;
  int? activeScrollableTabIndex;
  bool hasClickedStartContinue;

  RoadTripFormState({
    required this.titleController,
    required this.tagInputController,
    required this.storyController,
    required this.disclaimerController,
    this.editorState = const RoadTripEditorState(),
    this.startLatLng,
    this.destinationLatLng,
    this.startAddress,
    this.destinationAddress,
    this.startAddressFuture,
    this.destinationAddressFuture,
    this.startNearbyFuture,
    this.destinationNearbyFuture,
    this.routeType = EventRouteType.roundTrip,
    List<LatLng>? forwardWaypoints,
    List<LatLng>? returnWaypoints,
    Map<String, String>? waypointAddressCache,
    Map<String, Future<String?>>? waypointAddressFutures,
    Map<String, String>? waypointNotes,
    this.maxMembers = 4,
    this.price,
    this.pricingType = EventPricingType.free,
    List<String>? tags,
    this.isCreating = false,
    this.canSwipe = false,
    this.currentRoutePage = 0,
    this.activeScrollablePageIndex,
    this.activeScrollableTabIndex,
    this.hasClickedStartContinue = false,
  })  : forwardWaypoints = forwardWaypoints ?? [],
        returnWaypoints = returnWaypoints ?? [],
        waypointAddressCache = waypointAddressCache ?? {},
        waypointAddressFutures = waypointAddressFutures ?? {},
        waypointNotes = waypointNotes ?? {},
        tags = tags ?? [];

  /// 清理资源（注意：Controller 的 dispose 应该在 Widget 的 dispose 中调用）
  /// 这个方法只是标记，实际清理需要在 Widget 的 dispose 中完成
  void dispose() {
    // Controllers 的 dispose 应该在 Widget 的 dispose 中调用
    // 这里不做实际清理，只是提供接口
  }

  /// 检查基本信息是否有效
  bool isBasicValid() {
    return titleController.text.trim().isNotEmpty && editorState.dateRange != null;
  }

  /// 检查起始页是否有效
  bool isStartValid() {
    return startLatLng != null && destinationLatLng != null;
  }

  /// 检查是否可以创建
  bool canCreate() {
    return isStartValid() && isBasicValid() && !isCreating;
  }
}

