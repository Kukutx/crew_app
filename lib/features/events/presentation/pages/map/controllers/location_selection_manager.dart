import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:crew_app/core/network/places/places_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:crew_app/core/config/environment.dart';
import 'package:crew_app/core/error/api_exception.dart';
import 'package:crew_app/features/events/state/events_providers.dart';
import 'package:crew_app/features/events/presentation/pages/map/state/map_selection_controller.dart';
import 'package:crew_app/features/events/presentation/pages/map/controllers/map_controller.dart';
import 'package:crew_app/features/events/presentation/pages/map/state/map_overlay_sheet_provider.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:crew_app/shared/extensions/common_extensions.dart';

/// 位置选择管理器
class LocationSelectionManager {
  LocationSelectionManager(this.ref);

  final Ref ref;
  bool _isHandlingLongPress = false;
  NavigatorState? _activeSheetNavigator;
  Object? _activeSheetCancelResult;

  // Getters
  bool get isHandlingLongPress => _isHandlingLongPress;

  /// 处理地图长按（用于选择位置）
  Future<void> onMapLongPress(LatLng latlng, BuildContext context) async {
    final selectionState = ref.read(mapSelectionControllerProvider);
    final mapSheetType = ref.read(mapOverlaySheetProvider);
    final selectionController = ref.read(mapSelectionControllerProvider.notifier);
    final mapController = ref.read(mapControllerProvider);
    
    debugPrint('🗺️🗺️🗺️ 长按地图被触发 - mapSheetType: $mapSheetType, isSelectingDestination: ${selectionState.isSelectingDestination}, 起点: ${selectionState.selectedLatLng}, 终点: ${selectionState.destinationLatLng}');
    
    // 选择终点模式
    if (selectionState.isSelectingDestination) {
      debugPrint('📍 进入选择终点模式分支');
      _handleDestinationSelection(latlng, context);
      return;
    }
    
    // 创建城市活动模式：只有一个集合点
    if (mapSheetType == MapOverlaySheetType.createCityEvent) {
      debugPrint('🏙️ 进入创建城市活动分支');
      selectionController.setSelectedLatLng(latlng);
      unawaited(mapController.moveCamera(latlng, zoom: 17));
      return;
    }
    
    // 创建自驾游模式：需要区分起点和终点
    if (mapSheetType == MapOverlaySheetType.createRoadTrip) {
      debugPrint('🚗 进入创建自驾游分支 - 起点=${selectionState.selectedLatLng}, 终点=${selectionState.destinationLatLng}');
      
      // 如果没有起点，设置起点
      if (selectionState.selectedLatLng == null) {
        debugPrint('✅ 创建起点');
        selectionController.setSelectedLatLng(latlng);
        unawaited(mapController.moveCamera(latlng, zoom: 17));
        return;
      }
      
      // 如果有起点但没有终点，设置终点
      if (selectionState.destinationLatLng == null) {
        debugPrint('✅ 创建终点');
        selectionController.setDestinationLatLng(latlng);
        // 移动地图以显示起点和终点
        unawaited(mapController.fitBounds(
          [selectionState.selectedLatLng!, latlng],
          padding: 100,
        ));
        return;
      }
      
      debugPrint('⚠️ 起点和终点都已存在，不做任何操作');
      // 如果起点和终点都已存在，不做任何操作
      return;
    }
    
    debugPrint('🔄 进入默认分支 - 创建新的自驾游');
    
    // 默认模式：创建新的自驾游
    if (_isHandlingLongPress) return;
    _isHandlingLongPress = true;
    
    try {
      await clearSelectedLocation();
      selectionController.setSelectedLatLng(latlng);
      unawaited(mapController.moveCamera(latlng, zoom: 17));
      
      if (context.mounted) {
        _showRoadTripCreationSheet(context, latlng);
      }
    } finally {
      _isHandlingLongPress = false;
    }
  }

