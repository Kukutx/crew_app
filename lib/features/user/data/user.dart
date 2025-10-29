enum Gender {
  female,
  male,
  custom,
  undisclosed,
}

extension GenderEmoji on Gender {
  String get emoji {
    switch (this) {
      case Gender.female:
        return '♀';
      case Gender.male:
        return '♂';
      case Gender.custom:
        return '⚧';
      case Gender.undisclosed:
        return '✦';
    }
  }

  bool get shouldDisplay => this != Gender.undisclosed;
}

const _sentinel = Object();

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
  final Gender gender;
  final DateTime? birthday;
  final String? school;
  final String? location;

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
    this.gender = Gender.undisclosed,
    this.tags = const [],
    this.countryCode,
    this.birthday,
    this.school,
    this.location,
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
    Gender? gender,
    Object? birthday = _sentinel,
    Object? school = _sentinel,
    Object? location = _sentinel,
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
        gender: gender ?? this.gender,
        birthday: birthday == _sentinel ? this.birthday : birthday as DateTime?,
        school: school == _sentinel ? this.school : school as String?,
        location:
            location == _sentinel ? this.location : location as String?,
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
