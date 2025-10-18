class UserGuestbookEntryDto {
  final String id;
  final String authorId;
  final String authorDisplayName;
  final String content;
  final DateTime createdAt;

  UserGuestbookEntryDto({
    required this.id,
    required this.authorId,
    required this.authorDisplayName,
    required this.content,
    required this.createdAt,
  });

  factory UserGuestbookEntryDto.fromJson(Map<String, dynamic> json) => UserGuestbookEntryDto(
        id: json['id'],
        authorId: json['authorId'],
        authorDisplayName: json['authorDisplayName'],
        content: json['content'],
        createdAt: DateTime.parse(json['createdAt']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'authorId': authorId,
        'authorDisplayName': authorDisplayName,
        'content': content,
        'createdAt': createdAt.toIso8601String(),
      };
}
