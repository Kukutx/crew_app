class EventSummaryDto {
  final String id;
  final String ownerId;
  final String title;
  final DateTime? startTime;
  final List<double> center; // [lon, lat]
  final int memberCount;
  final int maxParticipants;
  final bool isRegistered;
  final List<String>? tags;

  EventSummaryDto({
    required this.id,
    required this.ownerId,
    required this.title,
    this.startTime,
    required this.center,
    required this.memberCount,
    required this.maxParticipants,
    required this.isRegistered,
    this.tags,
  });

  factory EventSummaryDto.fromJson(Map<String, dynamic> json) => EventSummaryDto(
        id: json['id'] as String,
        ownerId: json['ownerId'] as String,
        title: json['title'] as String,
        startTime: json['startTime'] != null
            ? DateTime.parse(json['startTime'] as String)
            : null,
        center: _asDoubleList(json['center']),
        memberCount: (json['memberCount'] as num?)?.toInt() ?? 0,
        maxParticipants: (json['maxParticipants'] as num?)?.toInt() ?? 0,
        isRegistered: json['isRegistered'] as bool? ?? false,
        tags: _asStringList(json['tags']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'ownerId': ownerId,
        'title': title,
        'startTime': startTime?.toIso8601String(),
        'center': center,
        'memberCount': memberCount,
        'maxParticipants': maxParticipants,
        'isRegistered': isRegistered,
        'tags': tags,
      };
}

List<double> _asDoubleList(dynamic value) {
  if (value is List) {
    return value
        .whereType<num>()
        .map((item) => item.toDouble())
        .toList(growable: false);
  }
  return const <double>[];
}

List<String>? _asStringList(dynamic value) {
  if (value is List) {
    final result = value.whereType<String>().map((e) => e.trim()).toList();
    return result.isEmpty ? null : List.unmodifiable(result);
  }
  return null;
}
