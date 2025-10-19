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

  const EventOrganizer({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.bio,
  });
}

class Event {
  final String id;
  final String ownerId;
  final String title;
  final String location;
  final String? description;
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
  final int maxParticipants;
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
  final List<EventSegmentDto> segments;
  final List<MomentSummaryDto> moments;
  final String visibility;
  final String? routePolyline;
  final int registrations;
  final int likes;
  final double? engagement;

  const Event({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.location,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.imageUrls,
    required this.videoUrls,
    required this.coverImageUrl,
    required this.address,
    required this.startTime,
    required this.endTime,
    required this.createdAt,
    required this.updatedAt,
    required this.maxParticipants,
    required this.currentParticipants,
    required this.isFavorite,
    required this.isRegistered,
    required this.isFree,
    required this.price,
    required this.tags,
    required this.waypoints,
    required this.isRoundTrip,
    required this.distanceKm,
    required this.organizer,
    required this.segments,
    required this.moments,
    required this.visibility,
    required this.routePolyline,
    required this.registrations,
    required this.likes,
    required this.engagement,
  });

  factory Event.fromSummary(EventSummaryDto dto) {
    final center = dto.center;
    final longitude = _extractLongitude(center) ?? 0;
    final latitude = _extractLatitude(center) ?? 0;
    return Event(
      id: dto.id,
      ownerId: dto.ownerId,
      title: dto.title,
      location: _formatLocation(latitude, longitude),
      description: null,
      latitude: latitude,
      longitude: longitude,
      imageUrls: const <String>[],
      videoUrls: const <String>[],
      coverImageUrl: null,
      address: null,
      startTime: dto.startTime,
      endTime: null,
      createdAt: null,
      updatedAt: null,
      maxParticipants: dto.maxParticipants,
      currentParticipants: dto.memberCount,
      isFavorite: false,
      isRegistered: dto.isRegistered,
      isFree: true,
      price: null,
      tags: List.unmodifiable(dto.tags ?? const <String>[]),
      waypoints: const <String>[],
      isRoundTrip: null,
      distanceKm: null,
      organizer: null,
      segments: const <EventSegmentDto>[],
      moments: const <MomentSummaryDto>[],
      visibility: 'Public',
      routePolyline: null,
      registrations: dto.memberCount,
      likes: 0,
      engagement: null,
    );
  }

  factory Event.fromCard(EventCardDto dto) {
    final coords = dto.coordinates;
    final longitude = _extractLongitude(coords) ?? 0;
    final latitude = _extractLatitude(coords) ?? 0;
    return Event(
      id: dto.id,
      ownerId: dto.ownerId,
      title: dto.title,
      location: _formatLocation(latitude, longitude),
      description: dto.description,
      latitude: latitude,
      longitude: longitude,
      imageUrls: const <String>[],
      videoUrls: const <String>[],
      coverImageUrl: null,
      address: null,
      startTime: dto.startTime,
      endTime: null,
      createdAt: dto.createdAt,
      updatedAt: null,
      maxParticipants: dto.registrations > 0 ? dto.registrations : 1,
      currentParticipants: dto.registrations,
      isFavorite: false,
      isRegistered: false,
      isFree: true,
      price: null,
      tags: List.unmodifiable(dto.tags ?? const <String>[]),
      waypoints: const <String>[],
      isRoundTrip: null,
      distanceKm: dto.distanceKm,
      organizer: null,
      segments: const <EventSegmentDto>[],
      moments: const <MomentSummaryDto>[],
      visibility: 'Public',
      routePolyline: null,
      registrations: dto.registrations,
      likes: dto.likes,
      engagement: dto.engagement,
    );
  }

  Event copyWithDetail(EventDetailDto detail) {
    final start = detail.startPoint;
    final end = detail.endPoint;
    final longitude =
        _extractLongitude(start) ?? _extractLongitude(end) ?? this.longitude;
    final latitude =
        _extractLatitude(start) ?? _extractLatitude(end) ?? this.latitude;

    final momentImages = detail.moments
        .map((moment) => moment.coverImageUrl?.trim())
        .whereType<String>()
        .where((url) => url.isNotEmpty)
        .toList(growable: false);
    final cover = momentImages.isNotEmpty ? momentImages.first : coverImageUrl;

    return Event(
      id: detail.id,
      ownerId: detail.ownerId,
      title: detail.title,
      location: _formatLocation(latitude, longitude),
      description: detail.description ?? description,
      latitude: latitude,
      longitude: longitude,
      imageUrls: momentImages,
      videoUrls: const <String>[],
      coverImageUrl: cover,
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
      tags: detail.tags != null
          ? List.unmodifiable(detail.tags!)
          : tags,
      waypoints: waypoints,
      isRoundTrip: isRoundTrip,
      distanceKm: distanceKm,
      organizer: organizer ??
          EventOrganizer(
            id: detail.ownerId,
            name: '',
          ),
      segments: List.unmodifiable(detail.segments),
      moments: List.unmodifiable(detail.moments),
      visibility: detail.visibility,
      routePolyline: detail.routePolyline ?? routePolyline,
      registrations: detail.memberCount,
      likes: likes,
      engagement: engagement,
    );
  }

  String? get firstAvailableImageUrl {
    for (final url in [
      ...imageUrls,
      if (coverImageUrl != null) coverImageUrl!,
    ]) {
      final trimmed = url.trim();
      if (trimmed.isNotEmpty) {
        return trimmed;
      }
    }
    return null;
  }

  bool get isFull {
    final current = currentParticipants;
    if (current == null) {
      return false;
    }
    return current >= maxParticipants;
  }

  String? get participantSummary {
    final current = currentParticipants;
    if (current == null) {
      return maxParticipants > 0 ? maxParticipants.toString() : null;
    }
    return '$current/$maxParticipants';
  }
}

String _formatLocation(double latitude, double longitude) {
  return '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
}

double? _extractLatitude(List<double>? coords) {
  if (coords == null || coords.length < 2) {
    return null;
  }
  return coords[1];
}

double? _extractLongitude(List<double>? coords) {
  if (coords == null || coords.length < 2) {
    return null;
  }
  return coords[0];
}
