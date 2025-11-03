import 'package:chatview/chatview.dart';
import 'package:crew_app/features/messages/data/chat_message.dart';
import 'package:crew_app/features/messages/data/chat_participant.dart';
import 'package:crew_app/features/messages/data/direct_chat_preview.dart';
import 'package:crew_app/features/messages/presentation/chat_room/chat_room_settings_page.dart';
import 'package:crew_app/features/messages/presentation/chat_room/widgets/chat_attachment_sheet.dart';
import 'package:crew_app/features/messages/presentation/chat_room/widgets/chat_header_actions.dart';
import 'package:crew_app/features/messages/presentation/chat_room/widgets/chat_message_search_sheet.dart';
import 'package:crew_app/features/messages/presentation/chat_room/widgets/chat_room_app_bar.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:crew_app/features/user/presentation/pages/user_profile/user_profile_page.dart';
import 'package:crew_app/shared/widgets/crew_avatar.dart';
import 'package:flutter/material.dart';

enum ChatConversationType { group, direct }

class ChatConversationPage extends StatefulWidget {
  ChatConversationPage.group({
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

  ChatConversationPage.direct({
    super.key,
    required this.preview,
    required this.partner,
    required this.currentUser,
    required this.initialMessages,
  })  : type = ChatConversationType.direct,
        title = preview?.displayName ?? '',
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
  late final List<ChatMessage> _messages;
  late final Map<String, DateTime> _messageTimestamps;
  late final Map<String, ChatUser> _chatUsersById;
  late final ChatUser _currentChatUser;
  late final ChatController _chatController;
  late final ScrollController _chatScrollController;
  late final List<Message> _chatMessages;

  bool get _isGroup => widget.type == ChatConversationType.group;

  @override
  void initState() {
    super.initState();
    _messages = List<ChatMessage>.of(widget.initialMessages);
    _messageTimestamps = <String, DateTime>{};
    _initializeChatViewController();
  }

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  void _initializeChatViewController() {
    final participants = _buildParticipants();
    _chatUsersById = {
      for (final participant in participants)
        participant.id: _toChatUser(participant),
    };
    _currentChatUser =
        _chatUsersById[widget.currentUser.id] ?? _toChatUser(widget.currentUser);

    _chatMessages = _messages
        .map(
          (chatMessage) => _toChatViewMessage(
            chatMessage,
            createdAt: _resolveTimestamp(chatMessage),
          ),
        )
        .toList(growable: true);

    _chatController = ChatController(
      initialMessageList: _chatMessages,
      initialChatUsers: _chatUsersById.values.toList(growable: false),
    );
    _chatScrollController = _chatController.scrollController;
  }

  void _handleSend(
    String raw,
    ReplyMessage reply,
    MessageType messageType,
  ) {
    final text = raw.trim();
    final isTextMessage = messageType == MessageType.text;
    if (isTextMessage && text.isEmpty) return;

    final timeLabel = MaterialLocalizations.of(context)
        .formatTimeOfDay(TimeOfDay.fromDateTime(DateTime.now()));
    final prefix = _isGroup ? 'group-temp' : 'direct-temp';
    final createdAt = DateTime.now();

    final newMessage = ChatMessage(
      id: '$prefix-${DateTime.now().millisecondsSinceEpoch}',
      sender: widget.currentUser,
      body: isTextMessage ? raw : text,
      sentAtLabel: timeLabel,
    );

    setState(() {
      _messages.add(newMessage);
      _messageTimestamps[newMessage.id] = createdAt;
    });
    final chatMessage = _toChatViewMessage(
      newMessage,
      createdAt: createdAt,
      reply: reply,
      messageType: messageType,
    );
    _chatMessages.add(chatMessage);
    _chatController.addMessage(chatMessage);
    _scrollToLatestMessage();
  }

  Future<void> _scrollToMessage(String messageId) async {
    if (!_chatScrollController.hasClients) return;

    final index = _chatMessages.indexWhere((message) => message.id == messageId);
    if (index == -1) return;

    final maxExtent = _chatScrollController.position.maxScrollExtent;
    final estimatedOffset =
        maxExtent * (index / (_chatMessages.length + 1));

    await _chatScrollController.animateTo(
      estimatedOffset,
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

  void _openUserProfile(ChatParticipant participant) {
    if (participant.isCurrentUser) {
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => UserProfilePage(uid: participant.id),
      ),
    );
  }

  Future<void> _showSearchSheet() async {
    final selectedMessage = await showModalBottomSheet<ChatMessage>(
      context: context,
      isScrollControlled: true,
      showDragHandle: false,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (sheetContext) {
        return ChatMessageSearchSheet(
          messages: List<ChatMessage>.of(_messages.reversed),
          onMessageSelected: (message) {
            Navigator.of(sheetContext).pop(message);
          },
        );
      },
    );

    if (selectedMessage == null) return;

    await _scrollToMessage(selectedMessage.id);
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
        onSearchTap: _showSearchSheet,
        onVideoCallTap: () =>
            _showFeatureComingSoon(loc.chat_action_video_call),
        onParticipantTap: _openUserProfile,
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
          InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => _openUserProfile(partner),
            child: CrewAvatar(
              radius: 22,
              backgroundColor: avatarColor.withValues(alpha: .15),
              foregroundColor: avatarColor,
              child: Text(
                partnerInitials,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
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
          onSearchTap: _showSearchSheet,
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

    final chatViewState = _chatMessages.isEmpty
        ? ChatViewState.noData
        : ChatViewState.hasMessages;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: _buildAppBar(loc, colorScheme, participants),
      body: ChatView(
        currentUser: _currentChatUser,
        chatController: _chatController,
        chatViewState: chatViewState,
        type: ChatViewType.light,
        onSendTap: _handleSend,
        messageBarConfig: MessageBarConfiguration(
          sendButtonIcon: const Icon(Icons.send_rounded),
          hintText: loc.chat_message_input_hint,
          actions: [
            IconButton(
              tooltip: loc.chat_action_more,
              onPressed: _showAttachmentSheet,
              icon: const Icon(Icons.attach_file_rounded),
            ),
          ],
        ),
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

  Message _toChatViewMessage(
    ChatMessage chatMessage, {
    DateTime? createdAt,
    ReplyMessage reply = const ReplyMessage(),
    MessageType messageType = MessageType.text,
  }) {
    final timestamp = createdAt ?? _resolveTimestamp(chatMessage);

    return Message(
      id: chatMessage.id,
      message: chatMessage.body,
      createdAt: timestamp,
      sendBy: chatMessage.sender.id,
      messageType: messageType,
      replyMessage: reply,
    );
  }

  DateTime _resolveTimestamp(ChatMessage message) {
    final existing = _messageTimestamps[message.id];
    if (existing != null) {
      return existing;
    }

    final baseTime = DateTime.now();
    final index = _messages.indexOf(message);
    final resolved =
        baseTime.subtract(Duration(minutes: (_messages.length - index) * 3));
    _messageTimestamps[message.id] = resolved;
    return resolved;
  }

  ChatUser _toChatUser(ChatParticipant participant) {
    return ChatUser(
      id: participant.id,
      name: participant.displayName,
    );
  }

  void _scrollToLatestMessage() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_chatScrollController.hasClients) return;
      _chatScrollController.animateTo(
        _chatScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }
}
