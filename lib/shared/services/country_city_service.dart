import 'dart:convert';
import 'package:flutter/services.dart';
import '../data/country_city_data.dart';

/// 国家-城市数据服务
/// 单例模式，确保数据只加载一次
class CountryCityService {
  static const String _dataPath = 'assets/data/countries-cities.json';
  
  Map<String, CountryCityData>? _countryCityMap;
  bool _isLoading = false;
  Future<void>? _loadFuture;

  /// 加载国家-城市数据
  /// 如果数据已加载或正在加载，返回现有的 Future
  Future<void> loadData() async {
    if (_countryCityMap != null) {
      return;
    }

    // 如果正在加载，返回现有的 Future
    if (_isLoading && _loadFuture != null) {
      return _loadFuture!;
    }

    _isLoading = true;
    _loadFuture = _loadDataInternal();
    
    try {
      await _loadFuture;
    } finally {
      _isLoading = false;
    }
  }

  Future<void> _loadDataInternal() async {
    try {
      final String jsonString = await rootBundle.loadString(_dataPath);
      final Map<String, dynamic> jsonData = json.decode(jsonString) as Map<String, dynamic>;
      
      _countryCityMap = {};
      jsonData.forEach((code, data) {
        _countryCityMap![code] = CountryCityData.fromJson(code, data as Map<String, dynamic>);
      });
    } catch (e) {
      throw Exception('Failed to load country-city data: $e');
    }
  }

  /// 获取所有国家代码
  List<String> getCountryCodes() {
    if (_countryCityMap == null) {
      return [];
    }
    return _countryCityMap!.keys.toList();
  }

  /// 根据国家代码获取城市列表
  List<String> getCitiesByCountry(String? countryCode) {
    if (countryCode == null || _countryCityMap == null) {
      return [];
    }
    return _countryCityMap![countryCode]?.cities ?? [];
  }

  /// 获取国家名称
  String? getCountryName(String? countryCode) {
    if (countryCode == null || _countryCityMap == null) {
      return null;
    }
    return _countryCityMap![countryCode]?.countryName;
  }

  /// 检查数据是否已加载
  bool get isLoaded => _countryCityMap != null;
}

