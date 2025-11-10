class ChatParticipant {
  const ChatParticipant({
    required this.id,
    required this.displayName,
    this.avatarUrl,
    this.initials,
    this.avatarColorValue,
    this.isCurrentUser = false,
    this.isOnline = false,
    this.lastSeen,
  });

  final String id;
  final String displayName;
  final String? avatarUrl;
  final String? initials;
  final int? avatarColorValue;
  final bool isCurrentUser;
  final bool isOnline;
  final DateTime? lastSeen;

  factory ChatParticipant.fromJson(Map<String, dynamic> json) {
    return ChatParticipant(
      id: json['id'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
      initials: json['initials'] as String?,
      avatarColorValue: json['avatarColorValue'] as int?,
      isCurrentUser: (json['isCurrentUser'] as bool?) ?? false,
      isOnline: (json['isOnline'] as bool?) ?? false,
      lastSeen: json['lastSeen'] != null
          ? DateTime.parse(json['lastSeen'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'displayName': displayName,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
        if (initials != null) 'initials': initials,
        if (avatarColorValue != null) 'avatarColorValue': avatarColorValue,
        'isCurrentUser': isCurrentUser,
        'isOnline': isOnline,
        if (lastSeen != null) 'lastSeen': lastSeen!.toIso8601String(),
      };
}
