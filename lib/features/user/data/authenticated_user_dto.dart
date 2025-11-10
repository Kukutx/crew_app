class AuthenticatedUserDto {
  AuthenticatedUserDto({
    required this.uid,
  });

  final String uid;

  factory AuthenticatedUserDto.fromJson(Map<String, dynamic> json) {
    return AuthenticatedUserDto(
      uid: json['uid'] as String,
    );
  }
}
