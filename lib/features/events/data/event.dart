class Event {
  final int id;
  final String title;
  final String location;
  final String description;
  final double latitude;
  final double longitude;
  final List<String> imageUrls;
  final String coverImageUrl;
  final DateTime? startTime;

  Event({
    required this.id,
    required this.title,
    required this.location,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.imageUrls,
    required this.coverImageUrl,
    this.startTime,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    DateTime? startTime;
    final rawStart = json['startTime'] ?? json['start_time'] ?? json['scheduledAt'];
    if (rawStart is String && rawStart.isNotEmpty) {
      startTime = DateTime.tryParse(rawStart);
    } else if (rawStart is int) {
      startTime = DateTime.fromMillisecondsSinceEpoch(rawStart);
    }
    return Event(
      id: json['id'] as int,
      title: json['title'] as String,
      location: json['location'] as String,
      description: json['description'] as String,
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      imageUrls: (json['imageUrls'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      coverImageUrl: json['coverImageUrl'] as String? ?? '',
      startTime: startTime,
    );
  }

  /// Returns the first non-empty image URL among [imageUrls] and
  /// [coverImageUrl]. If no URL is available, `null` is returned.
  String? get firstAvailableImageUrl {
    for (final url in [...imageUrls, coverImageUrl]) {
      final trimmed = url.trim();
      if (trimmed.isNotEmpty) {
        return trimmed;
      }
    }
    return null;
  }
}
