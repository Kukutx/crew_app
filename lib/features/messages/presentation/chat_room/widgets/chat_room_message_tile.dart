import 'package:crew_app/features/messages/data/chat_message.dart';
import 'package:crew_app/features/messages/data/chat_participant.dart';
import 'package:crew_app/shared/widgets/crew_avatar.dart';
import 'package:flutter/material.dart';

class ChatRoomMessageTile extends StatelessWidget {
  const ChatRoomMessageTile({
    super.key,
    required this.message,
    required this.showAvatar,
    required this.youLabel,
    required this.repliesLabelBuilder,
    this.isHighlighted = false,
    this.onAvatarTap,
  });

  final ChatMessage message;
  final bool showAvatar;
  final String youLabel;
  final String Function(int) repliesLabelBuilder;
  final bool isHighlighted;
  final ValueChanged<ChatParticipant>? onAvatarTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isMine = message.isFromCurrentUser;
    // 判断是否为客服消息
    final isCustomerService = message.sender.id == 'customer-service-agent';
    // 判断是否为系统通知消息
    final isSystemNotification = message.sender.displayName == '系统通知' ||
        message.sender.id.contains('system');
    
    // 使用 surfaceContainerHighest 提高其他用户气泡的对比度，让气泡更清晰可见
    final bubbleColor = isMine 
        ? colorScheme.primary 
        : colorScheme.surfaceContainerHighest;
    final textColor = isMine ? colorScheme.onPrimary : colorScheme.onSurface;
    final captionColor =
        isMine ? colorScheme.onPrimary.withValues(alpha: .8) : colorScheme.onSurfaceVariant;
    
    // 如果是客服或系统通知，使用与通知页相同的颜色方案
    final isSystemMessage = isCustomerService || isSystemNotification;
    final senderColor = isSystemMessage
        ? null // 系统消息使用主题色，不单独设置
        : Color(
            message.sender.avatarColorValue ?? colorScheme.primary.toARGB32(),
          );
    
    final senderInitials = (message.sender.initials ??
            message.sender.displayName.characters.take(2).toString())
        .toUpperCase();

    final highlightColor =
        isHighlighted ? colorScheme.primary.withValues(alpha: .08) : Colors.transparent;

    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: isMine ? 72 : 16,
        end: isMine ? 16 : 72,
        top: 4,
        bottom: 4,
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: highlightColor,
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (!isMine)
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: showAvatar ? 1 : 0,
                child: showAvatar
                    ? GestureDetector(
                        onTap: onAvatarTap == null
                            ? null
                            : () => onAvatarTap!(message.sender),
                        child: CrewAvatar(
                          radius: 16,
                          backgroundColor: isSystemMessage
                              ? colorScheme.secondaryContainer
                              : senderColor!.withValues(alpha: .15),
                          foregroundColor: isSystemMessage
                              ? colorScheme.onSecondaryContainer
                              : senderColor!,
                          child: isCustomerService
                              ? const Icon(Icons.support_agent_outlined, size: 18)
                              : isSystemNotification
                                  ? const Icon(Icons.notifications_none_outlined, size: 18)
                                  : Text(
                                      senderInitials,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                        ),
                      )
                    : const SizedBox(width: 32),
              )
            else
              const SizedBox(width: 32),
            const SizedBox(width: 10),
            Flexible(
            child: Column(
              crossAxisAlignment:
                  isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsetsDirectional.only(
                    start: isMine ? 0 : 4,
                    end: isMine ? 4 : 0,
                    bottom: 4,
                  ),
                  child: Text(
                    isMine
                        ? '$youLabel · ${message.sentAtLabel}'
                        : '${message.sender.displayName} · ${message.sentAtLabel}',
                    style: TextStyle(
                      fontSize: 11,
                      color: captionColor,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                      letterSpacing: 0,
                    ),
                  ),
                ),
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isMine ? 18 : 4),
                      bottomRight: Radius.circular(isMine ? 4 : 18),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.shadow.withValues(alpha: .06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment:
                        isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.body,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          color: textColor,
                          letterSpacing: 0.2,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      if (message.attachmentLabels.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: message.attachmentLabels
                              .map(
                                (chip) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isMine
                                        ? colorScheme.onPrimary.withValues(alpha: .15)
                                        : colorScheme.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(10),
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
                                          height: 1.3,
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
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withValues(alpha: .4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.reply_all, size: 14, color: colorScheme.primary),
                        const SizedBox(width: 6),
                        Text(
                          message.replyPreview ?? repliesLabelBuilder(message.replyCount!),
                          style: TextStyle(
                            fontSize: 11,
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (isMine)
                  Padding(
                    padding: const EdgeInsets.only(top: 3, left: 4),
                    child: Icon(
                      Icons.done_all,
                      size: 14,
                      color: colorScheme.primary.withValues(alpha: 0.8),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}
