import 'package:crew_app/features/events/data/event.dart';

class EventLocationDto {
  EventLocationDto({
    required this.latitude,
    required this.longitude,
    this.name,
    this.address,
    this.city,
    this.country,
  });

  final double latitude;
  final double longitude;
  final String? name;
  final String? address;
  final String? city;
  final String? country;

  factory EventLocationDto.fromJson(Map<String, dynamic> json) {
    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString());
    }

    String? parseString(dynamic value) => value?.toString();

    final center = _asMap(json['center']) ??
        _asMap(json['point']) ??
        _asMap(json['location']) ??
        _asMap(json['coordinates']);

    final latitude = parseDouble(center?['latitude'] ?? center?['lat'] ?? json['latitude'] ?? json['lat']) ?? 0;
    final longitude =
        parseDouble(center?['longitude'] ?? center?['lng'] ?? center?['lon'] ?? json['longitude'] ?? json['lng']) ?? 0;

    return EventLocationDto(
      latitude: latitude,
      longitude: longitude,
      name: parseString(json['name'] ?? json['title'] ?? json['locationName'] ?? center?['name']),
      address: parseString(json['address'] ?? json['fullAddress'] ?? center?['address']),
      city: parseString(json['city'] ?? json['region']),
      country: parseString(json['country']),
    );
  }
}

class EventScheduleDto {
  EventScheduleDto({
    this.startTime,
    this.endTime,
    this.timezone,
  });

  final DateTime? startTime;
  final DateTime? endTime;
  final String? timezone;

  factory EventScheduleDto.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      return DateTime.tryParse(value.toString());
    }

    return EventScheduleDto(
      startTime: parseDate(json['startTime'] ?? json['start'] ?? json['begin']),
      endTime: parseDate(json['endTime'] ?? json['end'] ?? json['finish']),
      timezone: json['timezone']?.toString(),
    );
  }
}

class EventMediaDto {
  EventMediaDto({
    this.coverImageUrl,
    this.imageUrls = const <String>[],
    this.videoUrls = const <String>[],
  });

  final String? coverImageUrl;
  final List<String> imageUrls;
  final List<String> videoUrls;

  factory EventMediaDto.fromJson(Map<String, dynamic> json) {
    List<String> parseStringList(dynamic value) {
      if (value is Iterable) {
        return value
            .map((item) => item?.toString())
            .whereType<String>()
            .map((item) => item.trim())
            .where((item) => item.isNotEmpty)
            .toList(growable: false);
      }
      return const <String>[];
    }

    String? parseString(dynamic value) => value?.toString();

    final gallery = _asMap(json['gallery']);

    return EventMediaDto(
      coverImageUrl: parseString(
        json['coverImageUrl'] ?? json['cover'] ?? gallery?['cover'] ?? gallery?['coverImageUrl'],
      ),
      imageUrls: parseStringList(
        json['imageUrls'] ?? json['images'] ?? gallery?['images'] ?? gallery?['imageUrls'],
      ),
      videoUrls: parseStringList(
        json['videoUrls'] ?? json['videos'] ?? gallery?['videos'] ?? gallery?['videoUrls'],
      ),
    );
  }
}

class EventStatsDto {
  EventStatsDto({
    this.maxParticipants,
    this.registeredCount,
    this.price,
    this.isFree,
    this.isRegistered,
    this.isFavorite,
  });

  final int? maxParticipants;
  final int? registeredCount;
  final double? price;
  final bool? isFree;
  final bool? isRegistered;
  final bool? isFavorite;

  factory EventStatsDto.fromJson(Map<String, dynamic> json) {
    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value.toString());
    }

    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString());
    }

    bool? parseBool(dynamic value) {
      if (value == null) return null;
      if (value is bool) return value;
      if (value is num) return value != 0;
      final lower = value.toString().toLowerCase();
      if (lower == 'true' || lower == '1' || lower == 'yes') return true;
      if (lower == 'false' || lower == '0' || lower == 'no') return false;
      return null;
    }

    return EventStatsDto(
      maxParticipants: parseInt(json['maxParticipants'] ?? json['capacity'] ?? json['maxPeople']),
      registeredCount: parseInt(
        json['registeredCount'] ?? json['attendeeCount'] ?? json['currentParticipants'],
      ),
      price: parseDouble(json['price'] ?? json['cost']),
      isFree: parseBool(json['isFree']),
      isRegistered: parseBool(json['isRegistered'] ?? json['hasRegistered'] ?? json['isJoined']),
      isFavorite: parseBool(json['isFavorite'] ?? json['hasBookmarked']),
    );
  }
}

