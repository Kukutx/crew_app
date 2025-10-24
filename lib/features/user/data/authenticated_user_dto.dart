class AuthenticatedUserDto {
  AuthenticatedUserDto({
    required this.uid,
    required this.aspNetIdentityId,
  });

  final String uid;
  final String aspNetIdentityId;

  factory AuthenticatedUserDto.fromJson(Map<String, dynamic> json) {
    return AuthenticatedUserDto(
      uid: json['uid'] as String,
      aspNetIdentityId: json['aspNetIdentityId'] as String,
    );
  }
}
