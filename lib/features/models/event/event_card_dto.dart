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
        id: json['id'],
        ownerId: json['ownerId'],
        title: json['title'],
        description: json['description'],
        startTime: json['startTime'] != null ? DateTime.parse(json['startTime']) : null,
        createdAt: DateTime.parse(json['createdAt']),
        coordinates: (json['coordinates'] as List).map((e) => (e as num).toDouble()).toList(),
        distanceKm: (json['distanceKm'] as num?)?.toDouble(),
        registrations: json['registrations'],
        likes: json['likes'],
        engagement: (json['engagement'] as num?)?.toDouble(),
        tags: (json['tags'] as List?)?.map((e) => e as String).toList(),
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
