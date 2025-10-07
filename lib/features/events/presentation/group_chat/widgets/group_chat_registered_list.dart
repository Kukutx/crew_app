import 'package:crew_app/features/events/data/group_chat_preview.dart';
import 'package:crew_app/features/events/presentation/group_chat/group_chat_page.dart';
import 'package:flutter/material.dart';

class GroupChatRegisteredList extends StatelessWidget {
  const GroupChatRegisteredList({
    super.key,
    required this.events,
    this.onEventTap,
  });

  final List<GroupChatPreview> events;
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
        return GroupChatListTile(
          event: event,
          onTap: onEventTap == null ? null : () => onEventTap!(index),
        );
      },
    );
  }
}
