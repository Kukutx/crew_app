import 'package:crew_app/features/messages/data/chat_participant.dart';

/// 消息类型
enum MessageType {
  text,    // 文本
  image,   // 图片
  video,   // 视频
  file,    // 文件
  system,  // 系统消息
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.chatId,
    required this.sender,
    required this.body,
    required this.sentAtLabel,
    this.replyCount,
    this.replyPreview,
    this.attachmentLabels = const <String>[],
    this.messageType = MessageType.text,
    this.sentAt,
    this.isRead = false,
  });

  final String id;
  final String chatId;
  final ChatParticipant sender;
  final String body;
  final String sentAtLabel;
  final DateTime? sentAt;
  final int? replyCount;
  final String? replyPreview;
  final List<String> attachmentLabels;
  final MessageType messageType;
  final bool isRead;

  bool get isFromCurrentUser => sender.isCurrentUser;

  bool isFromSameSender(ChatMessage other) => sender.id == other.sender.id;

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String? ?? '',
      chatId: json['chatId'] as String? ?? '',
      sender: ChatParticipant(
        id: json['senderId'] as String? ?? '',
        displayName: json['senderName'] as String? ?? '',
        avatarUrl: json['senderAvatarUrl'] as String?,
        isCurrentUser: false, // 需要在调用处设置
      ),
      body: json['body'] as String? ?? '',
      sentAtLabel: json['sentAtLabel'] as String? ?? '',
      sentAt: json['sentAt'] != null
          ? DateTime.parse(json['sentAt'] as String)
          : null,
      replyCount: json['replyCount'] as int?,
      replyPreview: json['replyPreview'] as String?,
      attachmentLabels: (json['attachmentUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      messageType: _parseMessageType(json['messageType'] as String?),
      isRead: (json['isRead'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'chatId': chatId,
        'senderId': sender.id,
        'senderName': sender.displayName,
        if (sender.avatarUrl != null) 'senderAvatarUrl': sender.avatarUrl,
        'body': body,
        'sentAt': sentAt?.toIso8601String(),
        'sentAtLabel': sentAtLabel,
        if (replyCount != null) 'replyCount': replyCount,
        if (replyPreview != null) 'replyPreview': replyPreview,
        if (attachmentLabels.isNotEmpty) 'attachmentUrls': attachmentLabels,
        'messageType': _messageTypeToString(messageType),
        'isRead': isRead,
      };

  static MessageType _parseMessageType(String? value) {
    switch (value) {
      case 'text':
        return MessageType.text;
      case 'image':
        return MessageType.image;
      case 'video':
        return MessageType.video;
      case 'file':
        return MessageType.file;
      case 'system':
        return MessageType.system;
      default:
        return MessageType.text;
    }
  }

  static String _messageTypeToString(MessageType type) {
    switch (type) {
      case MessageType.text:
        return 'text';
      case MessageType.image:
        return 'image';
      case MessageType.video:
        return 'video';
      case MessageType.file:
        return 'file';
      case MessageType.system:
        return 'system';
    }
  }
}

/// 创建消息请求
class ChatMessageCreateRequest {
  final String chatId;
  final String body;
  final MessageType messageType;
  final List<String>? attachmentUrls;
  final String? replyToMessageId;

  const ChatMessageCreateRequest({
    required this.chatId,
    required this.body,
    this.messageType = MessageType.text,
    this.attachmentUrls,
    this.replyToMessageId,
  });

  Map<String, dynamic> toJson() => {
        'chatId': chatId,
        'body': body,
        'messageType': _messageTypeToString(messageType),
        if (attachmentUrls != null && attachmentUrls!.isNotEmpty)
          'attachmentUrls': attachmentUrls,
        if (replyToMessageId != null) 'replyToMessageId': replyToMessageId,
      };

  static String _messageTypeToString(MessageType type) {
    switch (type) {
      case MessageType.text:
        return 'text';
      case MessageType.image:
        return 'image';
      case MessageType.video:
        return 'video';
      case MessageType.file:
        return 'file';
      case MessageType.system:
        return 'system';
    }
  }
}
