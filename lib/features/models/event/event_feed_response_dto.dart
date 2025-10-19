import 'event_card_dto.dart';

class EventFeedResponseDto {
  final List<EventCardDto> events;
  final String? nextCursor;

  EventFeedResponseDto({required this.events, this.nextCursor});

  factory EventFeedResponseDto.fromJson(Map<String, dynamic> json) {
    final eventsJson = json['events'];
    final events = eventsJson is List
        ? eventsJson
            .whereType<Map<String, dynamic>>()
            .map(EventCardDto.fromJson)
            .toList(growable: false)
        : const <EventCardDto>[];

    return EventFeedResponseDto(
      events: events,
      nextCursor: json['nextCursor'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'events': events.map((e) => e.toJson()).toList(),
        'nextCursor': nextCursor,
      };
}
