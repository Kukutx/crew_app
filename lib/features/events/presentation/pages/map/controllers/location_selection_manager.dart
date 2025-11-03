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
  NavigatorState? _activeSheetNavigator;
  Object? _activeSheetCancelResult;

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
  Future<bool?> _showLocationSelectionSheet(BuildContext context) async {
    final selectionController = ref.read(mapSelectionControllerProvider.notifier);
    final selectionState = ref.read(mapSelectionControllerProvider);
    
    if (selectionState.selectedLatLng == null || selectionState.isSelectionSheetOpen) {
      return null;
    }

    final proceed = await _presentSelectionSheet<bool>(
      context: context,
      initialChildSize: 0.45,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      cancelResult: false,
      builder: (sheetContext, scrollController) {
        return StartLocationSheet(
          positionListenable: selectionController.selectedLatLngListenable,
          onConfirm: () => Navigator.of(sheetContext).pop(true),
          onCancel: () => Navigator.of(sheetContext).pop(false),
          reverseGeocode: _reverseGeocode,
          fetchNearbyPlaces: selectionController.getNearbyPlaces,
          scrollController: scrollController,
        );
      },
    );

    if (proceed != null && proceed) {
      await _beginDestinationSelection();
    } else {
      await clearSelectedLocation(dismissSheet: false);
    }

    return proceed;
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
      initialChildSize: 0.55,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (sheetContext, scrollController) {
        return DestinationSelectionSheet(
          startPositionListenable: selectionController.selectedLatLngListenable,
          destinationListenable: selectionController.destinationLatLngListenable,
          reverseGeocode: _reverseGeocode,
          fetchNearbyPlaces: selectionController.getNearbyPlaces,
          scrollController: scrollController,
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

    if (dismissSheet &&
        selectionState.isSelectionSheetOpen &&
        _activeSheetNavigator != null &&
        _activeSheetNavigator!.canPop()) {
      _activeSheetNavigator!.pop(_activeSheetCancelResult);
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
    required double initialChildSize,
    required Widget Function(BuildContext sheetContext, ScrollController scrollController) builder,
    double minChildSize = 0.3,
    double maxChildSize = 0.95,
    T? cancelResult,
  }) async {
    final selectionController = ref.read(mapSelectionControllerProvider.notifier);
    final media = MediaQuery.of(context);
    final controller = DraggableScrollableController();
    _activeSheetCancelResult = cancelResult;

    EdgeInsets _paddingForSize(double size) {
      final height = media.size.height;
      final bottom = height * size;
      return EdgeInsets.only(bottom: bottom);
    }

    void updatePadding() {
      selectionController.setMapPadding(_paddingForSize(controller.size));
    }

    selectionController.setMapPadding(_paddingForSize(initialChildSize));
    selectionController.setSelectionSheetOpen(true);
    controller.addListener(updatePadding);

    T? result;
    try {
      result = await showModalBottomSheet<T>(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        barrierColor: Colors.black.withValues(alpha: .45),
        builder: (modalContext) {
          _activeSheetNavigator = Navigator.of(modalContext);
          return _DraggableSheetModal(
            controller: controller,
            initialChildSize: initialChildSize,
            minChildSize: minChildSize,
            maxChildSize: maxChildSize,
            childBuilder: (sheetContext, scrollController) {
              return builder(sheetContext, scrollController);
            },
          );
        },
      );
    } finally {
      controller.removeListener(updatePadding);
      selectionController.resetMapPadding();
      selectionController.setSelectionSheetOpen(false);
      _activeSheetNavigator = null;
      _activeSheetCancelResult = null;
    }

    return result;
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
      selectionController.setSelectingDestination(true);
      if (initialDestination != null) {
        selectionController.setDestinationLatLng(initialDestination);
        await mapController.moveCamera(initialDestination, zoom: 12);
      } else {
        selectionController.setDestinationLatLng(initialStart);
        await mapController.moveCamera(initialStart, zoom: 6);
      }
      await _showDestinationSelectionSheet(context);
      return;
    }

    if (initialStart != null) {
      await mapController.moveCamera(initialStart, zoom: 12);
    }

    final proceed = await _showLocationSelectionSheet(context);
    if (proceed == true) {
      await _beginDestinationSelection();
      if (initialDestination != null) {
        selectionController.setDestinationLatLng(initialDestination);
        await mapController.moveCamera(initialDestination, zoom: 12);
      }
      await _showDestinationSelectionSheet(context);
    } else {
      await clearSelectedLocation(dismissSheet: false);
    }
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

class _DraggableSheetModal extends StatelessWidget {
  const _DraggableSheetModal({
    required this.controller,
    required this.initialChildSize,
    required this.minChildSize,
    required this.maxChildSize,
    required this.childBuilder,
  });

  final DraggableScrollableController controller;
  final double initialChildSize;
  final double minChildSize;
  final double maxChildSize;
  final Widget Function(BuildContext context, ScrollController scrollController)
      childBuilder;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      controller: controller,
      expand: false,
      initialChildSize: initialChildSize,
      minChildSize: minChildSize,
      maxChildSize: maxChildSize,
      builder: (context, scrollController) {
        final theme = Theme.of(context);
        return AnimatedPadding(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: Material(
              color: theme.colorScheme.surface,
              child: SafeArea(
                top: false,
                child: childBuilder(context, scrollController),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// LocationSelectionManager的Provider
final locationSelectionManagerProvider = Provider<LocationSelectionManager>((ref) {
  return LocationSelectionManager(ref);
});
