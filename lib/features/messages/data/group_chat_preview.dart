class GroupChatPreview {
  const GroupChatPreview({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.tags,
    required this.accentColorValue,
    this.eventId,
    this.status,
    this.lastMessageTimeLabel,
    this.lastMessagePreview,
    this.lastMessageTime,
    this.avatarUrl,
    this.unreadCount = 0,
    this.participantCount = 0,
  });

  final String id;
  final String? eventId;
  final String title;
  final String subtitle;
  final List<String> tags;
  final int accentColorValue;
  final String? status;
  final String? lastMessageTimeLabel;
  final String? lastMessagePreview;
  final DateTime? lastMessageTime;
  final String? avatarUrl;
  final int unreadCount;
  final int participantCount;

  factory GroupChatPreview.fromJson(Map<String, dynamic> json) {
    return GroupChatPreview(
      id: json['id'] as String? ?? '',
      eventId: json['eventId'] as String?,
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      accentColorValue: (json['accentColorValue'] as int?) ?? 0,
      status: json['status'] as String?,
      lastMessageTimeLabel: json['lastMessageTimeLabel'] as String?,
      lastMessagePreview: json['lastMessagePreview'] as String?,
      lastMessageTime: json['lastMessageTime'] != null
          ? DateTime.parse(json['lastMessageTime'] as String)
          : null,
      avatarUrl: json['avatarUrl'] as String?,
      unreadCount: (json['unreadCount'] as int?) ?? 0,
      participantCount: (json['participantCount'] as int?) ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        if (eventId != null) 'eventId': eventId,
        'title': title,
        'subtitle': subtitle,
        'tags': tags,
        'accentColorValue': accentColorValue,
        if (status != null) 'status': status,
        if (lastMessageTimeLabel != null)
          'lastMessageTimeLabel': lastMessageTimeLabel,
        if (lastMessagePreview != null)
          'lastMessagePreview': lastMessagePreview,
        if (lastMessageTime != null)
          'lastMessageTime': lastMessageTime!.toIso8601String(),
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
        'unreadCount': unreadCount,
        'participantCount': participantCount,
      };
}
