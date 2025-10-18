import 'package:firebase_auth/firebase_auth.dart' as fa;

class EnsureUserRequest {
  EnsureUserRequest({
    required this.firebaseUid,
    required this.displayName,
    this.email,
    this.role = 'User',
    this.avatarUrl,
    this.bio,
    this.tags = const <String>[],
  });

  final String firebaseUid;
  final String displayName;
  final String? email;
  final String role;
  final String? avatarUrl;
  final String? bio;
  final List<String> tags;

  factory EnsureUserRequest.fromFirebaseUser(
    fa.User user, {
    String? role,
    List<String>? tags,
  }) {
    final displayName = user.displayName?.trim();
    final email = user.email?.trim();

    return EnsureUserRequest(
      firebaseUid: user.uid,
      displayName: (displayName != null && displayName.isNotEmpty)
          ? displayName
          : (email != null && email.isNotEmpty)
              ? email
              : 'Crew User',
      email: email,
      role: role ?? 'User',
      avatarUrl: user.photoURL,
      bio: null,
      tags: tags ?? const <String>[],
    );
  }

  Map<String, dynamic> toJson() => {
        'firebaseUid': firebaseUid,
        'displayName': displayName,
        if (email != null) 'email': email,
        'role': role,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
        if (bio != null) 'bio': bio,
        if (tags.isNotEmpty) 'tags': tags,
      };
}
