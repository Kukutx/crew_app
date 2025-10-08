import 'package:crew_app/features/messages/data/messages_chat_preview.dart';
import 'package:crew_app/features/messages/presentation/messages_chat/widgets/messages_chat_list_tile.dart';
import 'package:flutter/material.dart';

class MessagesChatRegisteredList extends StatelessWidget {
  const MessagesChatRegisteredList({
    super.key,
    required this.events,
    this.onEventTap,
  });

  final List<MessagesChatPreview> events;
  final ValueChanged<int>? onEventTap;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      key: const PageStorageKey('messages-chat-group-list'),
      padding: const EdgeInsets.only(bottom: 24),
      physics: const BouncingScrollPhysics(),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return MessagesChatListTile(
          event: event,
          onTap: onEventTap == null ? null : () => onEventTap!(index),
        );
      },
    );
  }
}
