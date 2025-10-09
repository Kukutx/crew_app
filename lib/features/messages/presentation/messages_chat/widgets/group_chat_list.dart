import 'package:crew_app/features/messages/data/group_chat_preview.dart';
import 'package:crew_app/features/messages/presentation/messages_chat/widgets/group_chat_list_tile.dart';
import 'package:flutter/material.dart';

class GroupChatList extends StatelessWidget {
  const GroupChatList({
    super.key,
    required this.events,
    this.onEventTap,
  });

  final List<GroupChatPreview> events;
  final ValueChanged<GroupChatPreview>? onEventTap;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      key: const PageStorageKey('messages-chat-group-list'),
      padding: const EdgeInsets.only(bottom: 24),
      physics: const BouncingScrollPhysics(),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return GroupChatListTile(
          preview: event,
          onTap: onEventTap == null ? null : () => onEventTap!(event),
        );
      },
    );
  }
}
