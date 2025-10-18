class CreateMomentRequestDto {
  const CreateMomentRequestDto({
    this.eventId,
    required this.title,
    this.content,
    required this.coverImageUrl,
    required this.country,
    this.city,
    required this.images,
  });

  factory CreateMomentRequestDto.fromJson(Map<String, dynamic> json) {
    return CreateMomentRequestDto(
      eventId: json['eventId'] as String?,
      title: json['title'] as String,
      content: json['content'] as String?,
      coverImageUrl: json['coverImageUrl'] as String,
      country: json['country'] as String,
      city: json['city'] as String?,
      images: (json['images'] as List<dynamic>).map((e) => e as String).toList(),
    );
  }

  final String? eventId;
  final String title;
  final String? content;
  final String coverImageUrl;
  final String country;
  final String? city;
  final List<String> images;

  Map<String, dynamic> toJson() => {
        'eventId': eventId,
        'title': title,
        'content': content,
        'coverImageUrl': coverImageUrl,
        'country': country,
        'city': city,
        'images': images,
      };
}
