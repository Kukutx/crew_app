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
        id: json['id'],
        userId: json['userId'],
        userDisplayName: json['userDisplayName'],
        title: json['title'],
        coverImageUrl: json['coverImageUrl'],
        country: json['country'],
        city: json['city'],
        createdAt: DateTime.parse(json['createdAt']),
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
