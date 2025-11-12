import 'package:crew_app/core/network/api_service.dart';

/// 地理位置 API 服务
/// 从后端 API 获取国家和城市数据
class LocationApiService {
  final ApiService _apiService;

  LocationApiService(this._apiService);

  /// 获取所有国家列表
  Future<List<CountryDto>> getCountries() async {
    // 使用 ApiService 的内部请求处理器
    // 由于 _requestHandler 是 private，我们需要通过扩展方法或修改 ApiService
    // 这里使用反射访问，或者更好的方式是修改 ApiService 添加公开方法
    // 临时方案：通过扩展 ApiService 或使用反射
    return _callApi<List<CountryDto>>(
      path: '/locations/countries',
      parseResponse: (data) {
        // 后端返回 ApiResponse<List<CountryDto>>，需要提取 data 字段
        final responseData = _extractData(data);
        if (responseData is List) {
          return responseData
              .map((json) => CountryDto.fromJson(json as Map<String, dynamic>))
              .toList();
        }
        throw Exception('Unexpected countries payload type');
      },
    );
  }

  /// 根据国家代码获取城市列表
  Future<List<CityDto>> getCitiesByCountry(String countryCode) async {
    return _callApi<List<CityDto>>(
      path: '/locations/countries/$countryCode/cities',
      parseResponse: (data) {
        final responseData = _extractData(data);
        if (responseData is List) {
          return responseData
              .map((json) => CityDto.fromJson(json as Map<String, dynamic>))
              .toList();
        }
        throw Exception('Unexpected cities payload type');
      },
    );
  }

  /// 搜索城市
  Future<List<CityDto>> searchCities(String countryCode, String? searchTerm) async {
    return _callApi<List<CityDto>>(
      path: '/locations/countries/$countryCode/cities/search',
      queryParameters: searchTerm != null && searchTerm.isNotEmpty
          ? {'q': searchTerm}
          : null,
      parseResponse: (data) {
        final responseData = _extractData(data);
        if (responseData is List) {
          return responseData
              .map((json) => CityDto.fromJson(json as Map<String, dynamic>))
              .toList();
        }
        throw Exception('Unexpected cities payload type');
      },
    );
  }

  /// 调用 API 的辅助方法
  Future<T> _callApi<T>({
    required String path,
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic) parseResponse,
  }) async {
    return _apiService.requestHandler.get<T>(
      path: path,
      queryParameters: queryParameters,
      requiresAuth: false, // 地理位置接口不需要认证
      parseResponse: (data) {
        // 后端返回 ApiResponse<T>，需要提取 data 字段
        final responseData = _extractData(data);
        return parseResponse(responseData);
      },
    );
  }

  /// 从 ApiResponse 中提取 data 字段
  dynamic _extractData(dynamic data) {
    if (data is Map<String, dynamic>) {
      // 如果是 ApiResponse 格式，提取 data 字段
      if (data.containsKey('data')) {
        return data['data'];
      }
      // 如果直接是数据，返回原数据
      return data;
    }
    return data;
  }
}

/// 国家 DTO
class CountryDto {
  final String id;
  final String code;
  final String name;
  final String? nameZh;

  CountryDto({
    required this.id,
    required this.code,
    required this.name,
    this.nameZh,
  });

  factory CountryDto.fromJson(Map<String, dynamic> json) {
    return CountryDto(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      nameZh: json['nameZh'] as String?,
    );
  }
}

/// 城市 DTO
class CityDto {
  final String id;
  final String name;
  final String? nameZh;
  final String countryCode;

  CityDto({
    required this.id,
    required this.name,
    this.nameZh,
    required this.countryCode,
  });

  factory CityDto.fromJson(Map<String, dynamic> json) {
    return CityDto(
      id: json['id'] as String,
      name: json['name'] as String,
      nameZh: json['nameZh'] as String?,
      countryCode: json['countryCode'] as String,
    );
  }

  /// 获取显示名称（优先使用中文，如果没有则使用英文）
  String getDisplayName() {
    return nameZh ?? name;
  }
}

