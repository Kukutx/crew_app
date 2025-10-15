class AuthenticatedUserDto {
  AuthenticatedUserDto({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.roles = const [],
    this.hasActiveSubscription = false,
  });

  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final List<String> roles;
  final bool hasActiveSubscription;

  factory AuthenticatedUserDto.fromJson(Map<String, dynamic> json) {
    final subscription = json['subscription'];

    return AuthenticatedUserDto(
      id: json['id']?.toString() ?? json['uid']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      displayName: json['displayName']?.toString(),
      photoUrl: json['photoUrl']?.toString(),
      roles: (json['roles'] as List<dynamic>? ?? const [])
          .map((role) => role.toString())
          .toList(growable: false),
      hasActiveSubscription:
          subscription is Map<String, dynamic> && subscription['isActive'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        if (displayName != null) 'displayName': displayName,
        if (photoUrl != null) 'photoUrl': photoUrl,
        if (roles.isNotEmpty) 'roles': roles,
        'subscription': {
          'isActive': hasActiveSubscription,
        },
      };

  AuthenticatedUserDto copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    List<String>? roles,
    bool? hasActiveSubscription,
  }) {
    return AuthenticatedUserDto(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      roles: roles ?? this.roles,
      hasActiveSubscription:
          hasActiveSubscription ?? this.hasActiveSubscription,
    );
  }
}
