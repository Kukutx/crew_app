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

  Map<String, dynamic> toJson() {
    final normalizedTags = tags
        ?.map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList(growable: false);

    return <String, dynamic>{
      'firebaseUid': firebaseUid.trim(),
      'displayName': displayName.trim(),
      'email': email.trim(),
      'role': role.trim(),
      if (_normalizeOptional(avatarUrl) != null)
        'avatarUrl': _normalizeOptional(avatarUrl),
      if (_normalizeOptional(bio) != null) 'bio': _normalizeOptional(bio),
      if (normalizedTags != null && normalizedTags.isNotEmpty)
        'tags': normalizedTags,
    };
  }
}

String? _normalizeOptional(String? value) {
  if (value == null) {
    return null;
  }
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
