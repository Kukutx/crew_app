import 'package:crew_app/features/messages/data/chat_participant.dart';

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.sender,
    required this.body,
    required this.sentAtLabel,
    this.replyCount,
    this.replyPreview,
    this.attachmentLabels = const <String>[],
  });

  final String id;
  final ChatParticipant sender;
  final String body;
  final String sentAtLabel;
  final int? replyCount;
  final String? replyPreview;
  final List<String> attachmentLabels;

  bool get isFromCurrentUser => sender.isCurrentUser;

  bool isFromSameSender(ChatMessage other) => sender.id == other.sender.id;
}
