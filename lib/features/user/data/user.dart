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
  final String? countryCode;

  String? get countryFlag => countryCodeToEmoji(countryCode);

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
    this.tags = const [],
    this.countryCode,
  });

  User copyWith({
    String? name,
    String? bio,
    String? avatar,
    String? cover,
    int? followers,
    int? following,
    int? events,
    bool? followed,
    List<String>? tags,
    String? countryCode,
  }) =>
      User(
        uid: uid,
        name: name ?? this.name,
        bio: bio ?? this.bio,
        avatar: avatar ?? this.avatar,
        cover: cover ?? this.cover,
        followers: followers ?? this.followers,
        following: following ?? this.following,
        events: events ?? this.events,
        followed: followed ?? this.followed,
        tags: tags ?? this.tags,
        countryCode: countryCode ?? this.countryCode,
      );
}

String? countryCodeToEmoji(String? countryCode) {
  if (countryCode == null || countryCode.length != 2) {
    return null;
  }

  final upper = countryCode.toUpperCase();
  final codeUnits = upper.codeUnits
      .map((unit) => 0x1F1E6 + unit - 'A'.codeUnitAt(0))
      .toList();
  return String.fromCharCodes(codeUnits);
}
