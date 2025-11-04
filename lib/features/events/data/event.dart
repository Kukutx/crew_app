import 'package:crew_app/shared/utils/json_parser_helper.dart';

class EventOrganizer {
  final String id;
  final String name;
  final String? avatarUrl;
  final String? bio;
  final String? username;

  const EventOrganizer({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.bio,
    this.username,
  });

  factory EventOrganizer.fromJson(Map<String, dynamic> json) {
    final profile = JsonParserHelper.asMap(json['profile']);
    return EventOrganizer(
      id: JsonParserHelper.parseString(
            json['id'] ??
                json['userId'] ??
                json['organizerId'] ??
                profile?['id'],
          ) ??
          '',
      name: JsonParserHelper.parseString(
            json['name'] ??
                json['displayName'] ??
                json['nickname'] ??
                json['userName'] ??
                json['organizerName'] ??
                profile?['name'],
          ) ??
          '',
      avatarUrl: JsonParserHelper.parseString(
        json['avatarUrl'] ??
            json['photoUrl'] ??
            json['imageUrl'] ??
            json['avatar'] ??
            json['organizerAvatar'] ??
            profile?['avatarUrl'] ??
            profile?['photoUrl'],
      ),
      bio: JsonParserHelper.parseString(json['bio'] ?? profile?['bio']),
      username: JsonParserHelper.parseString(json['userName'] ?? profile?['userName']),
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
  final int? maxParticipants;
  final int? currentParticipants;
  final int favoriteCount;
  final bool isFavorite;
  final bool isRegistered;
  final bool isFree;
  final double? price;
  final List<String> tags;
  final List<String> waypoints;
  final bool? isRoundTrip;
  final double? distanceKm;
  final EventOrganizer? organizer;
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
    this.maxParticipants,
    this.currentParticipants,
    this.favoriteCount = 0,
    this.isFavorite = false,
    this.isRegistered = false,
    this.isFree = false,
    this.price,
    this.tags = const <String>[],
    this.waypoints = const <String>[],
    this.isRoundTrip,
    this.distanceKm,
    this.organizer,
    this.status,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    final locationJson = JsonParserHelper.asMap(json['location']) ?? JsonParserHelper.asMap(json['meetingPoint']);
    final mediaJson =
        JsonParserHelper.asMap(json['media']) ?? JsonParserHelper.asMap(json['images']) ?? JsonParserHelper.asMap(json['gallery']);
    final statsJson = JsonParserHelper.asMap(json['stats']) ??
        JsonParserHelper.asMap(json['statistics']) ??
        JsonParserHelper.asMap(json['enrollment']) ??
        JsonParserHelper.asMap(json['status']);
    final scheduleJson =
        JsonParserHelper.asMap(json['schedule']) ?? JsonParserHelper.asMap(json['time']) ?? JsonParserHelper.asMap(json['period']);
    final organizerJson =
        JsonParserHelper.asMap(json['organizer']) ?? JsonParserHelper.asMap(json['host']) ?? JsonParserHelper.asMap(json['creator']);

    String locationName = JsonParserHelper.parseString(
          locationJson?['name'] ??
              locationJson?['title'] ??
              json['location'] ??
              json['locationName'] ??
              locationJson?['address'],
        ) ??
        '';
    if (locationName.isEmpty) {
      locationName = '';
    }

    final latitude = JsonParserHelper.parseDouble(
          locationJson?['latitude'] ??
              locationJson?['lat'] ??
              json['latitude'] ??
              json['lat'],
        ) ??
        0;
    final longitude = JsonParserHelper.parseDouble(
          locationJson?['longitude'] ??
              locationJson?['lng'] ??
              locationJson?['lon'] ??
              json['longitude'] ??
              json['lng'] ??
              json['lon'],
        ) ??
        0;

    final parsedImageUrls = JsonParserHelper.parseStringList(
      mediaJson?['imageUrls'] ?? mediaJson?['images'] ?? json['imageUrls'] ?? json['images'],
    );
    final parsedVideoUrls = JsonParserHelper.parseStringList(
      mediaJson?['videoUrls'] ??
          mediaJson?['videos'] ??
          json['videoUrls'] ??
          json['videos'] ??
          mediaJson?['clips'],
    );
    final coverImageUrl = JsonParserHelper.parseString(
      mediaJson?['coverImageUrl'] ??
          mediaJson?['cover'] ??
          json['coverImageUrl'] ??
          json['coverUrl'],
    );

    final maxParticipants = JsonParserHelper.parseInt(
      statsJson?['maxParticipants'] ??
          statsJson?['capacity'] ??
          json['maxParticipants'] ??
          json['capacity'] ??
          json['maxPeople'],
    );
    final currentParticipants = JsonParserHelper.parseInt(
      statsJson?['currentParticipants'] ??
          statsJson?['attendeeCount'] ??
          statsJson?['current'] ??
          statsJson?['registeredCount'] ??
          json['currentParticipants'] ??
          json['attendeeCount'] ??
          json['currentPeople'],
    );

    final favoriteCount = JsonParserHelper.parseInt(
          statsJson?['likeCount'] ??
              statsJson?['likes'] ??
              statsJson?['favorites'] ??
              json['likeCount'] ??
              json['likes'] ??
              json['favoriteCount'],
        ) ??
        0;

    final isFavorite = JsonParserHelper.parseBool(
          statsJson?['isFavorite'] ??
              statsJson?['isUserFavorite'] ??
              json['isFavorite'] ??
              json['isUserFavorite'],
        ) ??
        false;
    final isRegistered = JsonParserHelper.parseBool(
          statsJson?['isRegistered'] ??
              statsJson?['isJoined'] ??
              statsJson?['isUserJoined'] ??
              json['isRegistered'] ??
              json['isJoined'] ??
              json['isUserJoined'],
        ) ??
        false;

    final price = JsonParserHelper.parseDouble(statsJson?['price'] ?? json['price']);
    final isFree = JsonParserHelper.parseBool(json['isFree'] ?? statsJson?['isFree']) ??
        (price == null || price == 0);

    final parsedTags =
        JsonParserHelper.parseStringList(json['tags'] ?? json['categories'] ?? json['labels']);
    final parsedWaypoints = JsonParserHelper.parseStringList(
      json['waypoints'] ??
          json['routePoints'] ??
          json['stops'] ??
          json['via'] ??
          json['viaPoints'] ??
          locationJson?['waypoints'] ??
          locationJson?['stops'],
    );
    final parsedRoundTrip = JsonParserHelper.parseBool(
      json['isRoundTrip'] ??
          json['roundTrip'] ??
          json['isLoop'] ??
          json['loop'] ??
          json['round'],
    );
    final parsedDistanceKm = JsonParserHelper.parseDouble(
      json['distanceKm'] ??
          json['distance_km'] ??
          json['distance'] ??
          json['lengthKm'] ??
          json['length_km'] ??
          json['length'] ??
          json['routeLength'],
    );
    final parsedStatus = _parseEventStatus(
      json['status'] ??
          statsJson?['status'] ??
          statsJson?['state'] ??
          statsJson?['phase'],
    );

    return Event(
      id: JsonParserHelper.parseString(json['id'] ?? json['eventId']) ?? '',
      title: JsonParserHelper.parseString(json['title'] ?? json['name']) ?? '',
      location: locationName,
      description: JsonParserHelper.parseString(json['description'] ?? json['details']) ?? '',
      latitude: latitude,
      longitude: longitude,
      imageUrls: List.unmodifiable(parsedImageUrls),
      videoUrls: List.unmodifiable(parsedVideoUrls),
      coverImageUrl: coverImageUrl,
      address: JsonParserHelper.parseString(locationJson?['address'] ?? json['address']),
      startTime: JsonParserHelper.parseDate(
        scheduleJson?['startTime'] ??
            scheduleJson?['start'] ??
            scheduleJson?['begin'] ??
            json['startTime'] ??
            json['startDate'],
      ),
      endTime: JsonParserHelper.parseDate(
        scheduleJson?['endTime'] ??
            scheduleJson?['end'] ??
            scheduleJson?['finish'] ??
            json['endTime'] ??
            json['endDate'],
      ),
      createdAt: JsonParserHelper.parseDate(json['createdAt'] ?? scheduleJson?['createdAt'] ?? json['createdOn']),
      updatedAt: JsonParserHelper.parseDate(json['updatedAt'] ?? scheduleJson?['updatedAt'] ?? json['updatedOn']),
      maxParticipants: maxParticipants,
      currentParticipants: currentParticipants,
      isFavorite: isFavorite,
      favoriteCount: favoriteCount,
      isRegistered: isRegistered,
      isFree: isFree,
      price: price,
      tags: List.unmodifiable(parsedTags),
      waypoints: List.unmodifiable(parsedWaypoints),
      isRoundTrip: parsedRoundTrip,
      distanceKm: parsedDistanceKm,
      organizer: organizerJson != null
          ? EventOrganizer.fromJson(organizerJson)
                        : (json['organizerId'] != null || json['organizerName'] != null)
              ? EventOrganizer(
                  id: JsonParserHelper.parseString(json['organizerId']) ?? '',
                  name: JsonParserHelper.parseString(json['organizerName']) ?? '',
                  avatarUrl: JsonParserHelper.parseString(json['organizerAvatar']),
                )
              : null,
      status: parsedStatus,
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
        'maxParticipants': maxParticipants,
        'currentParticipants': currentParticipants,
        'favoriteCount': favoriteCount,
        'isFavorite': isFavorite,
        'isRegistered': isRegistered,
        'isFree': isFree,
        'price': price,
        'tags': tags,
        if (waypoints.isNotEmpty) 'waypoints': waypoints,
        if (isRoundTrip != null) 'isRoundTrip': isRoundTrip,
        if (distanceKm != null) 'distanceKm': distanceKm,
        if (organizer != null) 'organizer': organizer!.toJson(),
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
      maxParticipants != null &&
      currentParticipants != null &&
      currentParticipants! >= maxParticipants!;

  String? get participantSummary {
    if (currentParticipants == null && maxParticipants == null) {
      return null;
    }
    final current = currentParticipants;
    final max = maxParticipants;
    if (current != null && max != null) {
      return '$current/$max';
    }
    return (current ?? max).toString();
  }
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
