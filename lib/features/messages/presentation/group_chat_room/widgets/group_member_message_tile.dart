import 'package:crew_app/features/messages/data/group_message.dart';
import 'package:flutter/material.dart';


class GroupMemberMessageTile extends StatelessWidget {
  const GroupMemberMessageTile({
    super.key,
    required this.message,
    required this.showAvatar,
    required this.youLabel,
    required this.repliesLabelBuilder,
  });

  final GroupMessage message;
  final bool showAvatar;
  final String youLabel;
  final String Function(int) repliesLabelBuilder;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isMine = message.isMine;
    final bubbleColor = isMine ? colorScheme.primary : colorScheme.surface;
    final textColor = isMine ? colorScheme.onPrimary : colorScheme.onSurface;
    final captionColor =
        isMine ? colorScheme.onPrimary.withValues(alpha: .8) : colorScheme.onSurfaceVariant;

    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: isMine ? 80 : 16,
        end: isMine ? 16 : 80,
        top: 6,
        bottom: 6,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMine)
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: showAvatar ? 1 : 0,
              child: showAvatar
                  ? CircleAvatar(
                      radius: 18,
                      backgroundColor: message.sender.avatarColor.withValues(alpha: .15),
                      child: Text(
                        message.sender.initials,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: message.sender.avatarColor,
                        ),
                      ),
                    )
                  : const SizedBox(width: 36),
            )
          else
            const SizedBox(width: 36),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  isMine
                      ? '$youLabel · ${message.timeLabel}'
                      : '${message.sender.name} · ${message.timeLabel}',
                  style: TextStyle(
                    fontSize: 12,
                    color: captionColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(isMine ? 20 : 8),
                      bottomRight: Radius.circular(isMine ? 8 : 20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.shadow.withValues(alpha: .04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment:
                        isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.content,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.4,
                          color: textColor,
                        ),
                      ),
                      if (message.attachmentChips.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: message.attachmentChips
                              .map(
                                (chip) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isMine
                                        ? colorScheme.onPrimary.withValues(alpha: .12)
                                        : colorScheme.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.insert_drive_file_outlined,
                                        size: 14,
                                        color: textColor.withValues(alpha: .85),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        chip,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: textColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                ),
                if (message.replyCount != null && message.replyCount! > 0)
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withValues(alpha: .3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.reply_all, size: 16, color: colorScheme.primary),
                        const SizedBox(width: 6),
                        Text(
                          message.replyPreview ?? repliesLabelBuilder(message.replyCount!),
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (isMine)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Icon(
                      Icons.done_all,
                      size: 16,
                      color: colorScheme.primary,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
