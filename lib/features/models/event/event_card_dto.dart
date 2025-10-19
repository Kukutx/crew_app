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

  factory EventCardDto.fromJson(Map<String, dynamic> json) => EventCardDto(
        id: json['id'] as String,
        ownerId: json['ownerId'] as String,
        title: json['title'] as String,
        description: json['description'] as String?,
        startTime: json['startTime'] != null
            ? DateTime.parse(json['startTime'] as String)
            : null,
        createdAt: DateTime.parse(json['createdAt'] as String),
        coordinates: _asDoubleList(json['coordinates']),
        distanceKm: (json['distanceKm'] as num?)?.toDouble(),
        registrations: (json['registrations'] as num?)?.toInt() ?? 0,
        likes: (json['likes'] as num?)?.toInt() ?? 0,
        engagement: (json['engagement'] as num?)?.toDouble(),
        tags: _asStringList(json['tags']),
      );

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

List<double> _asDoubleList(dynamic value) {
  if (value is List) {
    return value
        .whereType<num>()
        .map((item) => item.toDouble())
        .toList(growable: false);
  }
  return const <double>[];
}

List<String>? _asStringList(dynamic value) {
  if (value is List) {
    final result = value.whereType<String>().map((e) => e.trim()).toList();
    return result.isEmpty ? null : List.unmodifiable(result);
  }
  return null;
}
