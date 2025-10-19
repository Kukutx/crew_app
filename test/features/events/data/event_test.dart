import 'package:crew_app/features/events/data/event.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Event.fromJson', () {
    test('parses nested Crew.Api DTO structure', () {
      final json = {
        'id': 'event-123',
        'title': 'Sunrise Run',
        'description': 'Start the day with an energising 5km run.',
        'schedule': {
          'startTime': '2024-06-01T05:45:00Z',
          'endTime': '2024-06-01T07:00:00Z',
        },
        'location': {
          'name': 'Central Park',
          'address': 'East Meadow, NY',
          'latitude': 40.785091,
          'longitude': -73.968285,
        },
        'media': {
          'coverImageUrl': 'https://example.com/cover.jpg',
          'imageUrls': [
            'https://example.com/photo-1.jpg',
            'https://example.com/photo-2.jpg',
          ],
        },
        'stats': {
          'maxParticipants': 20,
          'currentParticipants': 12,
          'isUserFavorite': true,
          'isUserJoined': false,
          'likeCount': 342,
        },
        'organizer': {
          'id': 'user-42',
          'name': 'Alice',
          'profile': {
            'bio': 'Outdoor enthusiast & community runner.',
            'photoUrl': 'https://example.com/avatar.png',
          },
        },
        'tags': ['Running', 'Outdoor'],
        'createdAt': '2024-05-01T12:00:00Z',
        'updatedAt': '2024-05-10T12:00:00Z',
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
      expect(event.maxParticipants, 20);
      expect(event.currentParticipants, 12);
      expect(event.isFavorite, isTrue);
      expect(event.isRegistered, isFalse);
      expect(event.likes, 342);
      expect(event.organizer?.name, 'Alice');
      expect(event.organizer?.avatarUrl, 'https://example.com/avatar.png');
      expect(event.organizer?.bio, contains('Outdoor enthusiast'));
      expect(event.startTime, DateTime.parse('2024-06-01T05:45:00Z'));
      expect(event.endTime, DateTime.parse('2024-06-01T07:00:00Z'));
      expect(event.createdAt, DateTime.parse('2024-05-01T12:00:00Z'));
      expect(event.updatedAt, DateTime.parse('2024-05-10T12:00:00Z'));
      expect(event.tags, containsAll(['Running', 'Outdoor']));
      expect(event.firstAvailableImageUrl, 'https://example.com/photo-1.jpg');
      expect(event.participantSummary, '12/20');
    });

    test('parses flat legacy structure', () {
      final json = {
        'id': 7,
        'title': 'Coffee Chat',
        'description': 'Meet other founders for a casual chat.',
        'location': 'Brew Lab',
        'latitude': 48.8566,
        'longitude': 2.3522,
        'imageUrls': ['https://example.com/coffee.png'],
        'startTime': '2024-07-20T09:00:00Z',
        'endTime': '2024-07-20T11:00:00Z',
        'maxParticipants': 15,
        'currentParticipants': 15,
        'isFavorite': false,
        'isRegistered': true,
        'likes': 28,
        'organizerId': 'org-1',
        'organizerName': 'Crew Team',
        'organizerAvatar': 'https://example.com/crew.png',
      };

      final event = Event.fromJson(json);

      expect(event.id, '7');
      expect(event.organizer?.id, 'org-1');
      expect(event.organizer?.name, 'Crew Team');
      expect(event.isRegistered, isTrue);
      expect(event.isFull, isTrue);
      expect(event.likes, 28);
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
        maxParticipants: 24,
        currentParticipants: 10,
        isFavorite: true,
        isRegistered: false,
        likes: 512,
        price: 12.5,
        tags: const ['Games', 'Social'],
        organizer: const EventOrganizer(
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
      expect(json['likes'], 512);
      expect(json['isFavorite'], true);
      expect(json['tags'], ['Games', 'Social']);
      expect(json['organizer'], {
        'id': 'user-7',
        'name': 'Ben',
        'avatarUrl': 'https://example.com/avatar.jpg',
      });
    });
  });
}
