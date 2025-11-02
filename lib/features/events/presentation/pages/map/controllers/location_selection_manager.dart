import 'dart:async';
import 'dart:io';
import 'package:crew_app/core/network/places/places_service.dart';
import 'package:flutter/material.dart';
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
import 'package:crew_app/features/events/presentation/pages/map/sheets/map_place_details_sheet.dart';
import 'package:crew_app/features/events/presentation/pages/map/state/map_overlay_sheet_provider.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';

/// 位置选择管理器
class LocationSelectionManager {
  LocationSelectionManager(this.ref);

  final Ref ref;
  bool _isHandlingLongPress = false;

  // Getters
  bool get isHandlingLongPress => _isHandlingLongPress;

  /// 处理地图长按
  Future<void> onMapLongPress(LatLng latlng, BuildContext context) async {
    if (_isHandlingLongPress) return;
    
    _isHandlingLongPress = true;
    try {
      await clearSelectedLocation(dismissSheet: false);
      final selectionController =
          ref.read(mapSelectionControllerProvider.notifier);
      selectionController.setSelectedLatLng(latlng);
      selectionController.setDestinationLatLng(null);
      selectionController.setSelectingDestination(false);
      selectionController.setSelectionSheetOpen(true);

      final mapController = ref.read(mapControllerProvider);
      await mapController.moveCamera(latlng, zoom: 17);
      ref.read(mapOverlaySheetProvider.notifier).state =
          MapOverlaySheetType.roadTripCreate;
    } finally {
      _isHandlingLongPress = false;
    }
  }

  /// 处理地图点击
  Future<void> onMapTap(LatLng position, BuildContext context) async {
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

  Future<String?> geocodeAddress(LatLng latlng) => _reverseGeocode(latlng);

  Future<void> createRoadTrip(QuickRoadTripResult result) =>
      _createQuickRoadTrip(result);

  Future<void> clearSelectedLocation({bool dismissSheet = true}) async {
    final selectionController = ref.read(mapSelectionControllerProvider.notifier);
    if (dismissSheet) {
      // 兼容旧调用，实际关闭由外部控制。
    }
    selectionController.resetSelection();
    selectionController.setSelectingDestination(false);
    selectionController.setSelectionSheetOpen(false);
  }

  /// 清除选中位置
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
