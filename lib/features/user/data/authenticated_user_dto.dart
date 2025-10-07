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
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
      roles: (json['roles'] as List<dynamic>? ?? const [])
          .map((role) => role.toString())
          .toList(),
      hasActiveSubscription:
          subscription is Map<String, dynamic> && subscription['isActive'] == true,
    );
  }
}
