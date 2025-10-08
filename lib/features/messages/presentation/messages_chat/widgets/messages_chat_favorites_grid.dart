import 'package:crew_app/features/messages/data/messages_chat_preview.dart';
import 'package:crew_app/features/messages/presentation/messages_chat/widgets/messages_chat_grid_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

typedef MessagesChatTap = void Function(int index);

class MessagesChatFavoritesGrid extends StatelessWidget {
  const MessagesChatFavoritesGrid({
    super.key,
    required this.events,
    this.onEventTap,
  });

  final List<MessagesChatPreview> events;
  final MessagesChatTap? onEventTap;

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
        return MessagesChatGridCard(
          event: event,
          onTap: onEventTap == null ? null : () => onEventTap!(index),
        );
      },
    );
  }
}
