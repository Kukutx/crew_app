class User {
  final String uid;
  final String name;
  final String? bio;
  final String? avatar;
  final String? cover;
  final int followers;
  final int following;
  final int likes;
  final bool followed;

  const User({
    required this.uid,
    required this.name,
    this.bio,
    this.avatar,
    this.cover,
    this.followers = 0,
    this.following = 0,
    this.likes = 0,
    this.followed = false,
  });

  User copyWith({
    String? name,
    String? bio,
    String? avatar,
    String? cover,
    int? followers,
    int? following,
    int? likes,
    bool? followed,
  }) {
    return User(
      uid: uid,
      name: name ?? this.name,
      bio: bio ?? this.bio,
      avatar: avatar ?? this.avatar,
      cover: cover ?? this.cover,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      likes: likes ?? this.likes,
      followed: followed ?? this.followed,
    );
  }
}

