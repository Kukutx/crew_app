class Event {
  final int id;
  final String title;
  final String location;
  final String description;
  final double latitude;
  final double longitude;
  final List<String> imageUrls;
  final String coverImageUrl;
  final EventUserSummary? createdByUser;
  final String? createdByUserId;
  final String? createdByUserName;
  final String? createdByUserPhotoUrl;
  final String? createdByUserBio;

  Event({
    required this.id,
    required this.title,
    required this.location,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.imageUrls,
    required this.coverImageUrl,
    this.createdByUser,
    this.createdByUserId,
    this.createdByUserName,
    this.createdByUserPhotoUrl,
    this.createdByUserBio,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    String? _readString(dynamic value) {
      if (value is String) {
        final trimmed = value.trim();
        return trimmed.isEmpty ? null : trimmed;
      }
      return null;
    }

    EventUserSummary? _readUserSummary(dynamic value) {
      if (value is Map<String, dynamic>) {
        return EventUserSummary.fromJson(value);
      }
      return null;
    }

    final createdBy = _readUserSummary(
      json['createdByUser'] ?? json['createdBy'] ?? json['creator'],
    );

    final createdById = _readString(json['createdByUserId']) ??
        _readString(json['createdById']) ??
        _readString(json['creatorId']) ??
        createdBy?.id;

    final createdByName = _readString(json['createdByUserName']) ??
        _readString(json['createdByName']) ??
        _readString(json['creatorName']) ??
        _readString(json['organizerName']) ??
        createdBy?.displayName ??
        createdBy?.name;

    final createdByPhoto = _readString(json['createdByUserPhotoUrl']) ??
        _readString(json['createdByPhotoUrl']) ??
        _readString(json['creatorPhotoUrl']) ??
        _readString(json['organizerAvatar']) ??
        _readString(json['avatarUrl']) ??
        createdBy?.photoUrl;

    final createdByBio = _readString(json['createdByUserBio']) ??
        _readString(json['createdByBio']) ??
        _readString(json['creatorBio']) ??
        _readString(json['organizerBio']) ??
        createdBy?.bio;

    return Event(
      id: json['id'] as int,
      title: json['title'] as String,
      location: json['location'] as String,
      description: json['description'] as String,
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      imageUrls: (json['imageUrls'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      coverImageUrl: json['coverImageUrl'] as String? ?? '',
      createdByUser: createdBy,
      createdByUserId: createdById,
      createdByUserName: createdByName,
      createdByUserPhotoUrl: createdByPhoto,
      createdByUserBio: createdByBio,
    );
  }

  /// Returns the first non-empty image URL among [imageUrls] and
  /// [coverImageUrl]. If no URL is available, `null` is returned.
  String? get firstAvailableImageUrl {
    for (final url in [...imageUrls, coverImageUrl]) {
      final trimmed = url.trim();
      if (trimmed.isNotEmpty) {
        return trimmed;
      }
    }
    return null;
  }

  String? get hostDisplayName {
    final candidates = [
      createdByUser?.displayName,
      createdByUserName,
      createdByUser?.name,
      createdByUser?.email,
    ];
    for (final value in candidates) {
      final trimmed = value?.trim();
      if (trimmed != null && trimmed.isNotEmpty) {
        return trimmed;
      }
    }
    return null;
  }

  String? get hostBio {
    final candidates = [createdByUser?.bio, createdByUserBio];
    for (final value in candidates) {
      final trimmed = value?.trim();
      if (trimmed != null && trimmed.isNotEmpty) {
        return trimmed;
      }
    }
    return null;
  }

  String? get hostAvatarUrl {
    final candidates = [createdByUser?.photoUrl, createdByUserPhotoUrl];
    for (final value in candidates) {
      final trimmed = value?.trim();
      if (trimmed != null && trimmed.isNotEmpty) {
        return trimmed;
      }
    }
    return null;
  }

  String? get hostUserId => createdByUser?.id ?? createdByUserId;
}

class EventUserSummary {
  const EventUserSummary({
    required this.id,
    this.displayName,
    this.name,
    this.email,
    this.photoUrl,
    this.bio,
  });

  final String id;
  final String? displayName;
  final String? name;
  final String? email;
  final String? photoUrl;
  final String? bio;

  factory EventUserSummary.fromJson(Map<String, dynamic> json) {
    String? _readString(dynamic value) {
      if (value is String) {
        final trimmed = value.trim();
        return trimmed.isEmpty ? null : trimmed;
      }
      return null;
    }

    final id = _readString(json['id']) ??
        _readString(json['userId']) ??
        _readString(json['uid']) ??
        _readString(json['identifier']) ??
        'unknown';

    return EventUserSummary(
      id: id,
      displayName: _readString(json['displayName']) ??
          _readString(json['nickName']) ??
          _readString(json['userName']) ??
          _readString(json['username']),
      name: _readString(json['name']) ?? _readString(json['fullName']),
      email: _readString(json['email']),
      photoUrl: _readString(json['photoUrl']) ??
          _readString(json['avatarUrl']) ??
          _readString(json['avatar']) ??
          _readString(json['profileImageUrl']),
      bio: _readString(json['bio']) ??
          _readString(json['about']) ??
          _readString(json['headline']) ??
          _readString(json['description']),
    );
  }
}
