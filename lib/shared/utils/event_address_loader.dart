import 'package:crew_app/core/network/places/places_service.dart';
import 'package:crew_app/features/events/presentation/pages/map/controllers/location_selection_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// 事件地址加载工具类
class EventAddressLoader {
  EventAddressLoader(this.ref);

  final WidgetRef ref;

  /// 加载地址（反向地理编码）
  Future<String?> loadAddress(LatLng location) {
    final manager = ref.read(locationSelectionManagerProvider);
    return manager.reverseGeocode(location);
  }

  /// 加载附近地点
  Future<List<NearbyPlace>> loadNearbyPlaces(LatLng location) {
    final manager = ref.read(locationSelectionManagerProvider);
    return manager.fetchNearbyPlaces(location);
  }

  /// 加载地址并返回格式化的地址字符串（去除首尾空格）
  Future<String?> loadFormattedAddress(LatLng location) async {
    final address = await loadAddress(location);
    if (address == null) return null;
    final trimmed = address.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

