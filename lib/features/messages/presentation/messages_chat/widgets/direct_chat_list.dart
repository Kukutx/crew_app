import 'package:crew_app/features/messages/data/direct_chat_preview.dart';
import 'package:flutter/material.dart';

class DirectChatList extends StatelessWidget {
  const DirectChatList({
    super.key,
    required this.conversations,
    this.onConversationTap,
    this.onAvatarTap,
  });

  final List<DirectChatPreview> conversations;
  final ValueChanged<DirectChatPreview>? onConversationTap;
  final ValueChanged<DirectChatPreview>? onAvatarTap;

  @override
  Widget build(BuildContext context) {
    final systemConversations =
        conversations.where((conversation) => conversation.isSystem).toList();
    final regularConversations = conversations
        .where((conversation) => !conversation.isSystem)
        .toList(growable: false);

    final tiles = <Widget>[];

    if (systemConversations.isNotEmpty) {
      tiles
        ..add(
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 16, 24, 4),
            child: _SectionHeader(label: '系统通知'),
          ),
        )
        ..addAll(
          systemConversations.map(
            (conversation) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: _DirectChatTile(
                conversation: conversation,
                onConversationTap: onConversationTap,
                onAvatarTap: onAvatarTap,
                isSystem: true,
              ),
            ),
          ),
        );
    }

    if (regularConversations.isNotEmpty) {
      if (systemConversations.isNotEmpty) {
        tiles.add(
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 12, 24, 0),
            child: _SectionHeader(label: '好友消息'),
          ),
        );
      }

      tiles.addAll(
        regularConversations.map(
          (conversation) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _DirectChatTile(
              conversation: conversation,
              onConversationTap: onConversationTap,
              onAvatarTap: onAvatarTap,
            ),
          ),
        ),
      );
    }

    return ListView(
      key: const PageStorageKey('messages-chat-private-list'),
      padding: const EdgeInsets.only(bottom: 24),
      physics: const BouncingScrollPhysics(),
      children: tiles,
    );
  }
}

class _DirectChatTile extends StatelessWidget {
  const _DirectChatTile({
    required this.conversation,
    this.onConversationTap,
    this.onAvatarTap,
    this.isSystem = false,
  });

  final DirectChatPreview conversation;
  final ValueChanged<DirectChatPreview>? onConversationTap;
  final ValueChanged<DirectChatPreview>? onAvatarTap;
  final bool isSystem;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final avatarColor = Color(
      conversation.avatarColorValue ?? colorScheme.primary.toARGB32(),
    );
    final subtitleColor = Color(
      conversation.subtitleColorValue ??
          colorScheme.onSurfaceVariant.withValues(alpha: .9).toARGB32(),
    );

    final effectiveTileColor = isSystem
        ? colorScheme.surfaceVariant.withValues(alpha: .6)
        : colorScheme.surface;
    final effectiveShadowColor = colorScheme.shadow.withValues(alpha: .12);

    final titleStyle = isSystem
        ? Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
            ) ??
            TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
            )
        : const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          );

    final subtitleStyle = isSystem
        ? Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant.withValues(alpha: .8),
            ) ??
            TextStyle(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant.withValues(alpha: .8),
            )
        : TextStyle(
            fontSize: 13,
            color: subtitleColor,
          );

    final timeStyle = isSystem
        ? Theme.of(context).textTheme.labelSmall?.copyWith(
              fontSize: 11,
              color: colorScheme.onSurfaceVariant.withValues(alpha: .7),
            ) ??
            TextStyle(
              fontSize: 11,
              color: colorScheme.onSurfaceVariant.withValues(alpha: .7),
            )
        : TextStyle(
            fontSize: 12,
            color: colorScheme.onSurfaceVariant,
          );

    final effectiveOnTap = (conversation.isSystem || isSystem)
        ? null
        : onConversationTap == null
            ? null
            : () => onConversationTap!(conversation);

    final effectiveOnAvatarTap = (conversation.isSystem || isSystem)
        ? null
        : onAvatarTap == null
            ? null
            : () => onAvatarTap!(conversation);

    return Material(
      color: effectiveTileColor,
      elevation: isSystem ? 0 : 2,
      shadowColor: effectiveShadowColor,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: effectiveOnTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  InkWell(
                    customBorder: const CircleBorder(),
                    onTap: effectiveOnAvatarTap,
                    child: CircleAvatar(
                      radius: isSystem ? 22 : 24,
                      backgroundColor: isSystem
                          ? colorScheme.secondaryContainer
                          : avatarColor.withValues(alpha: .12),
                      child: isSystem
                          ? Icon(
                              Icons.notifications_none_outlined,
                              color: colorScheme.onSecondaryContainer,
                            )
                          : Text(
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
                  ),
                  if (!isSystem && conversation.isActive)
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
                            style: titleStyle,
                          ),
                        ),
                        if (!isSystem && conversation.hasUnread)
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
                      style: subtitleStyle,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Text(
                conversation.lastMessageTimeLabel,
                style: timeStyle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Text(
      label,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurfaceVariant.withValues(alpha: .7),
          ) ??
          TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurfaceVariant.withValues(alpha: .7),
          ),
    );
  }
}
