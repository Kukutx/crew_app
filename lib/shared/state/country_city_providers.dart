import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/country_city_service.dart';

/// 国家-城市服务 Provider（单例）
final countryCityServiceProvider = Provider<CountryCityService>((ref) {
  return CountryCityService();
});

/// 国家-城市数据加载状态 Provider
/// 应用启动时自动加载数据
final countryCityDataProvider = FutureProvider<void>((ref) async {
  final service = ref.read(countryCityServiceProvider);
  await service.loadData();
});

/// 根据国家代码获取城市列表的 Provider
/// 当国家代码改变时，自动返回对应的城市列表
final citiesByCountryProvider = Provider.family<List<String>, String?>((ref, countryCode) {
  final service = ref.read(countryCityServiceProvider);
  // 确保数据已加载
  ref.watch(countryCityDataProvider);
  return service.getCitiesByCountry(countryCode);
});

