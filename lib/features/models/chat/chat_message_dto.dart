import '../common/enums.dart';

class ChatMessageDto {
  const ChatMessageDto({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.kind,
    this.bodyText,
    this.metaJson,
    required this.createdAt,
    required this.seq,
    required this.status,
  });

  factory ChatMessageDto.fromJson(Map<String, dynamic> json) {
    return ChatMessageDto(
      id: (json['id'] as num).toInt(),
      chatId: json['chatId'] as String,
      senderId: json['senderId'] as String,
      kind: ChatMessageKind.fromJson(json['kind']),
      bodyText: json['bodyText'] as String?,
      metaJson: json['metaJson'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      seq: (json['seq'] as num).toInt(),
      status: ChatMessageStatus.fromJson(json['status']),
    );
  }

  final int id;
  final String chatId;
  final String senderId;
  final ChatMessageKind kind;
  final String? bodyText;
  final String? metaJson;
  final DateTime createdAt;
  final int seq;
  final ChatMessageStatus status;

  Map<String, dynamic> toJson() => {
        'id': id,
        'chatId': chatId,
        'senderId': senderId,
        'kind': kind.toJson(),
        'bodyText': bodyText,
        'metaJson': metaJson,
        'createdAt': createdAt.toIso8601String(),
        'seq': seq,
        'status': status.toJson(),
      };
}
