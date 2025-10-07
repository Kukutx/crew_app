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
    this.padding,
  });

  final List<UserEventPreview> events;
  final ValueChanged<int>? onEventTap;
  final ScrollController? controller;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      key: const PageStorageKey('user-events-registered-list'),
      controller: controller,
      padding: padding ?? const EdgeInsets.only(bottom: 24),
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
