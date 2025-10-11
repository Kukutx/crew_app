import 'package:crew_app/features/messages/data/chat_message.dart';
import 'package:crew_app/features/messages/data/chat_participant.dart';
import 'package:crew_app/features/messages/data/direct_chat_preview.dart';
import 'package:crew_app/features/messages/presentation/chat_room/widgets/chat_room_message_composer.dart';
import 'package:crew_app/features/messages/presentation/chat_room/widgets/chat_room_message_list.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

class DirectChatPage extends StatefulWidget {
  const DirectChatPage({
    super.key,
    required this.preview,
    required this.partner,
    required this.currentUser,
    required this.initialMessages,
  });

  final DirectChatPreview preview;
  final ChatParticipant partner;
  final ChatParticipant currentUser;
  final List<ChatMessage> initialMessages;

  @override
  State<DirectChatPage> createState() => _DirectChatPageState();
}

class _DirectChatPageState extends State<DirectChatPage> {
  late final TextEditingController _composerController;
  late final ScrollController _scrollController;
  late final List<ChatMessage> _messages;

  @override
  void initState() {
    super.initState();
    _composerController = TextEditingController();
    _scrollController = ScrollController();
    _messages = List<ChatMessage>.of(widget.initialMessages);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    _composerController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleSend() {
    final raw = _composerController.text.trim();
    if (raw.isEmpty) return;

    final timeLabel = MaterialLocalizations.of(context)
        .formatTimeOfDay(TimeOfDay.fromDateTime(DateTime.now()));

    setState(() {
      _messages.add(
        ChatMessage(
          id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
          sender: widget.currentUser,
          body: raw,
          sentAtLabel: timeLabel,
        ),
      );
    });
    _composerController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;

    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent + 72,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final avatarColor = Color(
      widget.preview.avatarColorValue ??
          widget.partner.avatarColorValue ??
          colorScheme.primary.toARGB32(),
    );
    final partnerInitials = (widget.partner.initials ??
            widget.partner.displayName.characters.take(2).toString())
        .toUpperCase();
    final statusText = widget.preview.isActive
        ? loc.chat_status_online
        : loc.chat_last_seen(widget.preview.lastMessageTimeLabel);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: avatarColor.withValues(alpha: .15),
              child: Text(
                partnerInitials,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: avatarColor,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.preview.displayName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ChatRoomMessageList(
              messages: _messages,
              scrollController: _scrollController,
              youLabel: loc.chat_you_label,
              repliesLabelBuilder: loc.chat_reply_count,
            ),
          ),
          ChatRoomMessageComposer(
            controller: _composerController,
            hintText: loc.chat_message_input_hint,
            onSend: _handleSend,
          ),
        ],
      ),
    );
  }
}
