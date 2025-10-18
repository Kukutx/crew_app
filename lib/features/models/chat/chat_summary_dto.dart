import '../common/enums.dart';
import 'chat_message_dto.dart';

class ChatSummaryDto {
  const ChatSummaryDto({
    required this.id,
    required this.type,
    this.title,
    this.ownerUserId,
    this.eventId,
    required this.isArchived,
    required this.createdAt,
    required this.role,
    this.lastReadMessageSeq,
    required this.lastMessageSeq,
    required this.unreadCount,
    this.lastMessage,
  });

  factory ChatSummaryDto.fromJson(Map<String, dynamic> json) {
    return ChatSummaryDto(
      id: json['id'] as String,
      type: ChatType.fromJson(json['type']),
      title: json['title'] as String?,
      ownerUserId: json['ownerUserId'] as String?,
      eventId: json['eventId'] as String?,
      isArchived: json['isArchived'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      role: ChatMemberRole.fromJson(json['role']),
      lastReadMessageSeq: json['lastReadMessageSeq'] != null
          ? (json['lastReadMessageSeq'] as num).toInt()
          : null,
      lastMessageSeq: (json['lastMessageSeq'] as num).toInt(),
      unreadCount: json['unreadCount'] as int,
      lastMessage: json['lastMessage'] != null
          ? ChatMessageDto.fromJson(json['lastMessage'] as Map<String, dynamic>)
          : null,
    );
  }

  final String id;
  final ChatType type;
  final String? title;
  final String? ownerUserId;
  final String? eventId;
  final bool isArchived;
  final DateTime createdAt;
  final ChatMemberRole role;
  final int? lastReadMessageSeq;
  final int lastMessageSeq;
  final int unreadCount;
  final ChatMessageDto? lastMessage;

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.toJson(),
        'title': title,
        'ownerUserId': ownerUserId,
        'eventId': eventId,
        'isArchived': isArchived,
        'createdAt': createdAt.toIso8601String(),
        'role': role.toJson(),
        'lastReadMessageSeq': lastReadMessageSeq,
        'lastMessageSeq': lastMessageSeq,
        'unreadCount': unreadCount,
        'lastMessage': lastMessage?.toJson(),
      };
}
