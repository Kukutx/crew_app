import 'package:crew_app/features/messages/data/direct_chat_preview.dart';
import 'package:crew_app/shared/widgets/crew_avatar.dart';
import 'package:flutter/material.dart';

class DirectChatList extends StatelessWidget {
  const DirectChatList({
    super.key,
    required this.conversations,
    this.onConversationTap,
    this.onAvatarTap,
    this.showSectionHeaders = true,
    this.storageKey,
    this.controller,
    this.physics,
    this.padding = const EdgeInsets.only(bottom: 24),
    this.shrinkWrap = false,
  });

  final List<DirectChatPreview> conversations;
  final ValueChanged<DirectChatPreview>? onConversationTap;
  final ValueChanged<DirectChatPreview>? onAvatarTap;
  final bool showSectionHeaders;
  final Key? storageKey;
  final ScrollController? controller;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    final systemConversations =
        conversations.where((conversation) => conversation.isSystem).toList();
    final regularConversations = conversations
        .where((conversation) => !conversation.isSystem)
        .toList(growable: false);

    final tiles = <Widget>[];

    if (systemConversations.isNotEmpty) {
      if (showSectionHeaders) {
        tiles.add(
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 16, 24, 4),
            child: _SectionHeader(label: '系统通知'),
          ),
        );
      }

      tiles.addAll(
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
      if (systemConversations.isNotEmpty && showSectionHeaders) {
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
      key: storageKey ?? const PageStorageKey('messages-chat-private-list'),
      controller: controller,
      padding: padding,
      physics: physics ?? const BouncingScrollPhysics(),
      shrinkWrap: shrinkWrap,
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
        ? colorScheme.surfaceContainerHighest.withValues(alpha: .6)
        : colorScheme.surface;
    final effectiveShadowColor = colorScheme.shadow.withValues(alpha: .12);

    final titleStyle = isSystem
        ? Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
              height: 1.3,
              letterSpacing: 0,
            ) ??
            TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
              height: 1.3,
              letterSpacing: 0,
            )
        : TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            height: 1.3,
            letterSpacing: -0.2,
          );

    final subtitleStyle = isSystem
        ? Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 13,
              color: colorScheme.onSurfaceVariant.withValues(alpha: .8),
              height: 1.4,
              letterSpacing: 0,
            ) ??
            TextStyle(
              fontSize: 13,
              color: colorScheme.onSurfaceVariant.withValues(alpha: .8),
              height: 1.4,
              letterSpacing: 0,
            )
        : TextStyle(
            fontSize: 14,
            color: subtitleColor,
            height: 1.4,
            letterSpacing: 0,
          );

    final timeStyle = isSystem
        ? Theme.of(context).textTheme.labelSmall?.copyWith(
              fontSize: 11,
              color: colorScheme.onSurfaceVariant.withValues(alpha: .7),
              height: 1.3,
              letterSpacing: 0,
            ) ??
            TextStyle(
              fontSize: 11,
              color: colorScheme.onSurfaceVariant.withValues(alpha: .7),
              height: 1.3,
              letterSpacing: 0,
            )
        : TextStyle(
            fontSize: 12,
            color: colorScheme.onSurfaceVariant,
            height: 1.3,
            letterSpacing: 0,
          );

    // 如果提供了 onConversationTap，就允许点击
    // 这样可以在系统通知页面中点击系统通知
    final effectiveOnTap = onConversationTap == null
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
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: effectiveOnTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(isSystem ? 16 : 18),
                    onTap: effectiveOnAvatarTap,
                    child: CrewAvatar(
                      radius: isSystem ? 22 : 24,
                      backgroundColor: isSystem
                          ? colorScheme.secondaryContainer
                          : avatarColor.withValues(alpha: .12),
                      foregroundColor: isSystem
                          ? colorScheme.onSecondaryContainer
                          : avatarColor,
                      child: isSystem
                          ? (conversation.id == 'customer-service'
                              ? const Icon(Icons.support_agent_outlined)
                              : const Icon(Icons.notifications_none_outlined))
                          : Text(
                              (conversation.initials ?? conversation.displayName)
                                  .characters
                                  .take(2)
                                  .toString()
                                  .toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
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
