import 'user_activity_dto.dart';
import 'user_guestbook_entry_dto.dart';
import 'user_history_dto.dart';

class UserProfileDto {
  final String id;
  final String displayName;
  final String email;
  final String role;
  final String? bio;
  final String? avatarUrl;
  final int followers;
  final int following;
  final List<String>? tags;
  final List<UserActivityDto> activities;
  final List<UserGuestbookEntryDto> guestbook;
  final List<UserHistoryDto> history;

  UserProfileDto({
    required this.id,
    required this.displayName,
    required this.email,
    required this.role,
    this.bio,
    this.avatarUrl,
    required this.followers,
    required this.following,
    this.tags,
    required this.activities,
    required this.guestbook,
    required this.history,
  });

  factory UserProfileDto.fromJson(Map<String, dynamic> json) => UserProfileDto(
        id: json['id'] as String,
        displayName: json['displayName'] as String,
        email: json['email'] as String,
        role: json['role'] as String,
        bio: json['bio'] as String?,
        avatarUrl: json['avatarUrl'] as String?,
        followers: (json['followers'] as num?)?.toInt() ?? 0,
        following: (json['following'] as num?)?.toInt() ?? 0,
        tags: _asStringList(json['tags']),
        activities: _asActivities(json['activities']),
        guestbook: _asGuestbook(json['guestbook']),
        history: _asHistory(json['history']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'displayName': displayName,
        'email': email,
        'role': role,
        'bio': bio,
        'avatarUrl': avatarUrl,
        'followers': followers,
        'following': following,
        'tags': tags,
        'activities': activities.map((e) => e.toJson()).toList(),
        'guestbook': guestbook.map((e) => e.toJson()).toList(),
        'history': history.map((e) => e.toJson()).toList(),
      };
}

List<String>? _asStringList(dynamic value) {
  if (value is List) {
    final result = value.whereType<String>().map((e) => e.trim()).toList();
    return result.isEmpty ? null : List.unmodifiable(result);
  }
  return null;
}

List<UserActivityDto> _asActivities(dynamic value) {
  if (value is List) {
    return value
        .whereType<Map<String, dynamic>>()
        .map(UserActivityDto.fromJson)
        .toList(growable: false);
  }
  return const <UserActivityDto>[];
}

List<UserGuestbookEntryDto> _asGuestbook(dynamic value) {
  if (value is List) {
    return value
        .whereType<Map<String, dynamic>>()
        .map(UserGuestbookEntryDto.fromJson)
        .toList(growable: false);
  }
  return const <UserGuestbookEntryDto>[];
}

List<UserHistoryDto> _asHistory(dynamic value) {
  if (value is List) {
    return value
        .whereType<Map<String, dynamic>>()
        .map(UserHistoryDto.fromJson)
        .toList(growable: false);
  }
  return const <UserHistoryDto>[];
}
