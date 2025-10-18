class UserSummaryDto {
  final String id;
  final String displayName;
  final String email;
  final String role;
  final String? avatarUrl;
  final DateTime createdAt;

  UserSummaryDto({
    required this.id,
    required this.displayName,
    required this.email,
    required this.role,
    this.avatarUrl,
    required this.createdAt,
  });

  factory UserSummaryDto.fromJson(Map<String, dynamic> json) => UserSummaryDto(
        id: json['id'],
        displayName: json['displayName'],
        email: json['email'],
        role: json['role'],
        avatarUrl: json['avatarUrl'],
        createdAt: DateTime.parse(json['createdAt']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'displayName': displayName,
        'email': email,
        'role': role,
        'avatarUrl': avatarUrl,
        'createdAt': createdAt.toIso8601String(),
      };
}
