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
        id: json['id'],
        ownerId: json['ownerId'],
        title: json['title'],
        description: json['description'],
        startTime: json['startTime'] != null ? DateTime.parse(json['startTime']) : null,
        endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
        startPoint: (json['startPoint'] as List?)?.map((e) => (e as num).toDouble()).toList(),
        endPoint: (json['endPoint'] as List?)?.map((e) => (e as num).toDouble()).toList(),
        routePolyline: json['routePolyline'],
        maxParticipants: json['maxParticipants'],
        visibility: json['visibility'],
        segments: (json['segments'] as List).map((e) => EventSegmentDto.fromJson(e)).toList(),
        memberCount: json['memberCount'],
        isRegistered: json['isRegistered'],
        tags: (json['tags'] as List?)?.map((e) => e as String).toList(),
        moments: (json['moments'] as List).map((e) => MomentSummaryDto.fromJson(e)).toList(),
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
