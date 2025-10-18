import 'event_card_dto.dart';

class EventFeedResponseDto {
  final List<EventCardDto> events;
  final String? nextCursor;

  EventFeedResponseDto({required this.events, this.nextCursor});

  factory EventFeedResponseDto.fromJson(Map<String, dynamic> json) =>
      EventFeedResponseDto(
        events: (json['events'] as List)
            .map((e) => EventCardDto.fromJson(e))
            .toList(),
        nextCursor: json['nextCursor'],
      );

  Map<String, dynamic> toJson() => {
        'events': events.map((e) => e.toJson()).toList(),
        'nextCursor': nextCursor,
      };
}
