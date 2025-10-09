class ChatParticipant {
  const ChatParticipant({
    required this.id,
    required this.displayName,
    this.initials,
    this.avatarColorValue,
    this.isCurrentUser = false,
  });

  final String id;
  final String displayName;
  final String? initials;
  final int? avatarColorValue;
  final bool isCurrentUser;
}
