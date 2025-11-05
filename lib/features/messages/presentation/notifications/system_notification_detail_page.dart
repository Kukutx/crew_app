import 'package:crew_app/features/messages/data/chat_message.dart';
import 'package:crew_app/features/messages/presentation/chat_room/widgets/chat_room_message_list.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

class SystemNotificationDetailPage extends StatefulWidget {
  const SystemNotificationDetailPage({
    super.key,
    required this.title,
    required this.messages,
  });

  final String title;
  final List<ChatMessage> messages;

  @override
  State<SystemNotificationDetailPage> createState() => _SystemNotificationDetailPageState();
}

class _SystemNotificationDetailPageState extends State<SystemNotificationDetailPage> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Expanded(
            child: ChatRoomMessageList(
              messages: widget.messages,
              scrollController: _scrollController,
              youLabel: loc.chat_you_label,
              repliesLabelBuilder: loc.chat_reply_count,
              messageKeys: {},
              highlightedMessageId: null,
              onAvatarTap: null,
            ),
          ),
        ],
      ),
    );
  }
}

