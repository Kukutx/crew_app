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
    this.isSystem = false,
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
  final bool isSystem;
}
