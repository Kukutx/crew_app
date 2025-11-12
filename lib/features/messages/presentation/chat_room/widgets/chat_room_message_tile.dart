import 'package:crew_app/features/messages/data/chat_message.dart';
import 'package:crew_app/features/messages/data/chat_member.dart';
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
  final ValueChanged<ChatMember>? onAvatarTap;

  // 提取动画时长常量
  static const _animationDuration = Duration(milliseconds: 200);
  // 气泡最大宽度比例
  static const _maxBubbleWidthRatio = 0.75;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final isDark = colorScheme.brightness == Brightness.dark;
    
    final isMine = message.isFromCurrentUser;
    // 判断是否为客服消息
    final isCustomerService = message.sender.id == 'customer-service-agent';
    // 判断是否为系统通知消息（改进：更精确的判断，避免误判）
    final isSystemNotification = (message.sender.displayName == '系统通知' ||
        message.sender.id.toLowerCase().contains('system'));
    
    // 使用 surfaceContainerHighest 提高其他用户气泡的对比度，让气泡更清晰可见
    // 在深色主题下，通过混合白色提高气泡亮度以增强对比度
    final bubbleColor = isMine 
        ? colorScheme.primary 
        : (isDark
            ? Color.alphaBlend(
                Colors.white.withValues(alpha: 0.08),
                colorScheme.surfaceContainerHighest,
              )  // 深色主题下混合白色提高亮度
            : colorScheme.surfaceContainerHighest);
    final textColor = isMine ? colorScheme.onPrimary : colorScheme.onSurface;
    // 优化：提高时间戳文本对比度，确保在深色主题下清晰可见
    final captionColor = isMine
        ? (isDark
            ? colorScheme.onSurface.withValues(alpha: 0.7)  // 深色主题下使用更亮的颜色
            : colorScheme.onPrimary.withValues(alpha: .85))  // 浅色主题下保持原有逻辑
        : (isDark
            ? colorScheme.onSurfaceVariant.withValues(alpha: 0.9)  // 深色主题下提高对比度
            : colorScheme.onSurfaceVariant);
    
    // 如果是客服或系统通知，使用与通知页相同的颜色方案
    final isSystemMessage = isCustomerService || isSystemNotification;
    // 修复：避免在系统消息时使用 null，但后续访问时使用 !
    final senderColor = isSystemMessage
        ? null
        : Color(
            message.sender.avatarColorValue ?? colorScheme.primary.toARGB32(),
          );
    
    // 修复：正确提取前两个字符，避免 toString() 返回 'Characters(...)' 格式
    final displayName = message.sender.displayName.trim();
    final senderInitials = (message.sender.initials ??
            (displayName.isNotEmpty
                ? displayName.characters.take(2).join()
                : '??'))
        .toUpperCase();

    final highlightColor =
        isHighlighted ? colorScheme.primary.withValues(alpha: .08) : Colors.transparent;

    // 修复：检查消息内容是否为空
    final hasContent = message.body.trim().isNotEmpty || message.attachmentLabels.isNotEmpty;

    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: isMine ? 72 : 16,
        end: isMine ? 16 : 72,
        top: 4,
        bottom: 4,
      ),
      child: AnimatedContainer(
        duration: _animationDuration,
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
                duration: _animationDuration,
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
                  // 修复：只有当有内容时才显示气泡容器
                  if (hasContent)
                    Container(
                      constraints: BoxConstraints(
                        maxWidth: screenWidth * _maxBubbleWidthRatio,
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
                          // 修复：检查 body 是否为空，避免显示空文本
                          if (message.body.trim().isNotEmpty)
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
                            if (message.body.trim().isNotEmpty) const SizedBox(height: 10),
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
                                            color: textColor.withValues(alpha: isDark ? .95 : .85),
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
                              color: isDark
                                  ? colorScheme.onSurfaceVariant.withValues(alpha: 0.9)
                                  : colorScheme.onSurfaceVariant,
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
                        color: colorScheme.primary.withValues(alpha: isDark ? 0.9 : 0.8),
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
