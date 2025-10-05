import 'package:flutter/foundation.dart';

@immutable
class UserProfileSummary {
  final String id;
  final String name;
  final String? bio;
  final String? avatarUrl;
  final String? coverImageUrl;
  final int? followers;
  final int? following;
  final int? likes;
  final bool? isFollowing;

  const UserProfileSummary({
    required this.id,
    required this.name,
    this.bio,
    this.avatarUrl,
    this.coverImageUrl,
    this.followers,
    this.following,
    this.likes,
    this.isFollowing,
  });

  factory UserProfileSummary.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? asMap(dynamic value) {
      if (value is Map<String, dynamic>) {
        return value;
      }
      if (value is Map) {
        return value.map((key, value) => MapEntry(key.toString(), value));
      }
      return null;
    }

    String? parseString(dynamic value) {
      if (value == null) return null;
      final str = value.toString().trim();
      return str.isEmpty ? null : str;
    }

    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value.toString());
    }

    bool? parseBool(dynamic value) {
      if (value == null) return null;
      if (value is bool) return value;
      if (value is num) return value != 0;
      final lower = value.toString().toLowerCase();
      if (lower == 'true' || lower == 'yes' || lower == '1') {
        return true;
      }
      if (lower == 'false' || lower == 'no' || lower == '0') {
        return false;
      }
      return null;
    }

    final profile =
        asMap(json['profile']) ?? asMap(json['userProfile']) ?? asMap(json['detail']);
    final stats = asMap(json['stats']) ??
        asMap(json['statistics']) ??
        asMap(json['counts']) ??
        asMap(json['metrics']);

    final id = parseString(
          json['id'] ??
              json['uid'] ??
              json['userId'] ??
              json['ownerId'] ??
              profile?['id'] ??
              profile?['uid'],
        ) ??
        '';

    final name = parseString(
          json['name'] ??
              json['displayName'] ??
              json['nickname'] ??
              json['userName'] ??
              json['fullName'] ??
              profile?['name'] ??
              profile?['displayName'],
        ) ??
        '';

    return UserProfileSummary(
      id: id,
      name: name,
      bio: parseString(json['bio'] ?? profile?['bio'] ?? json['introduction']),
      avatarUrl: parseString(
        json['avatarUrl'] ??
            json['avatar'] ??
            json['profileImage'] ??
            json['photoUrl'] ??
            profile?['avatarUrl'] ??
            profile?['photoUrl'],
      ),
      coverImageUrl: parseString(
        json['coverImage'] ??
            json['coverImageUrl'] ??
            json['coverUrl'] ??
            profile?['coverImage'] ??
            profile?['cover'],
      ),
      followers: parseInt(
        json['followers'] ??
            json['followersCount'] ??
            stats?['followers'] ??
            stats?['followerCount'] ??
            stats?['followersCount'],
      ),
      following: parseInt(
        json['following'] ??
            json['followingCount'] ??
            stats?['following'] ??
            stats?['followingCount'],
      ),
      likes: parseInt(
        json['likes'] ??
            json['likesCount'] ??
            stats?['likes'] ??
            stats?['likesCount'] ??
            stats?['likeCount'],
      ),
      isFollowing: parseBool(
        json['isFollowing'] ??
            json['followed'] ??
            json['isFollowed'] ??
            stats?['isFollowing'] ??
            stats?['followed'],
      ),
    );
  }

  UserProfileSummary copyWith({
    String? id,
    String? name,
    String? bio,
    String? avatarUrl,
    String? coverImageUrl,
    int? followers,
    int? following,
    int? likes,
    bool? isFollowing,
  }) {
    return UserProfileSummary(
      id: id ?? this.id,
      name: name ?? this.name,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      likes: likes ?? this.likes,
      isFollowing: isFollowing ?? this.isFollowing,
    );
  }
}
