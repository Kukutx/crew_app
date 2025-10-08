import 'package:crew_app/features/messages/data/group_chat_preview.dart';
import 'package:crew_app/features/messages/presentation/group_chat/widgets/group_chat_grid_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

typedef GroupChatTap = void Function(int index);

class GroupChatFavoritesGrid extends StatelessWidget {
  const GroupChatFavoritesGrid({
    super.key,
    required this.events,
    this.onEventTap,
  });

  final List<GroupChatPreview> events;
  final GroupChatTap? onEventTap;

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
        return GroupChatGridCard(
          event: event,
          onTap: onEventTap == null ? null : () => onEventTap!(index),
        );
      },
    );
  }
}
