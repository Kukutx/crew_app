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
        eventId: json['eventId'],
        title: json['title'],
        startTime: json['startTime'] != null ? DateTime.parse(json['startTime']) : null,
        role: json['role'],
        isCreator: json['isCreator'],
        confirmedParticipants: json['confirmedParticipants'],
        maxParticipants: json['maxParticipants'],
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
