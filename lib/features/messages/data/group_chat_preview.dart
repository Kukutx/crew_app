class GroupChatPreview {
  const GroupChatPreview({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.tags,
    required this.accentColorValue,
    this.status,
    this.lastMessageTimeLabel,
    this.unreadCount = 0,
  });

  final String id;
  final String title;
  final String subtitle;
  final List<String> tags;
  final int accentColorValue;
  final String? status;
  final String? lastMessageTimeLabel;
  final int unreadCount;
}
