import 'package:crew_app/features/events/data/event.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Event.fromJson', () {
    test('parses standard Crew.Api DTO structure', () {
      final json = {
        'id': 'event-123',
        'title': 'Sunrise Run',
        'description': 'Start the day with an energising 5km run.',
        'location': 'Central Park',
        'address': 'East Meadow, NY',
        'latitude': 40.785091,
        'longitude': -73.968285,
        'startTime': '2024-06-01T05:45:00Z',
        'endTime': '2024-06-01T07:00:00Z',
        'coverImageUrl': 'https://example.com/cover.jpg',
        'imageUrls': [
          'https://example.com/photo-1.jpg',
          'https://example.com/photo-2.jpg',
        ],
        'videoUrls': [],
        'maxParticipants': 20,
        'currentParticipants': 12,
        'isFavorite': true,
        'isRegistered': false,
        'favoriteCount': 342,
        'isFree': true,
        'host': {
          'id': 'user-42',
          'name': 'Alice',
          'avatarUrl': 'https://example.com/avatar.png',
          'bio': 'Outdoor enthusiast & community runner.',
        },
        'tags': ['Running', 'Outdoor'],
        'waypoints': [],
        'createdAt': '2024-05-01T12:00:00Z',
        'updatedAt': '2024-05-10T12:00:00Z',
        'status': 'recruiting',
      };

      final event = Event.fromJson(json);

      expect(event.id, 'event-123');
      expect(event.title, 'Sunrise Run');
      expect(event.location, 'Central Park');
      expect(event.description, contains('energising'));
      expect(event.latitude, closeTo(40.785091, 1e-6));
      expect(event.longitude, closeTo(-73.968285, 1e-6));
      expect(event.imageUrls, hasLength(2));
      expect(event.coverImageUrl, 'https://example.com/cover.jpg');
      expect(event.maxMembers, 20);
      expect(event.currentMembers, 12);
      expect(event.isFavorite, isTrue);
      expect(event.isRegistered, isFalse);
      expect(event.favoriteCount, 342);
      expect(event.host?.name, 'Alice');
      expect(event.host?.avatarUrl, 'https://example.com/avatar.png');
      expect(event.host?.bio, contains('Outdoor enthusiast'));
      expect(event.startTime, DateTime.parse('2024-06-01T05:45:00Z'));
      expect(event.endTime, DateTime.parse('2024-06-01T07:00:00Z'));
      expect(event.createdAt, DateTime.parse('2024-05-01T12:00:00Z'));
      expect(event.updatedAt, DateTime.parse('2024-05-10T12:00:00Z'));
      expect(event.tags, containsAll(['Running', 'Outdoor']));
      expect(event.firstAvailableImageUrl, 'https://example.com/photo-1.jpg');
      expect(event.memberSummary, '12/20');
    });

    test('parses standard structure without optional fields', () {
      final json = {
        'id': '7',
        'title': 'Coffee Chat',
        'description': 'Meet other founders for a casual chat.',
        'location': 'Brew Lab',
        'latitude': 48.8566,
        'longitude': 2.3522,
        'imageUrls': ['https://example.com/coffee.png'],
        'videoUrls': [],
        'startTime': '2024-07-20T09:00:00Z',
        'endTime': '2024-07-20T11:00:00Z',
        'maxParticipants': 15,
        'currentParticipants': 15,
        'isFavorite': false,
        'isRegistered': true,
        'favoriteCount': 28,
        'isFree': true,
        'tags': [],
        'waypoints': [],
      };

      final event = Event.fromJson(json);

      expect(event.id, '7');
      expect(event.host, isNull); // 没有 host 字段时应该为 null
      expect(event.isRegistered, isTrue);
      expect(event.isFull, isTrue);
      expect(event.favoriteCount, 28);
      expect(event.firstAvailableImageUrl, 'https://example.com/coffee.png');
    });
  });

  group('Event.toJson', () {
    test('serializes key fields', () {
      final event = Event(
        id: 'abc',
        title: 'Board Games Night',
        description: 'Bring your favourite games and snacks.',
        location: 'Community Hub',
        latitude: 10,
        longitude: 20,
        imageUrls: const ['https://example.com/game.png'],
        coverImageUrl: 'https://example.com/cover.png',
        startTime: DateTime.parse('2024-08-03T18:30:00Z'),
        endTime: DateTime.parse('2024-08-03T22:30:00Z'),
        maxMembers: 24,
        currentMembers: 10,
        isFavorite: true,
        isRegistered: false,
        favoriteCount: 512,
        price: 12.5,
        tags: const ['Games', 'Social'],
        host: const EventHost(
          id: 'user-7',
          name: 'Ben',
          avatarUrl: 'https://example.com/avatar.jpg',
        ),
      );

      final json = event.toJson();

      expect(json['id'], 'abc');
      expect(json['title'], 'Board Games Night');
      expect(json['location'], 'Community Hub');
      expect(json['imageUrls'], ['https://example.com/game.png']);
      expect(json['coverImageUrl'], 'https://example.com/cover.png');
      expect(json['startTime'], '2024-08-03T18:30:00.000Z');
      expect(json['maxParticipants'], 24);
      expect(json['currentParticipants'], 10);
      expect(json['favoriteCount'], 512);
      expect(json['isFavorite'], true);
      expect(json['tags'], ['Games', 'Social']);
      expect(json['host'], {
        'id': 'user-7',
        'name': 'Ben',
        'avatarUrl': 'https://example.com/avatar.jpg',
      });
    });
  });
}
