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
import 'package:crew_app/features/events/presentation/pages/map/sheets/location_selection_sheets.dart';
import 'package:crew_app/features/events/presentation/pages/map/sheets/start_location_sheet.dart';
import 'package:crew_app/features/events/presentation/pages/map/sheets/destination_selection_sheet.dart';
import 'package:crew_app/features/events/presentation/pages/map/sheets/map_place_details_sheet.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:crew_app/features/events/presentation/pages/trips/sheets/create_road_trip_sheet.dart';

/// 位置选择管理器
class LocationSelectionManager {
  LocationSelectionManager(this.ref);

  final Ref ref;
  bool _isHandlingLongPress = false;
  BuildContext? _selectionSheetContext;

  // Getters
  bool get isHandlingLongPress => _isHandlingLongPress;

  /// 处理地图长按
  Future<void> onMapLongPress(LatLng latlng, BuildContext context) async {
    final selectionState = ref.read(mapSelectionControllerProvider);
    if (selectionState.isSelectingDestination) {
      await _handleDestinationSelection(latlng, context);
      return;
    }
    
    if (_isHandlingLongPress) return;
    
    _isHandlingLongPress = true;
    try {
      await clearSelectedLocation();
      ref.read(mapSelectionControllerProvider.notifier).setSelectedLatLng(latlng);
      
      final mapController = ref.read(mapControllerProvider);
      await mapController.moveCamera(latlng, zoom: 17);
      await _showLocationSelectionSheet(context);
    } finally {
      _isHandlingLongPress = false;
    }
  }

  /// 处理地图点击
  Future<void> onMapTap(LatLng position, BuildContext context) async {
    final selectionState = ref.read(mapSelectionControllerProvider);
    if (selectionState.isSelectingDestination) {
      await _handleDestinationSelection(position, context);
      return;
    }

    final loc = AppLocalizations.of(context)!;
    final places = ref.read(placesServiceProvider);

    try {
      final placeId = await places.findPlaceId(position);
      if (placeId == null) {
        await showMapPlaceDetailsSheet(
          context: context,
          detailsFuture: Future<PlaceDetails?>.value(null),
          emptyMessage: loc.map_place_details_not_found,
        );
        return;
      }

      await showMapPlaceDetailsSheet(
        context: context,
        detailsFuture: places.getPlaceDetails(placeId),
        emptyMessage: loc.map_place_details_not_found,
      );
    } on PlacesApiException catch (error) {
      final message = error.message.contains('not configured')
          ? loc.map_place_details_missing_api_key
          : error.message;
      _showSnackBar(context, message.isEmpty ? loc.map_place_details_error : message);
    } catch (_) {
      _showSnackBar(context, loc.map_place_details_error);
    }
  }

  /// 处理目标位置选择
  Future<void> _handleDestinationSelection(LatLng position, BuildContext context) async {
    final selectionController = ref.read(mapSelectionControllerProvider.notifier);
    final selectionState = ref.read(mapSelectionControllerProvider);
    
    if (!selectionState.isSelectingDestination || selectionState.isSelectionSheetOpen) {
      return;
    }
    
    selectionController.setDestinationLatLng(position);
    
    final mapController = ref.read(mapControllerProvider);
    await mapController.moveCamera(position, zoom: 12);
    
    HapticFeedback.lightImpact();
    await _showDestinationSelectionSheet(context);
  }

  /// 显示位置选择Sheet
  Future<void> _showLocationSelectionSheet(BuildContext context) async {
    final selectionController = ref.read(mapSelectionControllerProvider.notifier);
    final selectionState = ref.read(mapSelectionControllerProvider);
    
    if (selectionState.selectedLatLng == null || selectionState.isSelectionSheetOpen) {
      return;
    }

    final proceed = await _presentSelectionSheet<bool>(
      context: context,
      expandedPadding: 320.0,
      builder: (sheetContext, collapsedNotifier) {
        return StartLocationSheet(
          positionListenable: selectionController.selectedLatLngListenable,
          onConfirm: () => Navigator.of(sheetContext).pop(true),
          onCancel: () => Navigator.of(sheetContext).pop(false),
          reverseGeocode: _reverseGeocode,
          fetchNearbyPlaces: selectionController.getNearbyPlaces,
          collapsedListenable: collapsedNotifier,
          onExpand: () => collapsedNotifier.value = false,
        );
      },
    );

    if (proceed != null && proceed) {
      await _beginDestinationSelection();
    } else {
      await clearSelectedLocation(dismissSheet: false);
    }
  }

