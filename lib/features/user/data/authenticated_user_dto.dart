class AuthenticatedUserDto {
  AuthenticatedUserDto({
    required this.uid,
    required this.aspNetIdentityId,
    required this.email,
  });

  final String uid;
  final String aspNetIdentityId;
  final String email;

  factory AuthenticatedUserDto.fromJson(Map<String, dynamic> json) {
    return AuthenticatedUserDto(
      uid: json['uid'] as String,
      aspNetIdentityId: json['aspNetIdentityId'] as String,
      email: json['email'] as String,
    );
  }
}