  /// 处理地图点击（已移除通过点击添加途经点的功能）
  Future<void> onMapTap(LatLng position, BuildContext context) async {
    final selectionState = ref.read(mapSelectionControllerProvider);
    
    // 检查点击位置是否在标记点附近（容差约50米）
    final isNearMarker = _isNearAnyMarker(position, selectionState);
    
    // 如果点击了地图空白区域（不在标记点附近），清除选中的标记点（呼吸效果）
    // 无论是否正在选择终点，都应该能够清除选中状态
    if (!isNearMarker && selectionState.draggingMarkerPosition != null) {
      ref.read(mapSelectionControllerProvider.notifier).clearDraggingMarker();
      return;
    }
    
    // 如果正在选择终点，且点击的不是标记点，不做其他处理（终点用长按）
    if (selectionState.isSelectingDestination) {
      return;
    }
    
    // 其他正常点击：不做任何处理
  }

  /// 检查点击位置是否在任何标记点附近
  bool _isNearAnyMarker(LatLng tapPosition, MapSelectionState selectionState) {
    const double toleranceMeters = 50.0; // 容差：50米
    
    // 检查起点
    if (selectionState.selectedLatLng != null) {
      final distance = _calculateDistance(tapPosition, selectionState.selectedLatLng!);
      if (distance <= toleranceMeters) {
        return true;
      }
    }
    
    // 检查终点
    if (selectionState.destinationLatLng != null) {
      final distance = _calculateDistance(tapPosition, selectionState.destinationLatLng!);
      if (distance <= toleranceMeters) {
        return true;
      }
    }
    
    // 检查去程途经点
    for (final waypoint in selectionState.forwardWaypoints) {
      final distance = _calculateDistance(tapPosition, waypoint);
      if (distance <= toleranceMeters) {
        return true;
      }
    }
    
    // 检查返程途经点
    for (final waypoint in selectionState.returnWaypoints) {
      final distance = _calculateDistance(tapPosition, waypoint);
      if (distance <= toleranceMeters) {
        return true;
      }
    }
    
    return false;
  }

  /// 计算两个经纬度之间的距离（米）
  double _calculateDistance(LatLng a, LatLng b) {
    const double earthRadius = 6371000; // 地球半径（米）
    final double dLat = (b.latitude - a.latitude) * 3.141592653589793 / 180.0;
    final double dLon = (b.longitude - a.longitude) * 3.141592653589793 / 180.0;
    final double sinDLat = math.sin(dLat / 2);
    final double sinDLon = math.sin(dLon / 2);
    final double a1 = sinDLat * sinDLat +
        math.cos(a.latitude * 3.141592653589793 / 180.0) *
            math.cos(b.latitude * 3.141592653589793 / 180.0) *
            sinDLon *
            sinDLon;
    final double c = 2 * math.atan2(math.sqrt(a1), math.sqrt(1 - a1));
    return earthRadius * c;
  }

  /// 处理目标位置选择
  void _handleDestinationSelection(LatLng position, BuildContext context) {
    final selectionController = ref.read(mapSelectionControllerProvider.notifier);
    final selectionState = ref.read(mapSelectionControllerProvider);
    
    if (!selectionState.isSelectingDestination) {
      return;
    }
    
    selectionController.setDestinationLatLng(position);
    
    final mapController = ref.read(mapControllerProvider);
    
    // 如果起点也存在，调整地图以同时显示起点和终点
    if (selectionState.selectedLatLng != null) {
      unawaited(mapController.fitBounds(
        [selectionState.selectedLatLng!, position],
        padding: 100,
      ));
    } else {
      // 如果只有终点，移动到终点位置
      unawaited(mapController.moveCamera(position, zoom: 12));
    }
    
    HapticFeedback.lightImpact();
    
    // 确保 overlay sheet 打开，CreateRoadTripSheet 会显示在 fullCreation 模式
    ref.read(mapOverlaySheetProvider.notifier).state = MapOverlaySheetType.createRoadTrip;
  }

  /// 显示自驾游创建Sheet（启动页）- 使用 overlay 模式
  void _showRoadTripCreationSheet(BuildContext context, LatLng startLatLng) {
    final selectionState = ref.read(mapSelectionControllerProvider);
    
    if (selectionState.selectedLatLng == null) {
      return;
    }

    // 获取起点地址（异步获取，不影响显示）
    unawaited(_reverseGeocode(startLatLng));

    // 使用 overlay 模式显示 CreateRoadTripSheet
    // overlay 模式下的 CreateRoadTripSheet 由 events_map_page 管理
    // 它会通过 ValueListenable 读取位置信息，显示在 fullCreation 模式
    ref.read(mapOverlaySheetProvider.notifier).state = MapOverlaySheetType.createRoadTrip;
  }

