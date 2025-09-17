class User {
  final String uid;
  final String name;
  final String bio;
  final String avatar;
  final String cover;
  final int followers;
  final int following;
  final int likes;
  final bool followed;
  User({
    required this.uid,
    required this.name,
    required this.bio,
    required this.avatar,
    required this.cover,
    required this.followers,
    required this.following,
    required this.likes,
    required this.followed,
  });

  User copyWith({bool? followed, int? followers}) => User(
        uid: uid,
        name: name,
        bio: bio,
        avatar: avatar,
        cover: cover,
        followers: followers ?? this.followers,
        following: following,
        likes: likes,
        followed: followed ?? this.followed,
      );
}

