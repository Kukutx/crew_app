class EnsureUserRequest {
  final String firebaseUid;
  final String displayName;
  final String email;
  final String role;
  final String? avatarUrl;
  final String? bio;
  /// 可为 null
  final List<String>? tags;

  EnsureUserRequest({
    required this.firebaseUid,
    required this.displayName,
    required this.email,
    required this.role,
    this.avatarUrl,
    this.bio,
    this.tags,
  });

  factory EnsureUserRequest.fromJson(Map<String, dynamic> json) => EnsureUserRequest(
        firebaseUid: json['firebaseUid'],
        displayName: json['displayName'],
        email: json['email'],
        role: json['role'],
        avatarUrl: json['avatarUrl'],
        bio: json['bio'],
        tags: (json['tags'] as List?)?.map((e) => e as String).toList(),
      );

  Map<String, dynamic> toJson() => {
        'firebaseUid': firebaseUid,
        'displayName': displayName,
        'email': email,
        'role': role,
        'avatarUrl': avatarUrl,
        'bio': bio,
        'tags': tags,
      };
}
