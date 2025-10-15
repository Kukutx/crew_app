class UserProfile {
  const UserProfile({
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

  UserProfile copyWith({
    String? displayName,
    String? bio,
    String? avatarUrl,
    String? coverUrl,
    int? followers,
    int? following,
    int? eventsHosted,
    bool? isFollowed,
    List<String>? tags,
  }) {
    return UserProfile(
      id: id,
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      coverUrl: coverUrl ?? this.coverUrl,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      eventsHosted: eventsHosted ?? this.eventsHosted,
      isFollowed: isFollowed ?? this.isFollowed,
      tags: tags ?? this.tags,
    );
  }
}
