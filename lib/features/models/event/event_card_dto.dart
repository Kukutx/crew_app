import 'json_helpers.dart';

class EventCardDto {
  final String id;
  final String ownerId;
  final String title;
  final String? description;
  final DateTime? startTime;
  final DateTime createdAt;
  final List<double> coordinates; // [lon, lat]
  final double? distanceKm;
  final int registrations;
  final int likes;
  final double? engagement; // 指标/分数
  final List<String>? tags;

  EventCardDto({
    required this.id,
    required this.ownerId,
    required this.title,
    this.description,
    this.startTime,
    required this.createdAt,
    required this.coordinates,
    this.distanceKm,
    required this.registrations,
    required this.likes,
    this.engagement,
    this.tags,
  });

  factory EventCardDto.fromJson(Map<String, dynamic> json) {
    final coordinates = parseDoubleList(json['coordinates']);
    final tags = parseStringList(json['tags']);
    return EventCardDto(
      id: json['id']?.toString() ?? '',
      ownerId: json['ownerId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description'] as String?,
      startTime: parseDateTime(json['startTime']),
      createdAt: parseDateTime(json['createdAt']) ?? DateTime.now().toUtc(),
      coordinates:
          coordinates.isEmpty ? const <double>[] : List.unmodifiable(coordinates),
      distanceKm: parseDouble(json['distanceKm']),
      registrations: parseInt(json['registrations']) ?? 0,
      likes: parseInt(json['likes']) ?? 0,
      engagement: parseDouble(json['engagement']),
      tags: tags.isEmpty ? null : List.unmodifiable(tags),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'ownerId': ownerId,
        'title': title,
        'description': description,
        'startTime': startTime?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'coordinates': coordinates,
        'distanceKm': distanceKm,
        'registrations': registrations,
        'likes': likes,
        'engagement': engagement,
        'tags': tags,
      };
}
