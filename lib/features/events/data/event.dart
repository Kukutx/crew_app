import 'package:intl/intl.dart';

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
  final DateTime? endTime;
  final int? currentParticipants;
  final int? maxParticipants;
  final String? timeText;
  final String? participantsText;

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
    this.endTime,
    this.currentParticipants,
    this.maxParticipants,
    this.timeText,
    this.participantsText,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      if (value is int) {
        // Support seconds and milliseconds since epoch.
        if (value < 1000000000000) {
          return DateTime.fromMillisecondsSinceEpoch(value * 1000);
        }
        return DateTime.fromMillisecondsSinceEpoch(value);
      }
      if (value is double) {
        final milliseconds = value > 1000000000000
            ? value.toInt()
            : (value * 1000).toInt();
        return DateTime.fromMillisecondsSinceEpoch(milliseconds);
      }
      if (value is String && value.isNotEmpty) {
        return DateTime.tryParse(value);
      }
      return null;
    }

    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value);
      return null;
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
      startTime: parseDate(json['startTime'] ?? json['start_time']),
      endTime: parseDate(json['endTime'] ?? json['end_time']),
      currentParticipants:
          parseInt(json['currentParticipants'] ?? json['current_participants']),
      maxParticipants:
          parseInt(json['maxParticipants'] ?? json['max_participants']),
      timeText: (json['timeText'] ?? json['time_text']) as String?,
      participantsText:
          (json['participantsText'] ?? json['participants_text']) as String?,
    );
  }

  /// Returns the preferred image url for the event, falling back to the cover image.
  String get primaryImageUrl {
    if (imageUrls.isNotEmpty && imageUrls.first.isNotEmpty) {
      return imageUrls.first;
    }
    return coverImageUrl;
  }

  /// Returns a formatted start time string respecting the provided locale, if available.
  String? formattedStartTime(String locale) {
    final customText = timeText?.trim();
    if (customText != null && customText.isNotEmpty) {
      return customText;
    }

    final start = startTime;
    if (start == null) return null;

    final dateFormat = DateFormat.yMMMd(locale);
    final timeFormat = DateFormat.Hm(locale);
    return '${dateFormat.format(start)} ${timeFormat.format(start)}';
  }

  /// Returns a formatted participants string, if enough data is present.
  String? get participantsDisplayText {
    final customText = participantsText?.trim();
    if (customText != null && customText.isNotEmpty) {
      return customText;
    }

    final current = currentParticipants;
    final max = maxParticipants;

    if (current != null && max != null) {
      return '$current/$max';
    }

    if (current != null) {
      return '$current';
    }

    if (max != null) {
      return '$max';
    }

    return null;
  }
}
