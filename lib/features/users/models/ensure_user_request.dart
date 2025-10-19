import 'package:firebase_auth/firebase_auth.dart';

class EnsureUserRequest {
  EnsureUserRequest({
    required this.firebaseUid,
    this.displayName,
    this.email,
    this.role,
    this.avatarUrl,
    this.bio,
    this.tags,
  });

  factory EnsureUserRequest.fromFirebaseUser(User user) {
    final displayName = user.displayName?.trim();
    final email = user.email?.trim();
    final photoUrl = user.photoURL?.trim();
    return EnsureUserRequest(
      firebaseUid: user.uid,
      displayName:
          displayName != null && displayName.isNotEmpty ? displayName : null,
      email: email != null && email.isNotEmpty ? email : null,
      role: null,
      avatarUrl: photoUrl != null && photoUrl.isNotEmpty ? photoUrl : null,
      bio: null,
      tags: null,
    );
  }

  final String firebaseUid;
  final String? displayName;
  final String? email;
  final String? role;
  final String? avatarUrl;
  final String? bio;
  final List<String>? tags;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'firebaseUid': firebaseUid,
      'displayName': displayName,
      'email': email,
      'role': role,
      'avatarUrl': avatarUrl,
      'bio': bio,
      'tags': tags,
    };
  }
}
