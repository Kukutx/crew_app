class User {
  final String uid;
  final String name;
  final String avatar;
  final String cover;
  final int followers;
  final int following;
  final int events;
  final bool followed;
  User({
    required this.uid,
    required this.name,
    required this.avatar,
    required this.cover,
    required this.followers,
    required this.following,
    required this.events,
    required this.followed,
  });

  User copyWith({bool? followed, int? followers}) => User(
        uid: uid,
        name: name,
        avatar: avatar,
        cover: cover,
        followers: followers ?? this.followers,
        following: following,
        events: events,
        followed: followed ?? this.followed,
      );
}

