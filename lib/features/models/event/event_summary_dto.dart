class EventSummaryDto {
  final String id;
  final String ownerId;
  final String title;
  final DateTime? startTime;
  final List<double> center;    // [lon, lat]
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

  factory EventSummaryDto.fromJson(Map<String, dynamic> json) => EventSummaryDto(
        id: json['id'],
        ownerId: json['ownerId'],
        title: json['title'],
        startTime: json['startTime'] != null
            ? DateTime.parse(json['startTime'])
            : null,
        center: (json['center'] as List).map((e) => (e as num).toDouble()).toList(),
        memberCount: json['memberCount'],
        maxParticipants: json['maxParticipants'],
        isRegistered: json['isRegistered'],
        tags: (json['tags'] as List?)?.map((e) => e as String).toList(),
      );

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
