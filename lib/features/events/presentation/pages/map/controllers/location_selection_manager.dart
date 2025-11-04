import 'dart:async';
import 'dart:io';
import 'package:crew_app/core/network/places/places_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:crew_app/core/config/environment.dart';
import 'package:crew_app/core/error/api_exception.dart';
import 'package:crew_app/features/events/state/places_providers.dart';
import 'package:crew_app/features/events/state/events_providers.dart';
import 'package:crew_app/features/events/presentation/pages/map/state/map_selection_controller.dart';
import 'package:crew_app/features/events/presentation/pages/map/controllers/map_controller.dart';
import 'package:crew_app/features/events/presentation/pages/map/state/map_overlay_sheet_provider.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';

/// 位置选择管理器
class LocationSelectionManager {
  LocationSelectionManager(this.ref);

  final Ref ref;
  bool _isHandlingLongPress = false;
  NavigatorState? _activeSheetNavigator;
  Object? _activeSheetCancelResult;

  // Getters
  bool get isHandlingLongPress => _isHandlingLongPress;

  /// 处理地图长按（用于创建/更新起点和终点）
  Future<void> onMapLongPress(LatLng latlng, BuildContext context) async {
    final selectionState = ref.read(mapSelectionControllerProvider);
    
    // 如果正在选择终点，长按设置终点
    if (selectionState.isSelectingDestination) {
      _handleDestinationSelection(latlng, context);
      return;
    }
    
    // 如果正在添加途经点，长按不应该处理（途经点用单击）
    if (selectionState.isAddingWaypoint) {
      return;
    }
    
    if (_isHandlingLongPress) return;
    
    _isHandlingLongPress = true;
    try {
      await clearSelectedLocation();
      ref.read(mapSelectionControllerProvider.notifier).setSelectedLatLng(latlng);
      
      final mapController = ref.read(mapControllerProvider);
      unawaited(mapController.moveCamera(latlng, zoom: 17));
      
      // 直接显示 CreateRoadTripSheet 的启动页
      _showRoadTripCreationSheet(context, latlng);
    } finally {
      _isHandlingLongPress = false;
    }
  }

  /// 处理地图点击（用于添加途经点和其他正常点击）
  Future<void> onMapTap(LatLng position, BuildContext context) async {
    final selectionState = ref.read(mapSelectionControllerProvider);
    
    // 如果正在添加途经点，单击添加途经点（不处理终点选择）
    if (selectionState.isAddingWaypoint) {
      _handleWaypointSelection(position, context);
      return;
    }
    
    // 如果正在选择终点，单击不应该处理（终点用长按）
    if (selectionState.isSelectingDestination) {
      return;
    }
    
    // 其他正常点击：不做任何处理
  }
  
  /// 处理途经点选择
  void _handleWaypointSelection(LatLng position, BuildContext context) {
    final selectionController = ref.read(mapSelectionControllerProvider.notifier);
    final selectionState = ref.read(mapSelectionControllerProvider);
    
    if (!selectionState.isAddingWaypoint) {
      return;
    }
    
    HapticFeedback.lightImpact();
    
    // 存储临时途经点，供 CreateRoadTripSheet 监听
    selectionController.setPendingWaypoint(position);
    selectionController.setAddingWaypoint(false);
    
    // 移动相机到新添加的途经点
    final mapController = ref.read(mapControllerProvider);
    unawaited(mapController.moveCamera(position, zoom: 14));
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
    unawaited(mapController.moveCamera(position, zoom: 12));
    
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
    } on ApiException catch (error) {
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
        unawaited(mapController.moveCamera(initialDestination, zoom: 12));
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
    const offlineMessage = 'No internet connection detected.';
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

  /// 显示SnackBar
  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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
    );
    final subtitleStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurface.withValues(alpha: .7),
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
                place.displayName,
                style: titleStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (address != null && address.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  address,
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
