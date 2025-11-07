import 'dart:async';
import 'dart:math' as math;

import 'package:crew_app/core/network/places/places_service.dart';
import 'package:crew_app/features/events/presentation/pages/map/controllers/location_selection_manager.dart';
import 'package:crew_app/features/events/presentation/pages/map/widgets/map_canvas.dart';
import 'package:crew_app/features/events/presentation/pages/trips/widgets/location_info_bottom_sheet.dart';
import 'package:crew_app/features/events/state/places_providers.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// 地图位置选择页面
class LocationPickerMapPage extends ConsumerStatefulWidget {
  const LocationPickerMapPage({
    super.key,
    required this.onLocationSelected,
    this.initialLocation,
    this.markerColor,
  });

  final void Function(LatLng, String?) onLocationSelected;
  final LatLng? initialLocation;
  final Color? markerColor;

  @override
  ConsumerState<LocationPickerMapPage> createState() =>
      _LocationPickerMapPageState();
}

class _LocationPickerMapPageState
    extends ConsumerState<LocationPickerMapPage> {
  GoogleMapController? _mapController;
  LatLng? _currentLocation;
  String? _currentAddress;
  Future<String?>? _addressFuture;
  Future<List<NearbyPlace>>? _nearbyPlacesFuture;
  Timer? _debounceTimer;
  bool _isLoadingAddress = false;

  @override
  void initState() {
    super.initState();
    _currentLocation = widget.initialLocation;
    if (_currentLocation != null) {
      _loadLocationInfo(_currentLocation!);
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (_currentLocation != null) {
      controller.moveCamera(
        CameraUpdate.newLatLngZoom(_currentLocation!, 15),
      );
    }
  }

  void _onCameraMove(CameraPosition position) {
    // 取消之前的定时器
    _debounceTimer?.cancel();
    
    // 设置新的定时器，当地图停止移动后更新位置
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _onCameraIdle(position);
    });
  }

  void _onCameraIdle(CameraPosition position) {
    final newLocation = position.target;
    
    // 如果位置变化很小，不更新
    if (_currentLocation != null) {
      final distance = _calculateDistance(_currentLocation!, newLocation);
      if (distance < 10) {
        // 小于10米不更新
        return;
      }
    }

    setState(() {
      _currentLocation = newLocation;
      _isLoadingAddress = true;
    });

    _loadLocationInfo(newLocation);
  }

  void _loadLocationInfo(LatLng location) {
    // 加载地址
    final locationManager = ref.read(locationSelectionManagerProvider);
    _addressFuture = locationManager.reverseGeocode(location);
    _addressFuture!.then((address) {
      if (!mounted) return;
      setState(() {
        _currentAddress = address;
        _isLoadingAddress = false;
      });
    });

    // 加载附近POI
    final placesService = ref.read(placesServiceProvider);
    _nearbyPlacesFuture = placesService.searchNearbyPlaces(
      location,
      radius: 200,
      maxResults: 10,
    );
    setState(() {});
  }

  double _calculateDistance(LatLng a, LatLng b) {
    const double earthRadius = 6371000; // 地球半径（米）
    final double dLat = (b.latitude - a.latitude) * math.pi / 180.0;
    final double dLon = (b.longitude - a.longitude) * math.pi / 180.0;
    final double sinDLat = math.sin(dLat / 2);
    final double sinDLon = math.sin(dLon / 2);
    final double a1 = sinDLat * sinDLat +
        math.cos(a.latitude * math.pi / 180.0) *
            math.cos(b.latitude * math.pi / 180.0) *
            sinDLon *
            sinDLon;
    final double c = 2 * math.atan2(math.sqrt(a1), math.sqrt(1 - a1));
    return earthRadius * c;
  }

  void _onConfirm() {
    if (_currentLocation != null) {
      widget.onLocationSelected(_currentLocation!, _currentAddress);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    final markerColor = widget.markerColor ?? theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.map_select_location_title),
        actions: [
          TextButton(
            onPressed: _currentLocation != null ? _onConfirm : null,
            child: Text("Apply location"),
          ),
        ],
      ),
      body: Stack(
        children: [
          // 地图
          MapCanvas(
            initialCenter: _currentLocation ?? const LatLng(39.9042, 116.4074),
            initialZoom: 15,
            onMapCreated: _onMapCreated,
            onCameraMove: _onCameraMove,
            markers: const <Marker>{},
            clusterManagers: const <ClusterManager>{},
            polylines: const <Polyline>{},
            showUserLocation: false,
            mapPadding: EdgeInsets.zero,
          ),
          // 底部信息窗口
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: LocationInfoBottomSheet(
              addressFuture: _addressFuture,
              nearbyPlacesFuture: _nearbyPlacesFuture,
              isLoading: _isLoadingAddress,
            ),
          ),
        ],
      ),
    );
  }
}

