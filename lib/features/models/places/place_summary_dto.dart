import '../common/json_utils.dart';

class PlaceSummaryDto {
  const PlaceSummaryDto({
    required this.placeId,
    required this.name,
    required this.location,
    required this.types,
  });

  factory PlaceSummaryDto.fromJson(Map<String, dynamic> json) {
    return PlaceSummaryDto(
      placeId: json['placeId'] as String,
      name: json['name'] as String,
      location: toDoubleList(json['location']),
      types: toStringList(json['types']),
    );
  }

  final String placeId;
  final String name;
  final List<double> location;
  final List<String> types;

  Map<String, dynamic> toJson() => {
        'placeId': placeId,
        'name': name,
        'location': location,
        'types': types,
      };
}
