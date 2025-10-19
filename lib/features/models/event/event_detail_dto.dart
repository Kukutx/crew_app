import 'event_segment_dto.dart';
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
    required this.segments,
    required this.memberCount,
    required this.isRegistered,
    this.tags,
    required this.moments,
  });

  factory EventDetailDto.fromJson(Map<String, dynamic> json) => EventDetailDto(
        id: json['id'] as String,
        ownerId: json['ownerId'] as String,
        title: json['title'] as String,
        description: json['description'] as String?,
        startTime: json['startTime'] != null
            ? DateTime.parse(json['startTime'] as String)
            : null,
        endTime: json['endTime'] != null
            ? DateTime.parse(json['endTime'] as String)
            : null,
        startPoint: _asNullableDoubleList(json['startPoint']),
        endPoint: _asNullableDoubleList(json['endPoint']),
        routePolyline: json['routePolyline'] as String?,
        maxParticipants: (json['maxParticipants'] as num?)?.toInt() ?? 0,
        visibility: json['visibility'] as String,
        segments: _asSegments(json['segments']),
        memberCount: (json['memberCount'] as num?)?.toInt() ?? 0,
        isRegistered: json['isRegistered'] as bool? ?? false,
        tags: _asStringList(json['tags']),
        moments: _asMoments(json['moments']),
      );

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

List<double>? _asNullableDoubleList(dynamic value) {
  if (value is List) {
    final result = value
        .whereType<num>()
        .map((item) => item.toDouble())
        .toList(growable: false);
    return result.isEmpty ? null : result;
  }
  return null;
}

List<EventSegmentDto> _asSegments(dynamic value) {
  if (value is List) {
    return value
        .whereType<Map<String, dynamic>>()
        .map(EventSegmentDto.fromJson)
        .toList(growable: false);
  }
  return const <EventSegmentDto>[];
}

List<MomentSummaryDto> _asMoments(dynamic value) {
  if (value is List) {
    return value
        .whereType<Map<String, dynamic>>()
        .map(MomentSummaryDto.fromJson)
        .toList(growable: false);
  }
  return const <MomentSummaryDto>[];
}

List<String>? _asStringList(dynamic value) {
  if (value is List) {
    final result = value.whereType<String>().map((e) => e.trim()).toList();
    return result.isEmpty ? null : List.unmodifiable(result);
  }
  return null;
}
