import 'package:crew_app/core/network/places/places_service.dart';
import 'package:crew_app/features/events/presentation/widgets/common/components/location_selection_manager.dart';
import 'package:crew_app/features/events/state/places_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// 位置管理器基类
/// 
/// 提供地址加载、附近地点加载等公共方法
abstract class BaseLocationManager {
  final WidgetRef ref;

  BaseLocationManager(this.ref);

  /// 加载地址（使用 LocationSelectionManager）
  /// 
  /// 这是所有 Manager 共享的地址加载逻辑
  Future<String?> loadAddress(LatLng latLng) async {
    try {
      final locationManager = ref.read(locationSelectionManagerProvider);
      return await locationManager.reverseGeocode(latLng);
    } catch (e) {
      return null;
    }
  }

  /// 加载附近地点（使用 PlacesService）
  /// 
  /// 这是所有 Manager 共享的附近地点加载逻辑
  Future<List<NearbyPlace>> loadNearbyPlaces(LatLng latLng) async {
    try {
      final placesService = ref.read(placesServiceProvider);
      return await placesService.searchNearbyPlaces(
        latLng,
        maxResults: 10,
        radius: 200,
      );
    } catch (e) {
      return [];
    }
  }
}

