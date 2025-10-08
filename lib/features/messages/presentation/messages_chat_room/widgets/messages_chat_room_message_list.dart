import 'package:crew_app/features/messages/data/group_message.dart';
import 'package:crew_app/features/messages/presentation/messages_chat_room/widgets/messages_chat_room_message_tile.dart';
import 'package:flutter/material.dart';


class MessagesChatRoomMessageList extends StatelessWidget {
  const MessagesChatRoomMessageList({
    super.key,
    required this.messages,
    required this.scrollController,
    required this.youLabel,
    required this.repliesLabelBuilder,
  });

  final List<GroupMessage> messages;
  final ScrollController scrollController;
  final String youLabel;
  final String Function(int) repliesLabelBuilder;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.only(bottom: 24, top: 16),
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final message = messages[index];
          final bool showAvatar = index == 0
              ? true
              : !messages[index - 1].isFromSameSender(messages[index]);

          return MessagesChatRoomMessageTile(
            message: message,
            showAvatar: showAvatar,
            youLabel: youLabel,
            repliesLabelBuilder: repliesLabelBuilder,
          );
        },
      ),
    );
  }
}
