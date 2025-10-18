class MomentCommentDto {
  const MomentCommentDto({
    required this.id,
    required this.authorId,
    this.authorDisplayName,
    required this.content,
    required this.createdAt,
  });

  factory MomentCommentDto.fromJson(Map<String, dynamic> json) {
    return MomentCommentDto(
      id: json['id'] as String,
      authorId: json['authorId'] as String,
      authorDisplayName: json['authorDisplayName'] as String?,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  final String id;
  final String authorId;
  final String? authorDisplayName;
  final String content;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'authorId': authorId,
        'authorDisplayName': authorDisplayName,
        'content': content,
        'createdAt': createdAt.toIso8601String(),
      };
}
