import 'package:crew_app/features/models/event/event_card_dto.dart';
import 'package:crew_app/features/models/event/event_detail_dto.dart';
import 'package:crew_app/features/models/event/event_segment_dto.dart';
import 'package:crew_app/features/models/event/event_summary_dto.dart';
import 'package:crew_app/features/models/event/moment_summary_dto.dart';

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
    final profile = _asMap(json['profile']);
    String? parseString(dynamic value) => value?.toString();
    return EventOrganizer(
      id: parseString(
            json['id'] ??
                json['userId'] ??
                json['organizerId'] ??
                profile?['id'],
          ) ??
          '',
      name: parseString(
            json['name'] ??
                json['displayName'] ??
                json['nickname'] ??
                json['userName'] ??
                json['organizerName'] ??
                profile?['name'],
          ) ??
          '',
      avatarUrl: parseString(
        json['avatarUrl'] ??
            json['photoUrl'] ??
            json['imageUrl'] ??
            json['avatar'] ??
            json['organizerAvatar'] ??
            profile?['avatarUrl'] ??
            profile?['photoUrl'],
      ),
      bio: parseString(json['bio'] ?? profile?['bio']),
      username: parseString(json['userName'] ?? profile?['userName']),
    );
  }

  factory Event.fromEventSummaryDto(EventSummaryDto dto) {
    final lat = _coordinateAt(dto.center, 1) ?? 0;
    final lng = _coordinateAt(dto.center, 0) ?? 0;
    return Event(
      id: dto.id,
      title: dto.title,
      location: _formatCoordinateLocation(lat, lng),
      description: '',
      latitude: lat,
      longitude: lng,
      imageUrls: const <String>[],
      startTime: dto.startTime,
      maxParticipants: dto.maxParticipants,
      currentParticipants: dto.memberCount,
      isRegistered: dto.isRegistered,
      isFavorite: false,
      isFree: true,
      tags: dto.tags ?? const <String>[],
      waypoints: const <String>[],
      memberCount: dto.memberCount,
    );
  }

  factory Event.fromEventCardDto(EventCardDto dto) {
    final lat = _coordinateAt(dto.coordinates, 1) ?? 0;
    final lng = _coordinateAt(dto.coordinates, 0) ?? 0;
    return Event(
      id: dto.id,
      title: dto.title,
      location: _formatCoordinateLocation(lat, lng),
      description: dto.description ?? '',
      latitude: lat,
      longitude: lng,
      imageUrls: const <String>[],
      startTime: dto.startTime,
      createdAt: dto.createdAt,
      currentParticipants: dto.registrations,
      isRegistered: false,
      isFavorite: false,
      isFree: true,
      tags: dto.tags ?? const <String>[],
      distanceKm: dto.distanceKm,
      memberCount: dto.registrations,
    );
  }

  factory Event.fromEventDetailDto(EventDetailDto dto) {
    final startLat = _coordinateAt(dto.startPoint, 1) ?? 0;
    final startLng = _coordinateAt(dto.startPoint, 0) ?? 0;
    final waypointStrings = dto.segments
        .map((segment) => _formatCoordinateLocation(
              _coordinateAt(segment.waypoint, 1) ?? startLat,
              _coordinateAt(segment.waypoint, 0) ?? startLng,
            ))
        .toList(growable: false);
    final coverImages = dto.moments
        .map((moment) => moment.coverImageUrl)
        .whereType<String>()
        .map((url) => url.trim())
        .where((url) => url.isNotEmpty)
        .toList(growable: false);

    return Event(
      id: dto.id,
      title: dto.title,
      description: dto.description ?? '',
      location: _formatCoordinateLocation(startLat, startLng),
      latitude: startLat,
      longitude: startLng,
      imageUrls: List.unmodifiable(coverImages),
      coverImageUrl: coverImages.isNotEmpty ? coverImages.first : null,
      startTime: dto.startTime,
      endTime: dto.endTime,
      maxParticipants: dto.maxParticipants,
      currentParticipants: dto.memberCount,
      isRegistered: dto.isRegistered,
      isFavorite: false,
      isFree: true,
      tags: dto.tags ?? const <String>[],
      waypoints: List.unmodifiable(waypointStrings),
      visibility: dto.visibility,
      memberCount: dto.memberCount,
      segments: List.unmodifiable(dto.segments),
      moments: List.unmodifiable(dto.moments),
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
  final bool isFavorite;
  final bool isRegistered;
  final bool isFree;
  final double? price;
  final List<String> tags;
  final List<String> waypoints;
  final bool? isRoundTrip;
  final double? distanceKm;
  final EventOrganizer? organizer;
  final String? visibility;
  final int? memberCount;
  final List<EventSegmentDto>? segments;
  final List<MomentSummaryDto>? moments;

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
    this.isFavorite = false,
    this.isRegistered = false,
    this.isFree = false,
    this.price,
    this.tags = const <String>[],
    this.waypoints = const <String>[],
    this.isRoundTrip,
    this.distanceKm,
    this.organizer,
    this.visibility,
    this.memberCount,
    this.segments,
    this.moments,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    final locationJson = _asMap(json['location']) ?? _asMap(json['meetingPoint']);
    final mediaJson =
        _asMap(json['media']) ?? _asMap(json['images']) ?? _asMap(json['gallery']);
    final statsJson = _asMap(json['stats']) ??
        _asMap(json['statistics']) ??
        _asMap(json['enrollment']) ??
        _asMap(json['status']);
    final scheduleJson =
        _asMap(json['schedule']) ?? _asMap(json['time']) ?? _asMap(json['period']);
    final organizerJson =
        _asMap(json['organizer']) ?? _asMap(json['host']) ?? _asMap(json['creator']);

    String? parseString(dynamic value) => value?.toString();
    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString());
    }

    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value.toString());
    }

    bool? parseBool(dynamic value) {
      if (value == null) return null;
      if (value is bool) return value;
      if (value is num) return value != 0;
      final lower = value.toString().toLowerCase();
      if (lower == 'true' || lower == 'yes' || lower == '1') {
        return true;
      }
      if (lower == 'false' || lower == 'no' || lower == '0') {
        return false;
      }
      return null;
    }

    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      return DateTime.tryParse(value.toString());
    }

    List<String> parseStringList(dynamic value) {
      Iterable<dynamic>? list;
      if (value is Iterable<dynamic>) {
        list = value;
      } else if (value != null) {
        list = const [];
      }
      if (list == null) return const <String>[];
      return list
          .map((item) => item?.toString())
          .where((item) => item != null)
          .map((item) => item!.trim())
          .where((item) => item.isNotEmpty)
          .toList(growable: false);
    }

    String locationName = parseString(
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

    final latitude = parseDouble(
          locationJson?['latitude'] ??
              locationJson?['lat'] ??
              json['latitude'] ??
              json['lat'],
        ) ??
        0;
    final longitude = parseDouble(
          locationJson?['longitude'] ??
              locationJson?['lng'] ??
              locationJson?['lon'] ??
              json['longitude'] ??
              json['lng'] ??
              json['lon'],
        ) ??
        0;

    final parsedImageUrls = parseStringList(
      mediaJson?['imageUrls'] ?? mediaJson?['images'] ?? json['imageUrls'] ?? json['images'],
    );
    final parsedVideoUrls = parseStringList(
      mediaJson?['videoUrls'] ??
          mediaJson?['videos'] ??
          json['videoUrls'] ??
          json['videos'] ??
          mediaJson?['clips'],
    );
    final coverImageUrl = parseString(
      mediaJson?['coverImageUrl'] ??
          mediaJson?['cover'] ??
          json['coverImageUrl'] ??
          json['coverUrl'],
    );

    final maxParticipants = parseInt(
      statsJson?['maxParticipants'] ??
          statsJson?['capacity'] ??
          json['maxParticipants'] ??
          json['capacity'] ??
          json['maxPeople'],
    );
    final currentParticipants = parseInt(
      statsJson?['currentParticipants'] ??
          statsJson?['attendeeCount'] ??
          statsJson?['current'] ??
          statsJson?['registeredCount'] ??
          json['currentParticipants'] ??
          json['attendeeCount'] ??
          json['currentPeople'],
    );

    final isFavorite = parseBool(
          statsJson?['isFavorite'] ??
              statsJson?['isUserFavorite'] ??
              json['isFavorite'] ??
              json['isUserFavorite'],
        ) ??
        false;
    final isRegistered = parseBool(
          statsJson?['isRegistered'] ??
              statsJson?['isJoined'] ??
              statsJson?['isUserJoined'] ??
              json['isRegistered'] ??
              json['isJoined'] ??
              json['isUserJoined'],
        ) ??
        false;

    final price = parseDouble(statsJson?['price'] ?? json['price']);
    final isFree = parseBool(json['isFree'] ?? statsJson?['isFree']) ??
        (price == null || price == 0);

    final parsedTags =
        parseStringList(json['tags'] ?? json['categories'] ?? json['labels']);
    final parsedWaypoints = parseStringList(
      json['waypoints'] ??
          json['routePoints'] ??
          json['stops'] ??
          json['via'] ??
          json['viaPoints'] ??
          locationJson?['waypoints'] ??
          locationJson?['stops'],
    );
    final parsedRoundTrip = parseBool(
      json['isRoundTrip'] ??
          json['roundTrip'] ??
          json['isLoop'] ??
          json['loop'] ??
          json['round'],
    );
    final parsedDistanceKm = parseDouble(
      json['distanceKm'] ??
          json['distance_km'] ??
          json['distance'] ??
          json['lengthKm'] ??
          json['length_km'] ??
          json['length'] ??
          json['routeLength'],
    );

    final parsedSegments = (json['segments'] as List?)
        ?.map((item) => item is Map<String, dynamic>
            ? EventSegmentDto.fromJson(Map<String, dynamic>.from(item))
            : null)
        .whereType<EventSegmentDto>()
        .toList(growable: false);

    final parsedMoments = (json['moments'] as List?)
        ?.map((item) => item is Map<String, dynamic>
            ? MomentSummaryDto.fromJson(Map<String, dynamic>.from(item))
            : null)
        .whereType<MomentSummaryDto>()
        .toList(growable: false);

    return Event(
      id: parseString(json['id'] ?? json['eventId']) ?? '',
      title: parseString(json['title'] ?? json['name']) ?? '',
      location: locationName,
      description: parseString(json['description'] ?? json['details']) ?? '',
      latitude: latitude,
      longitude: longitude,
      imageUrls: List.unmodifiable(parsedImageUrls),
      videoUrls: List.unmodifiable(parsedVideoUrls),
      coverImageUrl: coverImageUrl,
      address: parseString(locationJson?['address'] ?? json['address']),
      startTime: parseDate(
        scheduleJson?['startTime'] ??
            scheduleJson?['start'] ??
            scheduleJson?['begin'] ??
            json['startTime'] ??
            json['startDate'],
      ),
      endTime: parseDate(
        scheduleJson?['endTime'] ??
            scheduleJson?['end'] ??
            scheduleJson?['finish'] ??
            json['endTime'] ??
            json['endDate'],
      ),
      createdAt: parseDate(json['createdAt'] ?? scheduleJson?['createdAt'] ?? json['createdOn']),
      updatedAt: parseDate(json['updatedAt'] ?? scheduleJson?['updatedAt'] ?? json['updatedOn']),
      maxParticipants: maxParticipants,
      currentParticipants: currentParticipants,
      isFavorite: isFavorite,
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
                  id: parseString(json['organizerId']) ?? '',
                  name: parseString(json['organizerName']) ?? '',
                  avatarUrl: parseString(json['organizerAvatar']),
                )
              : null,
      visibility: parseString(json['visibility'] ?? statsJson?['visibility']),
      memberCount: currentParticipants,
      segments: (parsedSegments == null || parsedSegments.isEmpty)
          ? null
          : List.unmodifiable(parsedSegments),
      moments: (parsedMoments == null || parsedMoments.isEmpty)
          ? null
          : List.unmodifiable(parsedMoments),
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
        'isFavorite': isFavorite,
        'isRegistered': isRegistered,
        'isFree': isFree,
        'price': price,
        'tags': tags,
        if (waypoints.isNotEmpty) 'waypoints': waypoints,
        if (isRoundTrip != null) 'isRoundTrip': isRoundTrip,
        if (distanceKm != null) 'distanceKm': distanceKm,
        if (organizer != null) 'organizer': organizer!.toJson(),
        if (visibility != null) 'visibility': visibility,
        if (memberCount != null) 'memberCount': memberCount,
        if (segments != null)
          'segments': segments!.map((e) => e.toJson()).toList(),
        if (moments != null)
          'moments': moments!.map((e) => e.toJson()).toList(),
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

double? _coordinateAt(List<double>? coordinates, int index) {
  if (coordinates == null || coordinates.length <= index) {
    return null;
  }
  return coordinates[index];
}

String _formatCoordinateLocation(double? lat, double? lng) {
  final safeLat = lat ?? 0;
  final safeLng = lng ?? 0;
  return 'Lat ${safeLat.toStringAsFixed(4)}, Lng ${safeLng.toStringAsFixed(4)}';
}

Map<String, dynamic>? _asMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  return null;
}
