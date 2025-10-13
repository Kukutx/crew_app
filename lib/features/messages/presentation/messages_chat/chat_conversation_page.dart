import 'package:crew_app/features/messages/data/chat_message.dart';
import 'package:crew_app/features/messages/data/chat_participant.dart';
import 'package:crew_app/features/messages/data/direct_chat_preview.dart';
import 'package:crew_app/features/messages/presentation/chat_room/chat_room_settings_page.dart';
import 'package:crew_app/features/messages/presentation/chat_room/widgets/chat_attachment_sheet.dart';
import 'package:crew_app/features/messages/presentation/chat_room/widgets/chat_header_actions.dart';
import 'package:crew_app/features/messages/presentation/chat_room/widgets/chat_room_app_bar.dart';
import 'package:crew_app/features/messages/presentation/chat_room/widgets/chat_room_message_composer.dart';
import 'package:crew_app/features/messages/presentation/chat_room/widgets/chat_room_message_list.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

enum ChatConversationType { group, direct }

class ChatConversationPage extends StatefulWidget {
  const ChatConversationPage.group({
    super.key,
    required String channelTitle,
    required this.currentUser,
    required List<ChatParticipant> participants,
    required this.initialMessages,
  })  : type = ChatConversationType.group,
        title = channelTitle,
        participants = List<ChatParticipant>.unmodifiable(participants),
        preview = null,
        partner = null;

  const ChatConversationPage.direct({
    super.key,
    required this.preview,
    required this.partner,
    required this.currentUser,
    required this.initialMessages,
  })  : type = ChatConversationType.direct,
        title = preview.displayName,
        participants = List<ChatParticipant>.unmodifiable(
          [partner, currentUser],
        );

  final ChatConversationType type;
  final String title;
  final ChatParticipant currentUser;
  final List<ChatParticipant> participants;
  final List<ChatMessage> initialMessages;
  final DirectChatPreview? preview;
  final ChatParticipant? partner;

  @override
  State<ChatConversationPage> createState() => _ChatConversationPageState();
}

class _ChatConversationPageState extends State<ChatConversationPage> {
  late final TextEditingController _composerController;
  late final ScrollController _scrollController;
  late final List<ChatMessage> _messages;

  bool get _isGroup => widget.type == ChatConversationType.group;

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

    final prefix = _isGroup ? 'group-temp' : 'direct-temp';

    setState(() {
      _messages.add(
        ChatMessage(
          id: '$prefix-${DateTime.now().millisecondsSinceEpoch}',
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
          title: widget.title,
          isGroup: _isGroup,
          participants: participants,
          currentUser: widget.currentUser,
          partner: widget.partner,
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    AppLocalizations loc,
    ColorScheme colorScheme,
    List<ChatParticipant> participants,
  ) {
    if (_isGroup) {
      return ChatRoomAppBar(
        channelTitle: widget.title,
        participants: participants,
        onOpenSettings: () => _openSettings(participants),
        onSearchTap: () => _showFeatureComingSoon(loc.chat_search_hint),
        onVideoCallTap: () =>
            _showFeatureComingSoon(loc.chat_action_video_call),
      );
    }

    final partner = widget.partner;
    final preview = widget.preview;

    if (partner == null || preview == null) {
      return AppBar(title: Text(widget.title));
    }

    final avatarColor = Color(
      preview.avatarColorValue ??
          partner.avatarColorValue ??
          colorScheme.primary.toARGB32(),
    );

    final partnerInitials =
        (partner.initials ?? partner.displayName.characters.take(2).toString())
            .toUpperCase();

    final statusText = preview.isActive
        ? loc.chat_status_online
        : loc.chat_last_seen(preview.lastMessageTimeLabel);

    return AppBar(
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
                  widget.title,
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
        ChatHeaderActions(
          onPhoneCallTap: () =>
              _showFeatureComingSoon(loc.chat_action_phone_call),
          onVideoCallTap: () =>
              _showFeatureComingSoon(loc.chat_action_video_call),
          onOpenSettings: () => _openSettings(participants),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final participants = _buildParticipants();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: _buildAppBar(loc, colorScheme, participants),
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
    final participants = List<ChatParticipant>.of(widget.participants);
    final hasCurrentUser = participants.any(
      (participant) => participant.id == widget.currentUser.id,
    );

    if (!hasCurrentUser) {
      participants.add(widget.currentUser);
    }

    return participants;
  }
}
