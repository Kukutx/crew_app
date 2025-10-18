import 'event_card_dto.dart';
import 'json_helpers.dart';

class EventFeedResponseDto {
  final List<EventCardDto> events;
  final String? nextCursor;

  EventFeedResponseDto({required List<EventCardDto> events, this.nextCursor})
      : events = List.unmodifiable(events);

  factory EventFeedResponseDto.fromJson(Map<String, dynamic> json) {
    final eventMaps = parseMapList(json['events']);
    final cursor = json['nextCursor'];
    final events = eventMaps
        .map((data) => EventCardDto.fromJson(data))
        .toList(growable: false);
    final cursorText = cursor == null ? null : cursor.toString().trim();
    return EventFeedResponseDto(
      events: events,
      nextCursor: (cursorText == null || cursorText.isEmpty) ? null : cursorText,
    );
  }

  Map<String, dynamic> toJson() => {
        'events': events.map((e) => e.toJson()).toList(),
        'nextCursor': nextCursor,
      };
}