class EventHostDto {
  EventHostDto({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.bio,
  });

  final String id;
  final String name;
  final String? avatarUrl;
  final String? bio;

  factory EventHostDto.fromJson(Map<String, dynamic> json) {
    String? parseString(dynamic value) => value?.toString();

    return EventHostDto(
      id: parseString(json['id'] ?? json['userId'] ?? json['organizerId']) ?? '',
      name: parseString(json['name'] ?? json['displayName'] ?? json['nickname']) ?? '',
      avatarUrl: parseString(json['avatarUrl'] ?? json['photoUrl']),
      bio: parseString(json['bio']),
    );
  }
}

class EventSummaryDto {
  EventSummaryDto({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    this.schedule,
    this.media,
    this.stats,
    this.tags = const <String>[],
    this.host,
  });

  final String id;
  final String title;
  final String description;
  final EventLocationDto location;
  final EventScheduleDto? schedule;
  final EventMediaDto? media;
  final EventStatsDto? stats;
  final List<String> tags;
  final EventHostDto? host;

  factory EventSummaryDto.fromJson(Map<String, dynamic> json) {
    List<String> parseTags(dynamic value) {
      if (value is Iterable) {
        return value
            .map((item) => item?.toString())
            .whereType<String>()
            .map((item) => item.trim())
            .where((item) => item.isNotEmpty)
            .toList(growable: false);
      }
      return const <String>[];
    }

    final locationJson = _asMap(json['location']) ??
        _asMap(json['meetingPoint']) ??
        _asMap(json['place']) ??
        <String, dynamic>{};

    final scheduleJson = _asMap(json['schedule']) ??
        _asMap(json['time']) ??
        _asMap(json['period']) ??
        <String, dynamic>{};

    final mediaJson = _asMap(json['media']) ?? _asMap(json['gallery']) ?? <String, dynamic>{};
    final statsJson = _asMap(json['stats']) ??
        _asMap(json['statistics']) ??
        _asMap(json['enrollment']) ??
        _asMap(json['status']) ??
        <String, dynamic>{};
    final hostJson = _asMap(json['host']) ?? _asMap(json['organizer']) ?? <String, dynamic>{};

    String? parseString(dynamic value) => value?.toString();

    return EventSummaryDto(
      id: parseString(json['id'] ?? json['eventId'] ?? json['guid']) ?? '',
      title: parseString(json['title'] ?? json['name']) ?? '',
      description: parseString(json['description'] ?? json['details']) ?? '',
      location: EventLocationDto.fromJson(locationJson),
      schedule: scheduleJson.isNotEmpty ? EventScheduleDto.fromJson(scheduleJson) : null,
      media: mediaJson.isNotEmpty ? EventMediaDto.fromJson(mediaJson) : null,
      stats: statsJson.isNotEmpty ? EventStatsDto.fromJson(statsJson) : null,
      tags: parseTags(json['tags'] ?? json['labels'] ?? json['categories']),
      host: hostJson.isNotEmpty ? EventHostDto.fromJson(hostJson) : null,
    );
  }

  Event toEvent() {
    final stats = this.stats;
    final media = this.media;
    final schedule = this.schedule;
    final price = stats?.price;
    final isFree = stats?.isFree ?? (price == null || price == 0);

    return Event(
      id: id,
      title: title,
      location: location.name ?? location.address ?? '',
      description: description,
      latitude: location.latitude,
      longitude: location.longitude,
      imageUrls: media?.imageUrls ?? const <String>[],
      videoUrls: media?.videoUrls ?? const <String>[],
      coverImageUrl: media?.coverImageUrl,
      address: location.address,
      startTime: schedule?.startTime,
      endTime: schedule?.endTime,
      maxParticipants: stats?.maxParticipants,
      currentParticipants: stats?.registeredCount,
      isFavorite: stats?.isFavorite ?? false,
      isRegistered: stats?.isRegistered ?? false,
      isFree: isFree,
      price: price,
      tags: tags,
      organizer: host != null
          ? EventOrganizer(
              id: host!.id,
              name: host!.name,
              avatarUrl: host!.avatarUrl,
              bio: host!.bio,
            )
          : null,
    );
  }
}

Map<String, dynamic>? _asMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return Map<String, dynamic>.from(value.cast<dynamic, dynamic>());
  }
  return null;
}
