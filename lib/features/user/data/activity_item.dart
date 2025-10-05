// 与event重合了，目前先用日后更改
class ActivityItem {
  final String id;
  final String title;
  final String? imageUrl;
  final DateTime? time;
  final String? location;

  const ActivityItem({
    required this.id,
    required this.title,
    this.imageUrl,
    this.time,
    this.location,
  });

  factory ActivityItem.fromJson(Map<String, dynamic> json) {
    DateTime? parsedTime;
    final rawTime = json['startTime'] ?? json['start_time'] ?? json['time'];
    if (rawTime is String && rawTime.isNotEmpty) {
      parsedTime = DateTime.tryParse(rawTime);
    } else if (rawTime is int) {
      parsedTime = DateTime.fromMillisecondsSinceEpoch(rawTime);
    }

    String? imageUrl;
    final images = json['imageUrls'] ?? json['images'];
    if (json['coverImageUrl'] is String && (json['coverImageUrl'] as String).isNotEmpty) {
      imageUrl = json['coverImageUrl'] as String;
    } else if (json['cover'] is String && (json['cover'] as String).isNotEmpty) {
      imageUrl = json['cover'] as String;
    } else if (images is List) {
      for (final item in images) {
        final candidate = item?.toString();
        if (candidate != null && candidate.trim().isNotEmpty) {
          imageUrl = candidate;
          break;
        }
      }
    }

    return ActivityItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? json['name']?.toString() ?? '',
      imageUrl: imageUrl,
      time: parsedTime,
      location: json['location']?.toString() ?? json['locationName']?.toString(),
    );
  }
}
