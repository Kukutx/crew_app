import 'package:crew_app/features/events/data/event_models.dart';
import 'package:crew_app/features/models/event/event_card_dto.dart';
import 'package:crew_app/features/models/event/event_detail_dto.dart';
import 'package:crew_app/features/models/event/event_segment_dto.dart';
import 'package:crew_app/features/models/event/event_summary_dto.dart';
import 'package:crew_app/features/models/event/moment_summary_dto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Event.fromFeedCard maps coordinates and metadata', () {
    final card = EventCardDto(
      id: 'event-1',
      ownerId: 'owner-7',
      title: 'Crew Morning Ride',
      description: 'Explore the riverside trail together.',
      startTime: DateTime.parse('2024-06-01T05:30:00Z'),
      createdAt: DateTime.parse('2024-05-25T09:00:00Z'),
      coordinates: const [121.5654, 25.0330],
      distanceKm: 4.2,
      registrations: 18,
      likes: 12,
      engagement: 0.87,
      tags: const ['cycling', 'outdoor'],
    );

    final event = Event.fromFeedCard(card);

    expect(event.id, 'event-1');
    expect(event.ownerId, 'owner-7');
    expect(event.title, 'Crew Morning Ride');
    expect(event.latitude, closeTo(25.0330, 1e-6));
    expect(event.longitude, closeTo(121.5654, 1e-6));
    expect(event.distanceKm, 4.2);
    expect(event.memberCount, 18);
    expect(event.tags, ['cycling', 'outdoor']);
    expect(event.location, contains('Lat 25.0330'));
  });

  test('Event.fromSummary converts center coordinates', () {
    final summary = EventSummaryDto(
      id: 'event-2',
      ownerId: 'owner-1',
      title: 'Downtown Coffee Walk',
      startTime: DateTime.parse('2024-07-02T01:00:00Z'),
      center: const [120.9842, 23.9739],
      memberCount: 9,
      maxParticipants: 12,
      isRegistered: true,
      tags: const ['coffee'],
    );

    final event = Event.fromSummary(summary);

    expect(event.id, 'event-2');
    expect(event.ownerId, 'owner-1');
    expect(event.maxParticipants, 12);
    expect(event.currentParticipants, 9);
    expect(event.isRegistered, isTrue);
    expect(event.participantSummary, '9/12');
  });

  test('Event.mergeDetail enriches feed data', () {
    final base = Event.fromFeedCard(
      EventCardDto(
        id: 'event-3',
        ownerId: 'owner-9',
        title: 'Weekend Hike',
        description: 'A relaxed trail suitable for all levels.',
        startTime: DateTime.parse('2024-07-10T00:00:00Z'),
        createdAt: DateTime.parse('2024-06-20T11:00:00Z'),
        coordinates: const [120.0, 24.0],
        registrations: 6,
        likes: 2,
      ),
    );

    final detail = EventDetailDto(
      id: 'event-3',
      ownerId: 'owner-9',
      title: 'Weekend Hike',
      description: 'A relaxed trail suitable for all levels.',
      startTime: DateTime.parse('2024-07-10T00:00:00Z'),
      endTime: DateTime.parse('2024-07-10T05:00:00Z'),
      startPoint: const [120.0005, 24.0005],
      endPoint: const [120.0500, 24.0200],
      routePolyline: null,
      maxParticipants: 20,
      visibility: 'Public',
      segments: const [
        EventSegmentDto(seq: 1, waypoint: [120.0, 24.0], note: 'Meet up'),
        EventSegmentDto(seq: 2, waypoint: [120.02, 24.01], note: 'Scenic spot'),
      ],
      memberCount: 6,
      isRegistered: true,
      tags: const ['hiking', 'nature'],
      moments: const [
        MomentSummaryDto(
          id: 'moment-1',
          userId: 'user-1',
          userDisplayName: 'Ivy',
          title: 'Sunrise view',
          coverImageUrl: 'https://example.com/sunrise.jpg',
          country: 'TW',
          city: 'Taipei',
          createdAt: '2024-06-22T09:00:00Z',
        ),
      ],
    );

    final enriched = base.mergeDetail(detail);

    expect(enriched.isRegistered, isTrue);
    expect(enriched.ownerId, 'owner-9');
    expect(enriched.maxParticipants, 20);
    expect(enriched.moments, hasLength(1));
    expect(enriched.segments, hasLength(2));
    expect(enriched.waypoints, contains('Lat 24.0000'));
    expect(enriched.firstAvailableImageUrl,
        'https://example.com/sunrise.jpg');
  });
}
