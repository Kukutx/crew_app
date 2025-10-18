class UserProfileDto {
  UserProfileDto({
    required this.id,
    required this.firebaseUid,
    required this.displayName,
    this.email,
    this.role,
    this.avatarUrl,
    this.bio,
    this.tags = const <String>[],
    this.followersCount,
    this.followingCount,
    this.eventsCount,
    this.isFollowing,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String firebaseUid;
  final String displayName;
  final String? email;
  final String? role;
  final String? avatarUrl;
  final String? bio;
  final List<String> tags;
  final int? followersCount;
  final int? followingCount;
  final int? eventsCount;
  final bool? isFollowing;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory UserProfileDto.fromJson(Map<String, dynamic> json) {
    List<String> parseTags(dynamic value) {
      if (value is Iterable) {
        return value
            .map((item) => item?.toString())
            .whereType<String>()
            .map((item) => item.trim())
            .where((item) => item.isNotEmpty)
            .toList(growable: false);
      }
      return const <String>[];
    }

    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      return DateTime.tryParse(value.toString());
    }

    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value.toString());
    }

    bool? parseBool(dynamic value) {
      if (value == null) return null;
      if (value is bool) return value;
      if (value is num) return value != 0;
      final lower = value.toString().toLowerCase();
      if (lower == 'true' || lower == '1' || lower == 'yes') return true;
      if (lower == 'false' || lower == '0' || lower == 'no') return false;
      return null;
    }

    final merged = () {
      final profile = json['profile'];
      if (profile is Map<String, dynamic>) {
        return {...profile, ...json};
      }
      return json;
    }();

    return UserProfileDto(
      id: (merged['id'] ??
                  merged['userId'] ??
                  merged['guid'] ??
                  merged['profileId'] ??
                  merged['aspNetIdentityId'])
              ?.toString() ??
          '',
      firebaseUid: (merged['firebaseUid'] ??
                  merged['uid'] ??
                  merged['firebaseId'] ??
                  merged['firebaseUserId'])
              ?.toString() ??
          '',
      displayName: (merged['displayName'] ??
              merged['name'] ??
              merged['nickname'] ??
              merged['userName'] ??
              '')
          .toString(),
      email: merged['email']?.toString(),
      role: merged['role']?.toString(),
      avatarUrl:
          (merged['avatarUrl'] ?? merged['photoUrl'] ?? merged['imageUrl'])?.toString(),
      bio: merged['bio']?.toString(),
      tags: parseTags(merged['tags'] ?? merged['labels'] ?? merged['interests']),
      followersCount: parseInt(
        merged['followers'] ?? merged['followersCount'] ?? merged['fansCount'],
      ),
      followingCount: parseInt(
        merged['following'] ?? merged['followingCount'] ?? merged['subscriptionsCount'],
      ),
      eventsCount: parseInt(
        merged['events'] ?? merged['eventsCount'] ?? merged['activitiesCount'],
      ),
      isFollowing: parseBool(
        merged['isFollowing'] ?? merged['followed'] ?? merged['isFollowed'],
      ),
      createdAt: parseDate(
        merged['createdAt'] ?? merged['createdOn'] ?? merged['created'],
      ),
      updatedAt: parseDate(
        merged['updatedAt'] ?? merged['updatedOn'] ?? merged['updated'],
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'firebaseUid': firebaseUid,
        'displayName': displayName,
        if (email != null) 'email': email,
        if (role != null) 'role': role,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
        if (bio != null) 'bio': bio,
        if (tags.isNotEmpty) 'tags': tags,
        if (followersCount != null) 'followersCount': followersCount,
        if (followingCount != null) 'followingCount': followingCount,
        if (eventsCount != null) 'eventsCount': eventsCount,
        if (isFollowing != null) 'isFollowing': isFollowing,
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
        if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      };
}
