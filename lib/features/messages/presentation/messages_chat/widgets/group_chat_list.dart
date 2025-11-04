import 'package:crew_app/features/messages/data/group_chat_preview.dart';
import 'package:crew_app/shared/widgets/crew_avatar.dart';
import 'package:flutter/material.dart';

class GroupChatList extends StatelessWidget {
  const GroupChatList({
    super.key,
    required this.events,
    this.onEventTap,
    this.controller,
    this.physics,
    this.padding = const EdgeInsets.only(bottom: 24),
    this.shrinkWrap = false,
  });

  final List<GroupChatPreview> events;
  final ValueChanged<GroupChatPreview>? onEventTap;
  final ScrollController? controller;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      key: const PageStorageKey('messages-chat-group-list'),
      controller: controller,
      padding: padding,
      physics: physics ?? const BouncingScrollPhysics(),
      shrinkWrap: shrinkWrap,
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

class GroupChatListTile extends StatelessWidget {
  const GroupChatListTile({
    super.key,
    required this.preview,
    this.onTap,
  });

  final GroupChatPreview preview;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accentColor = Color(preview.accentColorValue);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        color: colorScheme.surface,
        elevation: 0,
        shadowColor: colorScheme.shadow.withValues(alpha: 0.08),
        surfaceTintColor: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CrewAvatar(
                      radius: 24,
                      backgroundColor: accentColor.withValues(alpha: .12),
                      foregroundColor: accentColor,
                      child: Icon(
                        Icons.forum_outlined,
                        size: 22,
                      ),
                    ),
                    if (preview.unreadCount > 0)
                      Positioned(
                        right: -4,
                        top: -4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.error,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            preview.unreadCount.toString(),
                            style: TextStyle(
                              color: colorScheme.onError,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              preview.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                height: 1.3,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                          if (preview.status != null)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                preview.status!,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: colorScheme.onSecondaryContainer,
                                  fontWeight: FontWeight.w600,
                                  height: 1.2,
                                  letterSpacing: 0,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        preview.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                          height: 1.4,
                          letterSpacing: 0,
                        ),
                      ),
                      if (preview.tags.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: preview.tags
                                .map(
                                  (tag) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colorScheme.surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      tag,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: colorScheme.onSurfaceVariant,
                                        height: 1.3,
                                        letterSpacing: 0,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      preview.lastMessageTimeLabel ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                        height: 1.3,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: colorScheme.onSurfaceVariant.withValues(alpha: .6),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
