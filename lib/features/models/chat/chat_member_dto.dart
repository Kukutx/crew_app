import '../common/enums.dart';

class ChatMemberDto {
  const ChatMemberDto({
    required this.chatId,
    required this.userId,
    required this.role,
    required this.joinedAt,
    this.mutedUntil,
    this.lastReadMessageSeq,
    this.leftAt,
  });

  factory ChatMemberDto.fromJson(Map<String, dynamic> json) {
    return ChatMemberDto(
      chatId: json['chatId'] as String,
      userId: json['userId'] as String,
      role: ChatMemberRole.fromJson(json['role']),
      joinedAt: DateTime.parse(json['joinedAt'] as String),
      mutedUntil: json['mutedUntil'] != null ? DateTime.parse(json['mutedUntil'] as String) : null,
      lastReadMessageSeq: json['lastReadMessageSeq'] != null
          ? (json['lastReadMessageSeq'] as num).toInt()
          : null,
      leftAt: json['leftAt'] != null ? DateTime.parse(json['leftAt'] as String) : null,
    );
  }

  final String chatId;
  final String userId;
  final ChatMemberRole role;
  final DateTime joinedAt;
  final DateTime? mutedUntil;
  final int? lastReadMessageSeq;
  final DateTime? leftAt;

  Map<String, dynamic> toJson() => {
        'chatId': chatId,
        'userId': userId,
        'role': role.toJson(),
        'joinedAt': joinedAt.toIso8601String(),
        'mutedUntil': mutedUntil?.toIso8601String(),
        'lastReadMessageSeq': lastReadMessageSeq,
        'leftAt': leftAt?.toIso8601String(),
      };
}
