class User {
  final String uid;
  final String name;
  final String bio;
  final String avatar;
  final String cover;
  final int followers;
  final int following;
  final int events;
  final bool followed;
  final List<String> tags;
  User({
    required this.uid,
    required this.name,
    required this.bio,
    required this.avatar,
    required this.cover,
    required this.followers,
    required this.following,
    required this.events,
    required this.followed,
    required this.tags,
  });

  User copyWith({bool? followed, int? followers, List<String>? tags}) => User(
        uid: uid,
        name: name,
        bio: bio,
        avatar: avatar,
        cover: cover,
        followers: followers ?? this.followers,
        following: following,
        events: events,
        followed: followed ?? this.followed,
        tags: tags ?? this.tags,
      );
}

