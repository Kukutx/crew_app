import 'group_participant.dart';

class GroupMessage {
  const GroupMessage({
    required this.sender,
    required this.content,
    required this.timeLabel,
    this.replyCount,
    this.replyPreview,
    this.attachmentChips = const <String>[],
  });

  final GroupParticipant sender;
  final String content;
  final String timeLabel;
  final int? replyCount;
  final String? replyPreview;
  final List<String> attachmentChips;

  bool get isMine => sender.isSelf;

  bool isFromSameSender(GroupMessage other) => sender.name == other.sender.name;
}
