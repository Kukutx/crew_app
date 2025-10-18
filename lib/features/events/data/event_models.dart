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
  final List<EventSegmentDto> segments;
  final List<MomentSummaryDto> moments;

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
    this.segments = const <EventSegmentDto>[],
    this.moments = const <MomentSummaryDto>[],
  });

  factory Event.fromFeedCard(EventCardDto dto) {
    final lat = _coordinateAt(dto.coordinates, 1) ?? 0;
    final lng = _coordinateAt(dto.coordinates, 0) ?? 0;
    return Event(
      id: dto.id,
      title: dto.title,
      description: dto.description ?? '',
      location: _formatCoordinateLocation(lat, lng),
      latitude: lat,
      longitude: lng,
      imageUrls: const <String>[],
      startTime: dto.startTime,
      createdAt: dto.createdAt,
      currentParticipants: dto.registrations,
      tags: dto.tags ?? const <String>[],
      distanceKm: dto.distanceKm,
      memberCount: dto.registrations,
    );
  }

  factory Event.fromSummary(EventSummaryDto dto) {
    final lat = _coordinateAt(dto.center, 1) ?? 0;
    final lng = _coordinateAt(dto.center, 0) ?? 0;
    return Event(
      id: dto.id,
      title: dto.title,
      description: '',
      location: _formatCoordinateLocation(lat, lng),
      latitude: lat,
      longitude: lng,
      imageUrls: const <String>[],
      startTime: dto.startTime,
      maxParticipants: dto.maxParticipants,
      currentParticipants: dto.memberCount,
      isRegistered: dto.isRegistered,
      tags: dto.tags ?? const <String>[],
      memberCount: dto.memberCount,
    );
  }

  factory Event.fromDetail(EventDetailDto dto) {
    final lat = _coordinateAt(dto.startPoint, 1) ?? 0;
    final lng = _coordinateAt(dto.startPoint, 0) ?? 0;
    final waypoints = dto.segments
        .map((segment) => _formatCoordinateLocation(
              _coordinateAt(segment.waypoint, 1) ?? lat,
              _coordinateAt(segment.waypoint, 0) ?? lng,
            ))
        .toList(growable: false);
    final images = dto.moments
        .map((moment) => moment.coverImageUrl)
        .whereType<String>()
        .map((url) => url.trim())
        .where((url) => url.isNotEmpty)
        .toList(growable: false);

    return Event(
      id: dto.id,
      title: dto.title,
      description: dto.description ?? '',
      location: _formatCoordinateLocation(lat, lng),
      latitude: lat,
      longitude: lng,
      imageUrls: List.unmodifiable(images),
      coverImageUrl: images.isNotEmpty ? images.first : null,
      startTime: dto.startTime,
      endTime: dto.endTime,
      maxParticipants: dto.maxParticipants,
      currentParticipants: dto.memberCount,
      isRegistered: dto.isRegistered,
      tags: dto.tags ?? const <String>[],
      waypoints: List.unmodifiable(waypoints),
      visibility: dto.visibility,
      memberCount: dto.memberCount,
      segments: List.unmodifiable(dto.segments),
      moments: List.unmodifiable(dto.moments),
    );
  }

  Event mergeDetail(EventDetailDto detail) {
    final lat = _coordinateAt(detail.startPoint, 1) ?? latitude;
    final lng = _coordinateAt(detail.startPoint, 0) ?? longitude;
    final detailWaypoints = detail.segments
        .map((segment) => _formatCoordinateLocation(
              _coordinateAt(segment.waypoint, 1) ?? lat,
              _coordinateAt(segment.waypoint, 0) ?? lng,
            ))
        .toList(growable: false);
    final images = detail.moments
        .map((moment) => moment.coverImageUrl)
        .whereType<String>()
        .map((url) => url.trim())
        .where((url) => url.isNotEmpty)
        .toList(growable: false);

    return Event(
      id: detail.id,
      title: detail.title,
      description: detail.description ?? description,
      location: _formatCoordinateLocation(lat, lng),
      latitude: lat,
      longitude: lng,
      imageUrls: images.isNotEmpty ? List.unmodifiable(images) : imageUrls,
      videoUrls: videoUrls,
      coverImageUrl:
          images.isNotEmpty ? images.first : coverImageUrl,
      address: address,
      startTime: detail.startTime ?? startTime,
      endTime: detail.endTime ?? endTime,
      createdAt: createdAt,
      updatedAt: updatedAt,
      maxParticipants: detail.maxParticipants,
      currentParticipants: detail.memberCount,
      isFavorite: isFavorite,
      isRegistered: detail.isRegistered,
      isFree: isFree,
      price: price,
      tags: detail.tags ?? tags,
      waypoints: detailWaypoints.isNotEmpty
          ? List.unmodifiable(detailWaypoints)
          : waypoints,
      isRoundTrip: isRoundTrip,
      distanceKm: distanceKm,
      organizer: organizer,
      visibility: detail.visibility,
      memberCount: detail.memberCount,
      segments: List.unmodifiable(detail.segments),
      moments: List.unmodifiable(detail.moments),
    );
  }

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
