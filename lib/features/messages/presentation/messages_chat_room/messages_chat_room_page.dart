
import 'package:crew_app/features/messages/data/messages_chat_message.dart';
import 'package:crew_app/features/messages/data/messages_chat_participant.dart';
import 'package:crew_app/features/messages/presentation/messages_chat_room/widgets/messages_chat_room_app_bar.dart';
import 'package:crew_app/features/messages/presentation/messages_chat_room/widgets/messages_chat_room_message_composer.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

import 'widgets/messages_chat_room_message_list.dart';

class MessagesChatRoomPage extends StatefulWidget {
  const MessagesChatRoomPage({
    super.key,
    required this.channelTitle,
    required this.currentUser,
    required this.participants,
    required this.initialMessages,
  });

  final String channelTitle;
  final MessagesChatParticipant currentUser;
  final List<MessagesChatParticipant> participants;
  final List<MessagesChatMessage> initialMessages;

  @override
  State<MessagesChatRoomPage> createState() => _MessagesChatRoomPageState();
}

class _MessagesChatRoomPageState extends State<MessagesChatRoomPage> {
  late final TextEditingController _composerController;
  late final ScrollController _scrollController;
  late final List<MessagesChatMessage> _messages;

  @override
  void initState() {
    super.initState();
    _composerController = TextEditingController();
    _scrollController = ScrollController();
    _messages = List<MessagesChatMessage>.of(widget.initialMessages);
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
        MessagesChatMessage(
          sender: widget.currentUser,
          content: raw,
          timeLabel: timeLabel,
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
    final participants = _buildParticipants();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: MessagesChatRoomAppBar(
        channelTitle: widget.channelTitle,
        participants: participants,
      ),
      body: Column(
        children: [
          Expanded(
            child: MessagesChatRoomMessageList(
              messages: _messages,
              scrollController: _scrollController,
              youLabel: loc.chat_you_label,
              repliesLabelBuilder: loc.chat_reply_count,
            ),
          ),
          MessagesChatRoomMessageComposer(
            controller: _composerController,
            hintText: loc.chat_message_input_hint,
            onSend: _handleSend,
          ),
        ],
      ),
    );
  }

  List<MessagesChatParticipant> _buildParticipants() {
    return [
      ...widget.participants,
      if (!widget.participants
          .any((participant) => participant.name == widget.currentUser.name))
        widget.currentUser,
    ];
  }
}
