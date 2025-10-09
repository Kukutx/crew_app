/// A lightweight draft of an event created from the map sheet form.
///
/// The structure is intentionally simple so that it can be serialized directly
/// when integrating with a backend API.
class EventDraft {
  const EventDraft({
    required this.title,
    required this.description,
    required this.locationName,
    this.imagePaths = const <String>[],
    this.coverImageIndex,
  });

  final String title;
  final String description;
  final String locationName;
  final List<String> imagePaths;
  final int? coverImageIndex;

  EventDraft copyWith({
    String? title,
    String? description,
    String? locationName,
    List<String>? imagePaths,
    int? coverImageIndex,
  }) {
    return EventDraft(
      title: title ?? this.title,
      description: description ?? this.description,
      locationName: locationName ?? this.locationName,
      imagePaths: imagePaths ?? this.imagePaths,
      coverImageIndex: coverImageIndex ?? this.coverImageIndex,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'locationName': locationName,
        'imagePaths': imagePaths,
        'coverImageIndex': coverImageIndex,
      };
}
