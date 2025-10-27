import 'package:crew_app/features/messages/data/direct_chat_preview.dart';
import 'package:crew_app/features/messages/presentation/messages_chat/widgets/direct_chat_list.dart';
import 'package:flutter/material.dart';

class SystemNotificationsPage extends StatelessWidget {
  const SystemNotificationsPage({
    super.key,
    required this.notifications,
  });

  final List<DirectChatPreview> notifications;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('系统通知'),
        backgroundColor: colorScheme.surface,
        surfaceTintColor: colorScheme.surface,
      ),
      body: SafeArea(
        child: notifications.isEmpty
            ? Center(
                child: Text(
                  '暂时没有系统通知',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            : DirectChatList(
                conversations: notifications,
                showSectionHeaders: false,
                storageKey: const PageStorageKey('system-notifications-list'),
              ),
      ),
    );
  }
}