  /// 开始目标位置选择
  Future<void> _beginDestinationSelection() async {
    final selectionController = ref.read(mapSelectionControllerProvider.notifier);
    final selectionState = ref.read(mapSelectionControllerProvider);
    final start = selectionState.selectedLatLng;
    
    if (start == null) {
      await clearSelectedLocation(dismissSheet: false);
      return;
    }

    selectionController.setSelectingDestination(true);
    selectionController.setDestinationLatLng(null);
    
    final mapController = ref.read(mapControllerProvider);
    await mapController.moveCamera(start, zoom: 6);
  }

  /// 显示目标位置选择Sheet
  Future<void> _showDestinationSelectionSheet(BuildContext context) async {
    final selectionController = ref.read(mapSelectionControllerProvider.notifier);
    final selectionState = ref.read(mapSelectionControllerProvider);
    
    if (!selectionState.isSelectingDestination || 
        selectionState.selectedLatLng == null ||
        selectionState.destinationLatLng == null) {
      return;
    }

    final result = await _presentSelectionSheet<QuickRoadTripResult>(
      context: context,
      expandedPadding: 360.0,
      builder: (sheetContext, collapsedNotifier) {
        return DestinationSelectionSheet(
          startPositionListenable: selectionController.selectedLatLngListenable,
          destinationListenable: selectionController.destinationLatLngListenable,
          reverseGeocode: _reverseGeocode,
          fetchNearbyPlaces: selectionController.getNearbyPlaces,
          collapsedListenable: collapsedNotifier,
          onExpand: () => collapsedNotifier.value = false,
          onCancel: () => Navigator.of(sheetContext).pop(null),
        );
      },
    );

    if (result == null) {
      await _finishDestinationFlow();
      return;
    }

    if (result.openDetailed) {
      await _finishDestinationFlow();
      await showCreateRoadTripSheet(
        context,
        initialRoute: result,
      );
      return;
    }

    if (result.destination != null) {
      await _createQuickRoadTrip(result);
    }
    await _finishDestinationFlow();
  }

  /// 完成目标位置选择流程
  Future<void> _finishDestinationFlow() async {
    await clearSelectedLocation(dismissSheet: false);
  }

  /// 创建快速行程
  Future<void> _createQuickRoadTrip(QuickRoadTripResult result) async {
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

    if (dismissSheet && selectionState.isSelectionSheetOpen && _selectionSheetContext != null) {
      Navigator.of(_selectionSheetContext!).pop(false);
      await _waitForSelectionSheetToClose();
    }

    selectionController.resetSelection();
  }

  /// 等待选择Sheet关闭
  Future<void> _waitForSelectionSheetToClose() async {
    var attempts = 0;
    while (ref.read(mapSelectionControllerProvider).isSelectionSheetOpen && attempts < 50) {
      await Future<void>.delayed(const Duration(milliseconds: 20));
      attempts++;
    }
  }

  /// 显示Sheet
  Future<T?> _presentSelectionSheet<T>({
    required BuildContext context,
    required double expandedPadding,
    required Widget Function(BuildContext sheetContext, ValueNotifier<bool> collapsedNotifier) builder,
  }) async {
    final selectionController = ref.read(mapSelectionControllerProvider.notifier);
    final media = MediaQuery.of(context);
    final collapsedHeight = media.size.height * 0.15;
    final collapsedPadding = EdgeInsets.only(bottom: collapsedHeight);
    final expandedEdgeInsets = EdgeInsets.only(bottom: expandedPadding);
    final collapsedNotifier = ValueNotifier<bool>(false);

    void updatePadding() {
      final isCollapsed = collapsedNotifier.value;
      selectionController.setMapPadding(isCollapsed ? collapsedPadding : expandedEdgeInsets);
    }

    selectionController.setSelectionSheetOpen(true);
    selectionController.setMapPadding(expandedEdgeInsets);
    collapsedNotifier.addListener(updatePadding);

    T? result;
    try {
      result = await Navigator.of(context).push<T>(
        PageRouteBuilder<T>(
          opaque: false,
          barrierDismissible: false,
          barrierColor: Colors.transparent,
          pageBuilder: (routeContext, animation, secondaryAnimation) {
            return CollapsibleSheetRouteContent<T>(
              animation: animation,
              collapsedNotifier: collapsedNotifier,
              onBackgroundTap: () => collapsedNotifier.value = true,
              builder: (sheetContext) {
                _selectionSheetContext = sheetContext;
                return builder(sheetContext, collapsedNotifier);
              },
            );
          },
        ),
      );
    } finally {
      collapsedNotifier.removeListener(updatePadding);
      collapsedNotifier.dispose();
      _selectionSheetContext = null;
      selectionController.resetMapPadding();
      selectionController.setSelectionSheetOpen(false);
    }

    return result;
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
