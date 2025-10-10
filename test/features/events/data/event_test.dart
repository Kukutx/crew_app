import 'package:crew_app/features/events/data/event.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _baseEventJson() => {
      'id': '1',
      'title': 'Sample Event',
      'description': 'Description',
      'location': 'Location',
      'latitude': 1.0,
      'longitude': 2.0,
    };

void main() {
  group('Event.fromJson image parsing', () {
    test('parses single string imageUrl into list', () {
      final event = Event.fromJson({
        ..._baseEventJson(),
        'imageUrls': 'https://example.com/image.jpg',
      });

      expect(event.imageUrls, ['https://example.com/image.jpg']);
      expect(event.firstAvailableImageUrl, 'https://example.com/image.jpg');
    });

    test('parses nested media maps with url keys', () {
      final event = Event.fromJson({
        ..._baseEventJson(),
        'media': {
          'images': [
            {'url': 'https://example.com/a.jpg'},
            {'imageUrl': 'https://example.com/b.jpg'},
            {
              'data': {
                'src': 'https://example.com/c.jpg',
              },
            },
          ],
        },
      });

      expect(
        event.imageUrls,
        [
          'https://example.com/a.jpg',
          'https://example.com/b.jpg',
          'https://example.com/c.jpg',
        ],
      );
      expect(event.firstAvailableImageUrl, 'https://example.com/a.jpg');
    });
  });
}
