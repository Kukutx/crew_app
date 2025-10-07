import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../data/user_event.dart';
import 'user_event_grid_card.dart';

typedef UserEventTap = void Function(int index);

class UserEventsFavoritesGrid extends StatelessWidget {
  const UserEventsFavoritesGrid({
    super.key,
    required this.events,
    this.onEventTap,
    this.controller,
    this.physics,
  });

  final List<UserEventPreview> events;
  final UserEventTap? onEventTap;
  final ScrollController? controller;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    return MasonryGridView.count(
      key: const PageStorageKey('user-events-favorites-grid'),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      controller: controller,
      physics:
          physics ?? const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      primary: controller == null,
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return UserEventGridCard(
          event: event,
          onTap: onEventTap == null ? null : () => onEventTap!(index),
        );
      },
    );
  }
}
