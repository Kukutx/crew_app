import 'package:crew_app/core/state/di/providers.dart';
import 'package:crew_app/shared/services/location_api_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

/// LocationApiService Provider
final locationApiServiceProvider = Provider<LocationApiService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return LocationApiService(apiService);
});

/// 国家列表 Provider
final countriesProvider = FutureProvider<List<CountryDto>>((ref) async {
  final service = ref.watch(locationApiServiceProvider);
  return service.getCountries();
});

/// 根据国家代码获取城市列表的 Provider
final citiesByCountryCodeProvider = FutureProvider.family<List<CityDto>, String?>((ref, countryCode) async {
  if (countryCode == null || countryCode.isEmpty) {
    return [];
  }
  final service = ref.watch(locationApiServiceProvider);
  return service.getCitiesByCountry(countryCode);
});

/// 搜索城市的 Provider
final searchCitiesProvider = FutureProvider.family<List<CityDto>, ({String countryCode, String? searchTerm})>((ref, params) async {
  if (params.countryCode.isEmpty) {
    return [];
  }
  final service = ref.watch(locationApiServiceProvider);
  return service.searchCities(params.countryCode, params.searchTerm);
});

/// IP 位置 Provider（缓存结果）
/// 使用 geolocator 和 geocoding 获取当前位置的国家名称
final ipLocationProvider = FutureProvider<String>((ref) async {
  try {
    // 检查定位服务是否启用
    if (!await Geolocator.isLocationServiceEnabled()) {
      return '';
    }

    // 检查权限
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) {
      return '';
    }

    // 获取当前位置
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.low,
      ),
    ).timeout(const Duration(seconds: 5));

    // 反向地理编码获取地址信息
    final placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    ).timeout(const Duration(seconds: 5));

    if (placemarks.isNotEmpty) {
      final country = placemarks.first.country;
      if (country != null && country.isNotEmpty) {
        return country;
      }
    }
  } catch (_) {
    // 静默失败，返回空字符串
  }
  return '';
});

