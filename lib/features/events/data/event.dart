import 'package:crew_app/shared/utils/json_parser_helper.dart';

class EventHost {
  final String id;
  final String name;
  final String? avatarUrl;
  final String? bio;
  final String? username;

  const EventHost({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.bio,
    this.username,
  });

  factory EventHost.fromJson(Map<String, dynamic> json) {
    return EventHost(
      id: JsonParserHelper.parseString(json['id']) ?? '',
      name: JsonParserHelper.parseString(json['name']) ?? '',
      avatarUrl: JsonParserHelper.parseString(json['avatarUrl']),
      bio: JsonParserHelper.parseString(json['bio']),
      username: JsonParserHelper.parseString(json['username']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
        if (bio != null) 'bio': bio,
        if (username != null) 'userName': username,
      };
}

enum EventWaypointDirection { forward, returnTrip }

class EventWaypointSegment {
  const EventWaypointSegment({
    required this.seq,
    required this.longitude,
    required this.latitude,
    required this.direction,
    this.note,
  });

  factory EventWaypointSegment.fromJson(Map<String, dynamic> json) {
      final waypoint = (json['waypoint'] as List<dynamic>? ?? const [])
        .map((value) => JsonParserHelper.parseDouble(value) ?? 0.0)
        .toList();
    final longitude = waypoint.isNotEmpty ? waypoint.first.toDouble() : 0.0;
    final latitude = waypoint.length > 1 ? waypoint[1].toDouble() : 0.0;

    return EventWaypointSegment(
      seq: JsonParserHelper.parseInt(json['seq']) ?? 0,
      longitude: longitude,
      latitude: latitude,
      direction: _parseWaypointDirection(json['direction']),
      note: JsonParserHelper.parseString(json['note']),
    );
  }

  final int seq;
  final double longitude;
  final double latitude;
  final EventWaypointDirection direction;
  final String? note;
}

class Event {
  final String id;
  final String title;
  final String location;
  final String description;
  final double latitude;
  final double longitude;
  final List<String> imageUrls;
  final List<String> videoUrls;
  final String? coverImageUrl;
  final String? address;
  final DateTime? startTime;
  final DateTime? endTime;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? maxMembers;
  final int? currentMembers;
  final int favoriteCount;
  final bool isFavorite;
  final bool isRegistered;
  final bool isFree;
  final double? price;
  final List<String> tags;
  final List<EventWaypointSegment> waypointSegments;
  final bool? isRoundTrip;
  final EventHost? host;
  final EventStatus? status;

  const Event({
    required this.id,
    required this.title,
    required this.location,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.imageUrls,
    this.videoUrls = const <String>[],
    this.coverImageUrl,
    this.address,
    this.startTime,
    this.endTime,
    this.createdAt,
    this.updatedAt,
    this.maxMembers,
    this.currentMembers,
    this.favoriteCount = 0,
    this.isFavorite = false,
    this.isRegistered = false,
    this.isFree = false,
    this.price,
    this.tags = const <String>[],
    this.waypointSegments = const <EventWaypointSegment>[],
    this.isRoundTrip,
    this.host,
    this.status,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    final hostJson = json['host'] as Map<String, dynamic>?;

    return Event(
      id: JsonParserHelper.parseString(json['id']) ?? '',
      title: JsonParserHelper.parseString(json['title']) ?? '',
      location: JsonParserHelper.parseString(json['location']) ?? '',
      description: JsonParserHelper.parseString(json['description']) ?? '',
      latitude: JsonParserHelper.parseDouble(json['latitude']) ?? 0,
      longitude: JsonParserHelper.parseDouble(json['longitude']) ?? 0,
      imageUrls: List.unmodifiable(JsonParserHelper.parseStringList(json['imageUrls'])),
      videoUrls: List.unmodifiable(JsonParserHelper.parseStringList(json['videoUrls'])),
      coverImageUrl: JsonParserHelper.parseString(json['coverImageUrl']),
      address: JsonParserHelper.parseString(json['address']),
      startTime: JsonParserHelper.parseDate(json['startTime']),
      endTime: JsonParserHelper.parseDate(json['endTime']),
      createdAt: JsonParserHelper.parseDate(json['createdAt']),
      updatedAt: JsonParserHelper.parseDate(json['updatedAt']),
      maxMembers: JsonParserHelper.parseInt(json['maxMembers']),
      currentMembers: JsonParserHelper.parseInt(json['currentMembers']),
      isFavorite: JsonParserHelper.parseBool(json['isFavorite']) ?? false,
      favoriteCount: JsonParserHelper.parseInt(json['favoriteCount']) ?? 0,
      isRegistered: JsonParserHelper.parseBool(json['isRegistered']) ?? false,
      isFree: JsonParserHelper.parseBool(json['isFree']) ?? false,
      price: JsonParserHelper.parseDouble(json['price']),
      tags: List.unmodifiable(JsonParserHelper.parseStringList(json['tags'])),
      waypointSegments: List.unmodifiable(
        (json['segments'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(EventWaypointSegment.fromJson),
      ),
      isRoundTrip: JsonParserHelper.parseBool(json['isRoundTrip']),
      host: hostJson != null ? EventHost.fromJson(hostJson) : null,
      status: _parseEventStatus(json['status']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'location': location,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'imageUrls': imageUrls,
        if (videoUrls.isNotEmpty) 'videoUrls': videoUrls,
        'coverImageUrl': coverImageUrl,
        'startTime': startTime?.toIso8601String(),
        'endTime': endTime?.toIso8601String(),
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'maxMembers': maxMembers,
        'currentMembers': currentMembers,
        'favoriteCount': favoriteCount,
        'isFavorite': isFavorite,
        'isRegistered': isRegistered,
        'isFree': isFree,
        'price': price,
        'tags': tags,
        if (waypointSegments.isNotEmpty)
          'segments': waypointSegments
              .map((segment) => {
                    'seq': segment.seq,
                    'waypoint': [segment.longitude, segment.latitude],
                    'note': segment.note,
                    'direction': segment.direction == EventWaypointDirection.returnTrip
                        ? 'return'
                        : 'forward',
                  })
              .toList(),
        if (isRoundTrip != null) 'isRoundTrip': isRoundTrip,
        if (host != null) 'host': host!.toJson(),
        if (status != null) 'status': status,
      };

  /// Returns the first non-empty image URL among [imageUrls] and
  /// [coverImageUrl]. If no URL is available, `null` is returned.
  String? get firstAvailableImageUrl {
    for (final url in [...imageUrls, if (coverImageUrl != null) coverImageUrl!]) {
      final trimmed = url.trim();
      if (trimmed.isNotEmpty) {
        return trimmed;
      }
    }
    return null;
  }

  bool get isFull =>
      maxMembers != null &&
      currentMembers != null &&
      currentMembers! >= maxMembers!;

  String? get memberSummary {
    if (currentMembers == null && maxMembers == null) {
      return null;
    }
    final current = currentMembers;
    final max = maxMembers;
    if (current != null && max != null) {
      return '$current/$max';
    }
    return (current ?? max).toString();
  }
}

EventWaypointDirection _parseWaypointDirection(dynamic value) {
  final name = JsonParserHelper.parseString(value)?.toLowerCase();
  return name == 'return' ? EventWaypointDirection.returnTrip : EventWaypointDirection.forward;
}

EventStatus? _parseEventStatus(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is EventStatus) {
    return value;
  }
  dynamic raw = value;
  if (raw is Map<String, dynamic>) {
    raw = raw['name'] ?? raw['status'] ?? raw['value'];
  }
  if (raw is Enum) {
    raw = raw.name;
  }
  final text = raw?.toString();
  if (text == null) {
    return null;
  }
  final normalized = text.trim();
  if (normalized.isEmpty) {
    return null;
  }
  final lower = normalized.toLowerCase();
  final key = lower.contains('.') ? lower.split('.').last : lower;
  switch (key) {
    case 'reviewing':
    case 'under_review':
    case 'pending_review':
    case 'review':
      return EventStatus.reviewing;
    case 'recruiting':
    case 'recruitment':
    case 'open':
    case 'signup':
    case 'sign_up':
      return EventStatus.recruiting;
    case 'ongoing':
    case 'in_progress':
    case 'progress':
    case 'running':
    case 'active':
      return EventStatus.ongoing;
    case 'ended':
    case 'finished':
    case 'complete':
    case 'completed':
    case 'closed':
    case 'done':
      return EventStatus.ended;
    default:
      return null;
  }
}

enum EventStatus { reviewing, recruiting, ongoing, ended }
