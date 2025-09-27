import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

import '../data/models/group_message.dart';
import '../data/models/group_participant.dart';
import 'widgets/group_chat_app_bar.dart';
import 'widgets/group_chat_message_composer.dart';
import 'widgets/group_chat_message_list.dart';

class GroupChatPage extends StatefulWidget {
  const GroupChatPage({
    super.key,
    required this.channelTitle,
    required this.currentUser,
    required this.participants,
    required this.initialMessages,
  });

  final String channelTitle;
  final GroupParticipant currentUser;
  final List<GroupParticipant> participants;
  final List<GroupMessage> initialMessages;

  @override
  State<GroupChatPage> createState() => _GroupChatPageState();
}

class _GroupChatPageState extends State<GroupChatPage> {
  late final TextEditingController _composerController;
  late final ScrollController _scrollController;
  late final List<GroupMessage> _messages;

  @override
  void initState() {
    super.initState();
    _composerController = TextEditingController();
    _scrollController = ScrollController();
    _messages = List<GroupMessage>.of(widget.initialMessages);
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
        GroupMessage(
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
      appBar: GroupChatAppBar(
        channelTitle: widget.channelTitle,
        participants: participants,
      ),
      body: Column(
        children: [
          Expanded(
            child: GroupChatMessageList(
              messages: _messages,
              scrollController: _scrollController,
              youLabel: loc.chat_you_label,
              repliesLabelBuilder: loc.chat_reply_count,
            ),
          ),
          GroupChatMessageComposer(
            controller: _composerController,
            hintText: loc.chat_message_input_hint,
            onSend: _handleSend,
          ),
        ],
      ),
    );
  }

  List<GroupParticipant> _buildParticipants() {
    return [
      ...widget.participants,
      if (!widget.participants
          .any((participant) => participant.name == widget.currentUser.name))
        widget.currentUser,
    ];
  }
}
