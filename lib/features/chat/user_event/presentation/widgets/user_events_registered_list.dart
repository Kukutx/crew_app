import 'package:flutter/material.dart';

import '../../data/user_event.dart';
import 'user_event_list_tile.dart';

class UserEventsRegisteredList extends StatelessWidget {
  const UserEventsRegisteredList({
    super.key,
    required this.events,
    this.onEventTap,
    this.controller,
    this.physics,
  });

  final List<UserEventPreview> events;
  final ValueChanged<int>? onEventTap;
  final ScrollController? controller;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      key: const PageStorageKey('user-events-registered-list'),
      padding: const EdgeInsets.only(bottom: 24),
      controller: controller,
      physics:
          physics ?? const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
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
