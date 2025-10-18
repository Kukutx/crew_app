import 'json_helpers.dart';

class MomentSummaryDto {
  final String id;
  final String userId;
  final String userDisplayName;
  final String title;
  final String? coverImageUrl;
  final String? country;
  final String? city;
  final DateTime createdAt;

  MomentSummaryDto({
    required this.id,
    required this.userId,
    required this.userDisplayName,
    required this.title,
    this.coverImageUrl,
    this.country,
    this.city,
    required this.createdAt,
  });

  factory MomentSummaryDto.fromJson(Map<String, dynamic> json) => MomentSummaryDto(
        id: json['id']?.toString() ?? '',
        userId: json['userId']?.toString() ?? '',
        userDisplayName: json['userDisplayName']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        coverImageUrl: json['coverImageUrl'] as String?,
        country: json['country'] as String?,
        city: json['city'] as String?,
        createdAt: parseDateTime(json['createdAt']) ?? DateTime.now().toUtc(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'userDisplayName': userDisplayName,
        'title': title,
        'coverImageUrl': coverImageUrl,
        'country': country,
        'city': city,
        'createdAt': createdAt.toIso8601String(),
      };
}
