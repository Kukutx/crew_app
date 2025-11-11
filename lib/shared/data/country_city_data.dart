/// 国家-城市数据模型
class CountryCityData {
  final String countryCode;
  final String countryName;
  final List<String> cities;

  CountryCityData({
    required this.countryCode,
    required this.countryName,
    required this.cities,
  });

  factory CountryCityData.fromJson(String code, Map<String, dynamic> json) {
    return CountryCityData(
      countryCode: code,
      countryName: json['name'] as String,
      cities: List<String>.from(json['cities'] as List),
    );
  }
}

