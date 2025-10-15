import 'package:crew_app/features/user/domain/user_profile.dart';

class UserProfileDto {
  const UserProfileDto({
    required this.id,
    required this.displayName,
    required this.bio,
    required this.avatarUrl,
    required this.coverUrl,
    required this.followers,
    required this.following,
    required this.eventsHosted,
    required this.isFollowed,
    this.tags = const <String>[],
  });

  final String id;
  final String displayName;
  final String bio;
  final String avatarUrl;
  final String coverUrl;
  final int followers;
  final int following;
  final int eventsHosted;
  final bool isFollowed;
  final List<String> tags;

  factory UserProfileDto.fromJson(Map<String, dynamic> json) {
    return UserProfileDto(
      id: json['id']?.toString() ?? json['uid']?.toString() ?? '',
      displayName:
          json['name']?.toString() ?? json['displayName']?.toString() ?? '',
      bio: json['bio']?.toString() ?? '',
      avatarUrl:
          json['avatar']?.toString() ?? json['avatarUrl']?.toString() ?? '',
      coverUrl: json['cover']?.toString() ?? json['coverUrl']?.toString() ?? '',
      followers: (json['followers'] as num?)?.toInt() ?? 0,
      following: (json['following'] as num?)?.toInt() ?? 0,
      eventsHosted: (json['events'] as num?)?.toInt() ??
          (json['eventsHosted'] as num?)?.toInt() ??
          0,
      isFollowed: json['followed'] == true || json['isFollowed'] == true,
      tags: (json['tags'] as List<dynamic>? ?? const [])
          .map((tag) => tag.toString())
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': displayName,
        'bio': bio,
        'avatar': avatarUrl,
        'cover': coverUrl,
        'followers': followers,
        'following': following,
        'events': eventsHosted,
        'followed': isFollowed,
        if (tags.isNotEmpty) 'tags': tags,
      };

  UserProfile toDomain() => UserProfile(
        id: id,
        displayName: displayName,
        bio: bio,
        avatarUrl: avatarUrl,
        coverUrl: coverUrl,
        followers: followers,
        following: following,
        eventsHosted: eventsHosted,
        isFollowed: isFollowed,
        tags: tags,
      );
}
