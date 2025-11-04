import 'package:crew_app/features/messages/data/chat_message.dart';
import 'package:crew_app/features/messages/data/chat_participant.dart';
import 'package:crew_app/features/messages/presentation/chat_room/widgets/chat_room_message_tile.dart';
import 'package:flutter/material.dart';

class ChatRoomMessageList extends StatelessWidget {
  const ChatRoomMessageList({
    super.key,
    required this.messages,
    required this.scrollController,
    required this.youLabel,
    required this.repliesLabelBuilder,
    this.messageKeys,
    this.highlightedMessageId,
    this.onAvatarTap,
  });

  final List<ChatMessage> messages;
  final ScrollController scrollController;
  final String youLabel;
  final String Function(int) repliesLabelBuilder;
  final Map<String, GlobalKey>? messageKeys;
  final String? highlightedMessageId;
  final ValueChanged<ChatParticipant>? onAvatarTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.only(bottom: 20, top: 12),
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final message = messages[index];
          final bool showAvatar = index == 0
              ? true
              : !messages[index - 1].isFromSameSender(messages[index]);
          final key = messageKeys?[message.id];

          return ChatRoomMessageTile(
            key: key ?? ValueKey('chat-message-${message.id}'),
            message: message,
            showAvatar: showAvatar,
            youLabel: youLabel,
            repliesLabelBuilder: repliesLabelBuilder,
            isHighlighted: highlightedMessageId == message.id,
            onAvatarTap: onAvatarTap,
          );
        },
      ),
    );
  }
}