  /// 创建快速行程（公开方法）
  Future<void> createQuickRoadTrip(QuickRoadTripResult result) async {
    final destination = result.destination;
    if (destination == null) return;
    
    if (!await _ensureNetworkAvailable()) return;
    if (!await _ensureDisclaimerAccepted()) return;

    try {
      await ref.read(eventsProvider.notifier).createEvent(
        title: result.title.trim().isEmpty ? 'Quick Trip' : result.title.trim(),
        description: 'Trip from ${result.startAddress ?? 'Start'} to ${result.destinationAddress ?? 'Destination'}',
        pos: result.start,
        locationName: '${result.startAddress ?? 'Start'} → ${result.destinationAddress ?? 'Destination'}',
      );
    } on ApiException {
      // 处理错误
    } catch (_) {
      // 处理错误
    }
  }

  /// 清除选中位置
  Future<void> clearSelectedLocation({bool dismissSheet = true}) async {
    final selectionController = ref.read(mapSelectionControllerProvider.notifier);
    final selectionState = ref.read(mapSelectionControllerProvider);

    if (dismissSheet &&
        selectionState.isSelectionSheetOpen &&
        _activeSheetNavigator != null &&
        _activeSheetNavigator!.canPop()) {
      _activeSheetNavigator!.pop(_activeSheetCancelResult);
      await _waitForSelectionSheetToClose();
    }

    selectionController.resetSelection();
  }

  /// 清除途经点选择状态（只清除途经点模式，保留起点和终点）
  void clearWaypointSelection() {
    final selectionController = ref.read(mapSelectionControllerProvider.notifier);
    selectionController.setAddingWaypoint(false);
    selectionController.setPendingWaypoint(null);
    // 如果呼吸效果指向途经点，清除呼吸效果
    final state = ref.read(mapSelectionControllerProvider);
    if (state.draggingMarkerType == DraggingMarkerType.forwardWaypoint ||
        state.draggingMarkerType == DraggingMarkerType.returnWaypoint) {
      selectionController.clearDraggingMarker();
    }
  }

  /// 等待选择Sheet关闭
  Future<void> _waitForSelectionSheetToClose() async {
    var attempts = 0;
    while (ref.read(mapSelectionControllerProvider).isSelectionSheetOpen && attempts < 50) {
      await Future<void>.delayed(const Duration(milliseconds: 20));
      attempts++;
    }
  }

  /// 对外公开的反向地理编码
  Future<String?> reverseGeocode(LatLng latlng) {
    return _reverseGeocode(latlng);
  }

  /// 获取附近地点
  Future<List<NearbyPlace>> fetchNearbyPlaces(LatLng latlng) {
    return ref
        .read(mapSelectionControllerProvider.notifier)
        .getNearbyPlaces(latlng);
  }

  /// 从路线规划页重新发起位置选择
  Future<void> startRouteSelectionFlow(
    BuildContext context, {
    LatLng? initialStart,
    LatLng? initialDestination,
    bool skipStart = false,
  }) async {
    await clearSelectedLocation(dismissSheet: false);
    final selectionController = ref.read(mapSelectionControllerProvider.notifier);
    final mapController = ref.read(mapControllerProvider);

    if (initialStart != null) {
      selectionController.setSelectedLatLng(initialStart);
    }

    if (skipStart && initialStart != null) {
      // 跳过起点选择，直接进入终点选择模式
      selectionController.setSelectingDestination(true);
      if (initialDestination != null) {
        selectionController.setDestinationLatLng(initialDestination);
        // 如果起点和终点都存在，调整地图以同时显示起点和终点
        unawaited(mapController.fitBounds(
          [initialStart, initialDestination],
          padding: 100,
        ));
      } else {
        selectionController.setDestinationLatLng(null);
        unawaited(mapController.moveCamera(initialStart, zoom: 6));
      }
      // 使用 overlay 模式显示 CreateRoadTripSheet（fullCreation 模式）
      ref.read(mapOverlaySheetProvider.notifier).state = MapOverlaySheetType.createRoadTrip;
      return;
    }

    // 需要选择起点，直接使用 overlay 模式显示 CreateRoadTripSheet
    if (initialStart != null) {
      unawaited(mapController.moveCamera(initialStart, zoom: 12));
    }
    
    // 直接使用 overlay 模式显示 CreateRoadTripSheet（fullCreation 或 startLocationOnly 模式）
    // 不再使用弹窗模式，所有操作都在 overlay 内完成
    ref.read(mapOverlaySheetProvider.notifier).state = MapOverlaySheetType.createRoadTrip;
  }

