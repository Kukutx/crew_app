class AuthenticatedUserDto {
  AuthenticatedUserDto({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.coverUrl,
    this.bio,
    this.followers,
    this.following,
    this.likes,
    this.isFollowed,
    this.roles = const [],
    this.hasActiveSubscription = false,
  });

  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final String? coverUrl;
  final String? bio;
  final int? followers;
  final int? following;
  final int? likes;
  final bool? isFollowed;
  final List<String> roles;
  final bool hasActiveSubscription;

  factory AuthenticatedUserDto.fromJson(Map<String, dynamic> json) {
    final subscription = json['subscription'];
    final profile = json['profile'] as Map<String, dynamic>?;
    final stats = json['stats'] as Map<String, dynamic>?;

    return AuthenticatedUserDto(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
      coverUrl: _readString(profile, 'coverUrl') ?? json['coverUrl'] as String?,
      bio: _readString(profile, 'bio') ?? json['bio'] as String?,
      followers: _readInt(stats, 'followers') ?? _readInt(profile, 'followers'),
      following: _readInt(stats, 'following') ?? _readInt(profile, 'following'),
      likes: _readInt(stats, 'likes') ?? _readInt(profile, 'likes'),
      isFollowed: _readBool(json, 'isFollowed') ?? _readBool(profile, 'followed'),
      roles: (json['roles'] as List<dynamic>? ?? const [])
          .map((role) => role.toString())
          .toList(),
      hasActiveSubscription:
          subscription is Map<String, dynamic> && subscription['isActive'] == true,
    );
  }

  static String? _readString(Map<String, dynamic>? json, String key) {
    final value = json?[key];
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isNotEmpty) {
        return trimmed;
      }
    }
    return null;
  }

  static int? _readInt(Map<String, dynamic>? json, String key) {
    final value = json?[key];
    if (value is int) {
      return value;
    }
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  static bool? _readBool(Map<String, dynamic>? json, String key) {
    final value = json?[key];
    if (value is bool) {
      return value;
    }
    if (value is String) {
      if (value.toLowerCase() == 'true') return true;
      if (value.toLowerCase() == 'false') return false;
    }
    return null;
  }
}
