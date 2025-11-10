class DirectChatPreview {
  const DirectChatPreview({
    required this.id,
    required this.userId,
    required this.displayName,
    required this.lastMessagePreview,
    required this.lastMessageTimeLabel,
    this.avatarUrl,
    this.initials,
    this.avatarColorValue,
    this.isActive = false,
    this.hasUnread = false,
    this.unreadCount = 0,
    this.subtitleColorValue,
    this.isSystem = false,
    this.lastMessageTime,
  });

  final String id;
  final String userId;
  final String displayName;
  final String lastMessagePreview;
  final String lastMessageTimeLabel;
  final DateTime? lastMessageTime;
  final String? avatarUrl;
  final String? initials;
  final int? avatarColorValue;
  final bool isActive;
  final bool hasUnread;
  final int unreadCount;
  final int? subtitleColorValue;
  final bool isSystem;

  factory DirectChatPreview.fromJson(Map<String, dynamic> json) {
    return DirectChatPreview(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      lastMessagePreview: json['lastMessagePreview'] as String? ?? '',
      lastMessageTimeLabel: json['lastMessageTimeLabel'] as String? ?? '',
      lastMessageTime: json['lastMessageTime'] != null
          ? DateTime.parse(json['lastMessageTime'] as String)
          : null,
      avatarUrl: json['avatarUrl'] as String?,
      initials: json['initials'] as String?,
      avatarColorValue: json['avatarColorValue'] as int?,
      isActive: (json['isActive'] as bool?) ?? false,
      hasUnread: (json['hasUnread'] as bool?) ?? false,
      unreadCount: (json['unreadCount'] as int?) ?? 0,
      subtitleColorValue: json['subtitleColorValue'] as int?,
      isSystem: (json['isSystem'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'displayName': displayName,
        'lastMessagePreview': lastMessagePreview,
        'lastMessageTimeLabel': lastMessageTimeLabel,
        if (lastMessageTime != null)
          'lastMessageTime': lastMessageTime!.toIso8601String(),
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
        if (initials != null) 'initials': initials,
        if (avatarColorValue != null) 'avatarColorValue': avatarColorValue,
        'isActive': isActive,
        'hasUnread': hasUnread,
        'unreadCount': unreadCount,
        if (subtitleColorValue != null)
          'subtitleColorValue': subtitleColorValue,
        'isSystem': isSystem,
      };
}
