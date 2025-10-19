class UserActivityDto {
  final String eventId;
  final String title;
  final DateTime? startTime;
  final String role;
  final bool isCreator;
  final int confirmedParticipants;
  final int maxParticipants;

  UserActivityDto({
    required this.eventId,
    required this.title,
    this.startTime,
    required this.role,
    required this.isCreator,
    required this.confirmedParticipants,
    required this.maxParticipants,
  });

  factory UserActivityDto.fromJson(Map<String, dynamic> json) => UserActivityDto(
        eventId: json['eventId'] as String,
        title: json['title'] as String,
        startTime: json['startTime'] != null
            ? DateTime.parse(json['startTime'] as String)
            : null,
        role: json['role'] as String,
        isCreator: json['isCreator'] as bool? ?? false,
        confirmedParticipants:
            (json['confirmedParticipants'] as num?)?.toInt() ?? 0,
        maxParticipants: (json['maxParticipants'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'eventId': eventId,
        'title': title,
        'startTime': startTime?.toIso8601String(),
        'role': role,
        'isCreator': isCreator,
        'confirmedParticipants': confirmedParticipants,
        'maxParticipants': maxParticipants,
      };
}
