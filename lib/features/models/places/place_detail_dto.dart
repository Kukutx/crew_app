import '../common/json_utils.dart';

class PlaceDetailDto {
  const PlaceDetailDto({
    required this.placeId,
    required this.name,
    required this.location,
    required this.types,
    this.formattedAddress,
  });

  factory PlaceDetailDto.fromJson(Map<String, dynamic> json) {
    return PlaceDetailDto(
      placeId: json['placeId'] as String,
      name: json['name'] as String,
      location: toDoubleList(json['location']),
      types: toStringList(json['types']),
      formattedAddress: json['formattedAddress'] as String?,
    );
  }

  final String placeId;
  final String name;
  final List<double> location;
  final List<String> types;
  final String? formattedAddress;

  Map<String, dynamic> toJson() => {
        'placeId': placeId,
        'name': name,
        'location': location,
        'types': types,
        'formattedAddress': formattedAddress,
      };
}
