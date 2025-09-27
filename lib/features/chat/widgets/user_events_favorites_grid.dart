import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../user_event/data/user_event.dart';
import 'user_event_grid_card.dart';

typedef UserEventTap = void Function(int index);

class UserEventsFavoritesGrid extends StatelessWidget {
  const UserEventsFavoritesGrid({
    super.key,
    required this.events,
    this.onEventTap,
  });

  final List<UserEventPreview> events;
  final UserEventTap? onEventTap;

  @override
  Widget build(BuildContext context) {
    return MasonryGridView.count(
      key: const PageStorageKey('user-events-favorites-grid'),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      physics: const BouncingScrollPhysics(),
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
