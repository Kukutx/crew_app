import '../common/json_utils.dart';
import 'moment_comment_dto.dart';

class MomentDetailDto {
  const MomentDetailDto({
    required this.id,
    required this.userId,
    this.userDisplayName,
    required this.title,
    this.content,
    required this.coverImageUrl,
    required this.country,
    this.city,
    required this.createdAt,
    required this.images,
    required this.comments,
  });

  factory MomentDetailDto.fromJson(Map<String, dynamic> json) {
    return MomentDetailDto(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userDisplayName: json['userDisplayName'] as String?,
      title: json['title'] as String,
      content: json['content'] as String?,
      coverImageUrl: json['coverImageUrl'] as String,
      country: json['country'] as String,
      city: json['city'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      images: toStringList(json['images']),
      comments: (json['comments'] as List<dynamic>)
          .map((e) => MomentCommentDto.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
    );
  }

  final String id;
  final String userId;
  final String? userDisplayName;
  final String title;
  final String? content;
  final String coverImageUrl;
  final String country;
  final String? city;
  final DateTime createdAt;
  final List<String> images;
  final List<MomentCommentDto> comments;

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'userDisplayName': userDisplayName,
        'title': title,
        'content': content,
        'coverImageUrl': coverImageUrl,
        'country': country,
        'city': city,
        'createdAt': createdAt.toIso8601String(),
        'images': images,
        'comments': comments.map((e) => e.toJson()).toList(),
      };
}
