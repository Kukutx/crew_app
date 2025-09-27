import 'package:flutter/material.dart';

import '../user_event/data/user_event.dart';
import 'user_event_list_tile.dart';

class UserEventsRegisteredList extends StatelessWidget {
  const UserEventsRegisteredList({
    super.key,
    required this.events,
    this.onEventTap,
  });

  final List<UserEventPreview> events;
  final ValueChanged<int>? onEventTap;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      key: const PageStorageKey('user-events-registered-list'),
      padding: const EdgeInsets.only(bottom: 24),
      physics: const BouncingScrollPhysics(),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return UserEventListTile(
          event: event,
          onTap: onEventTap == null ? null : () => onEventTap!(index),
        );
      },
    );
  }
}
