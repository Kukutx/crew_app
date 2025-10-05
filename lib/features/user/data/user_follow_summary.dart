class UserFollowSummary {
  final String uid;
  final String userName;
  final String displayName;
  final String avatarUrl;
  final DateTime followedAt;

  const UserFollowSummary({
    required this.uid,
    required this.userName,
    required this.displayName,
    required this.avatarUrl,
    required this.followedAt,
  });

  factory UserFollowSummary.fromJson(Map<String, dynamic> json) {
    String _asString(dynamic value) => value?.toString() ?? '';
    DateTime _parseDate(dynamic value) {
      if (value is DateTime) {
        return value.toUtc();
      }
      if (value is String && value.isNotEmpty) {
        final parsed = DateTime.tryParse(value);
        if (parsed != null) {
          return parsed.toUtc();
        }
      }
      if (value is int) {
        return DateTime.fromMillisecondsSinceEpoch(value, isUtc: true);
      }
      return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    }

    return UserFollowSummary(
      uid: _asString(json['uid'] ?? json['userId'] ?? json['id']),
      userName: _asString(json['userName'] ?? json['username'] ?? json['name']),
      displayName:
          _asString(json['displayName'] ?? json['nickname'] ?? json['name']),
      avatarUrl: _asString(
        json['avatarUrl'] ??
            json['avatar'] ??
            json['photoUrl'] ??
            json['imageUrl'] ??
            json['profileImage'] ??
            '',
      ),
      followedAt: _parseDate(
        json['followedAt'] ?? json['createdAt'] ?? json['timestamp'],
      ),
    );
  }
}
