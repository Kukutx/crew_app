class UserGuestbookEntryDto {
  final String id;
  final String authorId;
  final String authorDisplayName;
  final String content;
  final int? rating;
  final DateTime createdAt;

  UserGuestbookEntryDto({
    required this.id,
    required this.authorId,
    required this.authorDisplayName,
    required this.content,
    this.rating,
    required this.createdAt,
  });

  factory UserGuestbookEntryDto.fromJson(Map<String, dynamic> json) =>
      UserGuestbookEntryDto(
        id: json['id'] as String,
        authorId: json['authorId'] as String,
        authorDisplayName: json['authorDisplayName'] as String,
        content: json['content'] as String,
        rating: (json['rating'] as num?)?.toInt(),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'authorId': authorId,
        'authorDisplayName': authorDisplayName,
        'content': content,
        'rating': rating,
        'createdAt': createdAt.toIso8601String(),
      };
}
