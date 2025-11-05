import 'package:crew_app/features/messages/data/direct_chat_preview.dart';
import 'package:crew_app/features/messages/presentation/messages_chat/widgets/direct_chat_list.dart';
import 'package:crew_app/features/messages/presentation/notifications/system_notification_detail_page.dart';
import 'package:crew_app/features/messages/presentation/chat_room/pages/chat_conversation_page.dart';
import 'package:crew_app/features/messages/data/chat_message.dart';
import 'package:crew_app/features/messages/data/chat_participant.dart';
import 'package:flutter/material.dart';

/// 客服相关常量
class _CustomerServiceConstants {
  static const String id = 'customer-service';
  static const String displayName = '客服';
  static const String lastMessagePreview = '您好！我是客服，有什么可以帮助您的吗？';
  static const String lastMessageTimeLabel = '刚刚';
  static const String initials = 'KF';
  static const int avatarColorValue = 0xFF4C6ED7;
  static const String customerServiceAgentId = 'customer-service-agent';
}

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({
    super.key,
    required this.notifications,
  });

  final List<DirectChatPreview> notifications;

  /// 创建客服预览数据
  static DirectChatPreview _createCustomerServicePreview({bool isSystem = false}) {
    return DirectChatPreview(
      id: _CustomerServiceConstants.id,
      displayName: _CustomerServiceConstants.displayName,
      lastMessagePreview: _CustomerServiceConstants.lastMessagePreview,
      lastMessageTimeLabel: _CustomerServiceConstants.lastMessageTimeLabel,
      initials: _CustomerServiceConstants.initials,
      avatarColorValue: _CustomerServiceConstants.avatarColorValue,
      isSystem: isSystem,
    );
  }

  /// 创建客服参与者
  static ChatParticipant _createCustomerServiceAgent() {
    return ChatParticipant(
      id: _CustomerServiceConstants.customerServiceAgentId,
      displayName: _CustomerServiceConstants.displayName,
      initials: _CustomerServiceConstants.initials,
      avatarColorValue: _CustomerServiceConstants.avatarColorValue,
    );
  }

  /// 创建当前用户参与者
  static ChatParticipant _createCurrentUser() {
    return const ChatParticipant(
      id: 'user-me',
      displayName: '我',
      initials: 'ME',
      avatarColorValue: 0xFF6750A4,
      isCurrentUser: true,
    );
  }

  /// 创建客服初始消息
  static List<ChatMessage> _createCustomerServiceMessages(
    ChatParticipant agent,
  ) {
    return [
      ChatMessage(
        id: 'cs-welcome',
        sender: agent,
        body: _CustomerServiceConstants.lastMessagePreview,
        sentAtLabel: _CustomerServiceConstants.lastMessageTimeLabel,
      ),
    ];
  }

  void _openNotificationDetail(BuildContext context, DirectChatPreview notification) {
    // 系统通知进入只读详情页面
    // 这里需要根据通知ID获取对应的消息列表
    // 暂时使用示例数据
    final systemParticipant = ChatParticipant(
      id: notification.id,
      displayName: notification.displayName,
      initials: notification.initials,
      avatarColorValue: notification.avatarColorValue,
    );

    final messages = [
      ChatMessage(
        id: 'sys-1',
        sender: systemParticipant,
        body: notification.lastMessagePreview,
        sentAtLabel: notification.lastMessageTimeLabel,
      ),
    ];

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SystemNotificationDetailPage(
          title: notification.displayName,
          messages: messages,
        ),
      ),
    );
  }

  void _openCustomerService(BuildContext context) {
    // 客服进入正常的聊天页面
    final customerServicePreview = _createCustomerServicePreview();
    final customerServiceAgent = _createCustomerServiceAgent();
    final currentUser = _createCurrentUser();
    final messages = _createCustomerServiceMessages(customerServiceAgent);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatConversationPage.direct(
          preview: customerServicePreview,
          partner: customerServiceAgent,
          currentUser: currentUser,
          initialMessages: messages,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // 合并系统通知和客服条目
    // 客服条目标记为系统通知样式
    final allConversations = <DirectChatPreview>[
      ...notifications,
      _createCustomerServicePreview(isSystem: true),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('通知'),
        backgroundColor: colorScheme.surface,
        surfaceTintColor: colorScheme.surface,
      ),
      body: SafeArea(
        child: allConversations.isEmpty
            ? Center(
                child: Text(
                  '暂时没有系统通知',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            : DirectChatList(
                conversations: allConversations,
                showSectionHeaders: false,
                storageKey: const PageStorageKey('system-notifications-list'),
                onConversationTap: (conversation) {
                  if (conversation.id == _CustomerServiceConstants.id) {
                    _openCustomerService(context);
                  } else {
                    _openNotificationDetail(context, conversation);
                  }
                },
              ),
      ),
    );
  }
}
