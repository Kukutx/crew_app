class ChatReactionDto {
  const ChatReactionDto({
    required this.messageId,
    required this.userId,
    required this.emoji,
    required this.createdAt,
  });

  factory ChatReactionDto.fromJson(Map<String, dynamic> json) {
    return ChatReactionDto(
      messageId: (json['messageId'] as num).toInt(),
      userId: json['userId'] as String,
      emoji: json['emoji'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  final int messageId;
  final String userId;
  final String emoji;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'messageId': messageId,
        'userId': userId,
        'emoji': emoji,
        'createdAt': createdAt.toIso8601String(),
      };
}
