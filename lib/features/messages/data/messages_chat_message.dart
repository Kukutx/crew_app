import 'package:crew_app/features/messages/data/messages_chat_participant.dart';

class MessagesChatMessage {
  const MessagesChatMessage({
    required this.sender,
    required this.content,
    required this.timeLabel,
    this.replyCount,
    this.replyPreview,
    this.attachmentChips = const <String>[],
  });

  final MessagesChatParticipant sender;
  final String content;
  final String timeLabel;
  final int? replyCount;
  final String? replyPreview;
  final List<String> attachmentChips;

  bool get isMine => sender.isSelf;

  bool isFromSameSender(MessagesChatMessage other) => sender.name == other.sender.name;
}
