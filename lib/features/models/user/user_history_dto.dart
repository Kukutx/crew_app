class UserHistoryDto {
  final String id;
  final String eventId;
  final String eventTitle;
  final String role;
  final DateTime occurredAt;

  UserHistoryDto({
    required this.id,
    required this.eventId,
    required this.eventTitle,
    required this.role,
    required this.occurredAt,
  });

  factory UserHistoryDto.fromJson(Map<String, dynamic> json) => UserHistoryDto(
        id: json['id'],
        eventId: json['eventId'],
        eventTitle: json['eventTitle'],
        role: json['role'],
        occurredAt: DateTime.parse(json['occurredAt']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'eventId': eventId,
        'eventTitle': eventTitle,
        'role': role,
        'occurredAt': occurredAt.toIso8601String(),
      };
}
