class MomentSummaryDto {
  const MomentSummaryDto({
    required this.id,
    required this.userId,
    this.userDisplayName,
    required this.title,
    required this.coverImageUrl,
    required this.country,
    this.city,
    required this.createdAt,
  });

  factory MomentSummaryDto.fromJson(Map<String, dynamic> json) {
    return MomentSummaryDto(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userDisplayName: json['userDisplayName'] as String?,
      title: json['title'] as String,
      coverImageUrl: json['coverImageUrl'] as String,
      country: json['country'] as String,
      city: json['city'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  final String id;
  final String userId;
  final String? userDisplayName;
  final String title;
  final String coverImageUrl;
  final String country;
  final String? city;
  final DateTime createdAt;

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
