import '../../../data/event.dart';

enum EventDetailAction {
  showOnMap,
  startAddWaypoint,
  startEditWaypoint,
}

class EventDetailResult {
  final Event event;
  final EventDetailAction? action;
  final int? waypointIndex;

  const EventDetailResult({
    required this.event,
    this.action,
    this.waypointIndex,
  });

  factory EventDetailResult.showOnMap(Event event) =>
      EventDetailResult(event: event, action: EventDetailAction.showOnMap);

  factory EventDetailResult.requestAddWaypoint(Event event) =>
      EventDetailResult(event: event, action: EventDetailAction.startAddWaypoint);

  factory EventDetailResult.requestEditWaypoint(Event event, int index) =>
      EventDetailResult(
        event: event,
        action: EventDetailAction.startEditWaypoint,
        waypointIndex: index,
      );

  EventDetailResult withEvent(Event updated) =>
      EventDetailResult(event: updated, action: action, waypointIndex: waypointIndex);
}
