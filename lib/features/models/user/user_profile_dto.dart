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
        id: json['id'],
        displayName: json['displayName'],
        email: json['email'],
        role: json['role'],
        bio: json['bio'],
        avatarUrl: json['avatarUrl'],
        followers: json['followers'],
        following: json['following'],
        tags: (json['tags'] as List?)?.map((e) => e as String).toList(),
        activities: (json['activities'] as List).map((e) => UserActivityDto.fromJson(e)).toList(),
        guestbook: (json['guestbook'] as List).map((e) => UserGuestbookEntryDto.fromJson(e)).toList(),
        history: (json['history'] as List).map((e) => UserHistoryDto.fromJson(e)).toList(),
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
