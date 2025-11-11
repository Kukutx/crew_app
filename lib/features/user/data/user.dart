import 'package:crew_app/shared/utils/country_helper.dart';

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
    final String? customGender;
    final String? city;
    final String? ipLocation; // IP属地

  String? get countryFlag => CountryHelper.countryCodeToEmoji(countryCode);

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
    this.customGender,
    this.city,
    this.ipLocation,
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
    Object? customGender = _sentinel,
    Object? city = _sentinel,
    Object? ipLocation = _sentinel,
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
        customGender: customGender == _sentinel
            ? this.customGender
            : customGender as String?,
        city:
            city == _sentinel ? this.city : city as String?,
        ipLocation: ipLocation == _sentinel
            ? this.ipLocation
            : ipLocation as String?,
      );
}
