class DirectChatPreview {
  const DirectChatPreview({
    required this.id,
    required this.displayName,
    required this.lastMessagePreview,
    required this.lastMessageTimeLabel,
    this.initials,
    this.avatarColorValue,
    this.isActive = false,
    this.hasUnread = false,
    this.subtitleColorValue,
  });

  final String id;
  final String displayName;
  final String lastMessagePreview;
  final String lastMessageTimeLabel;
  final String? initials;
  final int? avatarColorValue;
  final bool isActive;
  final bool hasUnread;
  final int? subtitleColorValue;
}
