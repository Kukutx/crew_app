import 'package:crew_app/features/messages/data/chat_message.dart';
import 'package:crew_app/features/messages/data/chat_participant.dart';
import 'package:crew_app/features/messages/presentation/chat_room/chat_room_settings_page.dart';
import 'package:crew_app/features/messages/presentation/chat_room/widgets/chat_attachment_sheet.dart';
import 'package:crew_app/features/messages/presentation/chat_room/widgets/chat_room_app_bar.dart';
import 'package:crew_app/features/messages/presentation/chat_room/widgets/chat_room_message_composer.dart';
import 'package:crew_app/features/messages/presentation/chat_room/widgets/chat_room_message_list.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

class ChatRoomPage extends StatefulWidget {
  const ChatRoomPage({
    super.key,
    required this.channelTitle,
    required this.currentUser,
    required this.participants,
    required this.initialMessages,
  });

  final String channelTitle;
  final ChatParticipant currentUser;
  final List<ChatParticipant> participants;
  final List<ChatMessage> initialMessages;

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
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
          id: 'group-temp-${DateTime.now().millisecondsSinceEpoch}',
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

  void _showFeatureComingSoon(String featureName) {
    final loc = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(loc.chat_action_unavailable(featureName)),
        ),
      );
  }

  Future<void> _showAttachmentSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: false,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (sheetContext) {
        return ChatAttachmentSheet(
          onOptionSelected: (label) {
            Navigator.of(sheetContext).pop();
            _showFeatureComingSoon(label);
          },
        );
      },
    );
  }

  void _openSettings(List<ChatParticipant> participants) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatRoomSettingsPage(
          title: widget.channelTitle,
          isGroup: true,
          participants: participants,
          currentUser: widget.currentUser,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final participants = _buildParticipants();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: ChatRoomAppBar(
        channelTitle: widget.channelTitle,
        participants: participants,
        onOpenSettings: () => _openSettings(participants),
        onSearchTap: () => _showFeatureComingSoon(loc.chat_search_hint),
        onVoiceCallTap: () => _showFeatureComingSoon(loc.chat_action_voice_call),
        onVideoCallTap: () =>
            _showFeatureComingSoon(loc.chat_action_video_call),
        onPhoneCallTap: () =>
            _showFeatureComingSoon(loc.chat_action_phone_call),
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
            onMoreOptionsTap: _showAttachmentSheet,
          ),
        ],
      ),
    );
  }

  List<ChatParticipant> _buildParticipants() {
    return [
      ...widget.participants,
      if (!widget.participants.any(
        (participant) => participant.id == widget.currentUser.id,
      ))
        widget.currentUser,
    ];
  }
}
