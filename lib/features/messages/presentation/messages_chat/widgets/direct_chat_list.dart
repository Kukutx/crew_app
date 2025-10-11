import 'package:crew_app/features/messages/data/direct_chat_preview.dart';
import 'package:flutter/material.dart';

class DirectChatList extends StatelessWidget {
  const DirectChatList({
    super.key,
    required this.conversations,
    this.onConversationTap,
  });

  final List<DirectChatPreview> conversations;
  final ValueChanged<DirectChatPreview>? onConversationTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView.builder(
      key: const PageStorageKey('messages-chat-private-list'),
      padding: const EdgeInsets.only(bottom: 24),
      physics: const BouncingScrollPhysics(),
      itemCount: conversations.length,
      itemBuilder: (context, index) {
        final conversation = conversations[index];
        final avatarColor = Color(
          conversation.avatarColorValue ?? colorScheme.primary.toARGB32(),
        );
        final subtitleColor = Color(
          conversation.subtitleColorValue ??
              colorScheme.onSurfaceVariant.withValues(alpha: .9).toARGB32(),
        );

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Material(
            color: colorScheme.surface,
            elevation: 2,
            shadowColor: colorScheme.shadow.withValues(alpha: .12),
            borderRadius: BorderRadius.circular(18),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onConversationTap == null
                  ? null
                  : () => onConversationTap!(conversation),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: avatarColor.withValues(alpha: .12),
                          child: Text(
                            (conversation.initials ?? conversation.displayName)
                                .characters
                                .take(2)
                                .toString()
                                .toUpperCase(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: avatarColor,
                            ),
                          ),
                        ),
                        if (conversation.isActive)
                          Positioned(
                            right: -2,
                            bottom: -2,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: const Color(0xFF4CAF50),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: colorScheme.surface,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  conversation.displayName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              if (conversation.hasUnread)
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            conversation.lastMessagePreview,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: subtitleColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      conversation.lastMessageTimeLabel,
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