  /// 反向地理编码
  Future<String?> _reverseGeocode(LatLng latlng) async {
    try {
      final list = await placemarkFromCoordinates(
        latlng.latitude,
        latlng.longitude,
      ).timeout(const Duration(seconds: 5));
      if (list.isEmpty) return null;
      return _formatPlacemark(list.first);
    } catch (_) {
      return null;
    }
  }

  /// 格式化地址信息
  String? _formatPlacemark(Placemark place) {
    final parts = [
      place.name,
      place.street,
      place.subLocality,
      place.locality,
      place.subAdministrativeArea,
      place.administrativeArea,
      place.country,
    ];
    final buffer = <String>[];
    final seen = <String>{};
    for (final part in parts) {
      if (part == null) continue;
      final trimmed = part.trim();
      if (trimmed.isEmpty || !seen.add(trimmed)) continue;
      buffer.add(trimmed);
    }
    if (buffer.isEmpty) return null;
    return buffer.join(', ');
  }

  /// 检查网络连接
  Future<bool> _ensureNetworkAvailable() async {
    final host = Uri.parse(Env.current).host;
    var lookupHost = host;

    if (lookupHost.isEmpty) {
      lookupHost = 'example.com';
    }

    if (lookupHost.isEmpty) return false;

    try {
      final result = await InternetAddress.lookup(lookupHost);
      final hasConnection = result.isNotEmpty && result.first.rawAddress.isNotEmpty;
      return hasConnection;
    } on SocketException catch (_) {
      return false;
    }
  }

  /// 检查免责声明
  Future<bool> _ensureDisclaimerAccepted() async {
    // 这里需要实现免责声明检查逻辑
    return true;
  }
}

/// LocationSelectionManager的Provider
final locationSelectionManagerProvider = Provider<LocationSelectionManager>((ref) {
  return LocationSelectionManager(ref);
});


/// Sheet手柄
class SheetHandle extends StatelessWidget {
  const SheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: .12);
    return Center(
      child: Container(
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

/// 位置Sheet行
class LocationSheetRow extends StatelessWidget {
  const LocationSheetRow({super.key, required this.icon, required this.child});

  final Icon icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        icon,
        const SizedBox(width: 8),
        Expanded(child: child),
      ],
    );
  }
}

/// 附近地点预览
class NearbyPlacesPreview extends StatelessWidget {
  const NearbyPlacesPreview({super.key, required this.future});

  final Future<List<NearbyPlace>> future;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.map_location_info_nearby_title,
          style: theme.textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        FutureBuilder<List<NearbyPlace>>(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 56,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasError) {
              return Text(
                loc.map_location_info_nearby_error,
                style: theme.textTheme.bodySmall,
              );
            }
            final places = snapshot.data;
            if (places == null || places.isEmpty) {
              return Text(
                loc.map_location_info_nearby_empty,
                style: theme.textTheme.bodySmall,
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < places.length; i++) ...[
                  NearbyPlaceTile(place: places[i]),
                  if (i < places.length - 1) const SizedBox(height: 8),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

/// 附近地点瓦片
class NearbyPlaceTile extends StatelessWidget {
  const NearbyPlaceTile({super.key, required this.place});

  final NearbyPlace place;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.w600,
      fontSize: 14,
    );
    final subtitleStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurface.withValues(alpha: .7),
      fontSize: 12,
    );
    final address = place.formattedAddress?.trim();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.place_outlined, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                place.displayName.truncateStart(maxLength: 30),
                style: titleStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (address != null && address.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  address.truncateStart(maxLength: 30),
                  style: subtitleStyle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// 快速行程结果
class QuickRoadTripResult {
  const QuickRoadTripResult({
    required this.title,
    required this.start,
    required this.destination,
    required this.startAddress,
    required this.destinationAddress,
    required this.openDetailed,
  });

  final String title;
  final LatLng start;
  final LatLng? destination;
  final String? startAddress;
  final String? destinationAddress;
  final bool openDetailed;
}
