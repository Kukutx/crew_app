import 'event_segment_dto.dart';
import 'json_helpers.dart';
import 'moment_summary_dto.dart';

class EventDetailDto {
  final String id;
  final String ownerId;
  final String title;
  final String? description;
  final DateTime? startTime;
  final DateTime? endTime;
  final List<double>? startPoint; // [lon, lat]
  final List<double>? endPoint; // [lon, lat]
  final String? routePolyline;
  final int maxParticipants;
  final String visibility; // public/private/friends-only 等
  final List<EventSegmentDto> segments;
  final int memberCount;
  final bool isRegistered;
  final List<String>? tags;
  final List<MomentSummaryDto> moments;

  EventDetailDto({
    required this.id,
    required this.ownerId,
    required this.title,
    this.description,
    this.startTime,
    this.endTime,
    this.startPoint,
    this.endPoint,
    this.routePolyline,
    required this.maxParticipants,
    required this.visibility,
    required List<EventSegmentDto> segments,
    required this.memberCount,
    required this.isRegistered,
    this.tags,
    required List<MomentSummaryDto> moments,
  })  : segments = List.unmodifiable(segments),
        moments = List.unmodifiable(moments);

  factory EventDetailDto.fromJson(Map<String, dynamic> json) {
    final start = parseDoubleList(json['startPoint']);
    final end = parseDoubleList(json['endPoint']);
    final tags = parseStringList(json['tags']);
    final segments = parseMapList(json['segments'])
        .map(EventSegmentDto.fromJson)
        .toList(growable: false);
    final moments = parseMapList(json['moments'])
        .map(MomentSummaryDto.fromJson)
        .toList(growable: false);
    return EventDetailDto(
      id: json['id']?.toString() ?? '',
      ownerId: json['ownerId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description'] as String?,
      startTime: parseDateTime(json['startTime']),
      endTime: parseDateTime(json['endTime']),
      startPoint: start.isEmpty ? null : List.unmodifiable(start),
      endPoint: end.isEmpty ? null : List.unmodifiable(end),
      routePolyline: json['routePolyline'] as String?,
      maxParticipants: parseInt(json['maxParticipants']) ?? 0,
      visibility: json['visibility']?.toString() ?? 'Public',
      segments: segments,
      memberCount: parseInt(json['memberCount']) ?? 0,
      isRegistered: parseBool(json['isRegistered']),
      tags: tags.isEmpty ? null : List.unmodifiable(tags),
      moments: moments,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'ownerId': ownerId,
        'title': title,
        'description': description,
        'startTime': startTime?.toIso8601String(),
        'endTime': endTime?.toIso8601String(),
        'startPoint': startPoint,
        'endPoint': endPoint,
        'routePolyline': routePolyline,
        'maxParticipants': maxParticipants,
        'visibility': visibility,
        'segments': segments.map((e) => e.toJson()).toList(),
        'memberCount': memberCount,
        'isRegistered': isRegistered,
        'tags': tags,
        'moments': moments.map((e) => e.toJson()).toList(),
      };
}
