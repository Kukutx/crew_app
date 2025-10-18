import 'json_helpers.dart';

class EventSummaryDto {
  final String id;
  final String ownerId;
  final String title;
  final DateTime? startTime;
  final List<double> center; // [lon, lat]
  final int memberCount;
  final int maxParticipants;
  final bool isRegistered;
  final List<String>? tags;

  EventSummaryDto({
    required this.id,
    required this.ownerId,
    required this.title,
    this.startTime,
    required this.center,
    required this.memberCount,
    required this.maxParticipants,
    required this.isRegistered,
    this.tags,
  });

  factory EventSummaryDto.fromJson(Map<String, dynamic> json) {
    final center = parseDoubleList(json['center']);
    final tags = parseStringList(json['tags']);
    return EventSummaryDto(
      id: json['id']?.toString() ?? '',
      ownerId: json['ownerId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      startTime: parseDateTime(json['startTime']),
      center: center.isEmpty ? const <double>[] : List.unmodifiable(center),
      memberCount: parseInt(json['memberCount']) ?? 0,
      maxParticipants: parseInt(json['maxParticipants']) ?? 0,
      isRegistered: parseBool(json['isRegistered']),
      tags: tags.isEmpty ? null : List.unmodifiable(tags),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'ownerId': ownerId,
        'title': title,
        'startTime': startTime?.toIso8601String(),
        'center': center,
        'memberCount': memberCount,
        'maxParticipants': maxParticipants,
        'isRegistered': isRegistered,
        'tags': tags,
      };
}
