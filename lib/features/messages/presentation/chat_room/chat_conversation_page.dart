import 'dart:async';

import 'package:chatview/chatview.dart';
import 'package:crew_app/features/messages/data/chat_message.dart';
import 'package:crew_app/features/messages/data/chat_participant.dart';
import 'package:crew_app/features/messages/data/direct_chat_preview.dart';
import 'package:crew_app/features/messages/presentation/chat_room/chat_room_settings_page.dart';
import 'package:crew_app/features/messages/presentation/chat_room/widgets/chat_attachment_sheet.dart';
import 'package:crew_app/features/messages/presentation/chat_room/widgets/chat_message_search_sheet.dart';
import 'package:crew_app/features/messages/presentation/chat_room/widgets/chat_header_actions.dart';
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
  late final ScrollController _chatScrollController;
  late final Map<String, ChatUser> _chatUsersById;
  late final ChatController _chatController;
  ChatViewState _chatViewState = ChatViewState.loading;
  Timer? _scrollDebounce;

  bool get _isGroup => widget.type == ChatConversationType.group;

  @override
  void initState() {
    super.initState();
    _chatScrollController = ScrollController();
    _messages = List<ChatMessage>.of(widget.initialMessages);
    final participants = _buildParticipants();
    _chatUsersById = {
      for (final participant in participants)
        participant.id: _mapToChatUser(participant),
    };
    final seedTime = DateTime.now();
    _chatController = ChatController(
      initialMessageList: List<Message>.generate(
        _messages.length,
        (index) => _mapToChatViewMessage(
          _messages[index],
          index,
          seedTime,
        ),
        growable: false,
      ),
      currentUser: _chatUsersById[widget.currentUser.id]!,
      scrollController: _chatScrollController,
    );
    _chatViewState =
        _messages.isEmpty ? ChatViewState.noMessages : ChatViewState.hasMessages;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_chatViewState == ChatViewState.hasMessages) {
        _scrollToBottom();
      }
    });
  }

  @override
  void dispose() {
    _scrollDebounce?.cancel();
    _chatController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (!_chatScrollController.hasClients) return;

    _chatScrollController.animateTo(
      _chatScrollController.position.maxScrollExtent + 72,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Future<void> _scrollToMessage(String messageId) async {
    if (!_chatScrollController.hasClients) return;

    final index = _messages.indexWhere((message) => message.id == messageId);
    if (index == -1) return;

    final targetOffset = _estimateScrollOffsetForIndex(index);
    try {
      await _chatScrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } catch (_) {
      // Ignore scroll errors when the controller is no longer attached.
    }
  }

  double _estimateScrollOffsetForIndex(int index) {
    if (!_chatScrollController.hasClients) {
      return 0;
    }

    final position = _chatScrollController.position;
    final maxExtent = position.maxScrollExtent;
    if (maxExtent <= 0 || _messages.length <= 1) {
      return maxExtent;
    }

    final averageExtent = maxExtent / (_messages.length - 1);
    final estimatedOffset = averageExtent * index;
    return estimatedOffset.clamp(0, maxExtent).toDouble();
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

  ChatUser _mapToChatUser(ChatParticipant participant) {
    return ChatUser(
      id: participant.id,
      name: participant.displayName,
    );
  }

  Message _mapToChatViewMessage(
    ChatMessage message,
    int index,
    DateTime seedTime,
  ) {
    final minuteOffset =
        (_messages.length - index).clamp(1, _messages.length) as int;
    final createdAt = seedTime.subtract(Duration(minutes: minuteOffset));
    final senderId = message.sender.id;

    return Message(
      id: message.id,
      message: message.body,
      createdAt: createdAt,
      sendBy: senderId,
      status: message.isFromCurrentUser
          ? MessageStatus.read
          : MessageStatus.delivered,
    );
  }

  void _handleSendTap(String rawMessage, ReplyMessage? _) {
    final trimmed = rawMessage.trim();
    if (trimmed.isEmpty) return;

    final timeLabel = MaterialLocalizations.of(context)
        .formatTimeOfDay(TimeOfDay.fromDateTime(DateTime.now()));

    final prefix = _isGroup ? 'group-temp' : 'direct-temp';
    final newChatMessage = ChatMessage(
      id: '$prefix-${DateTime.now().millisecondsSinceEpoch}',
      sender: widget.currentUser,
      body: trimmed,
      sentAtLabel: timeLabel,
    );

    final message = Message(
      id: newChatMessage.id,
      message: newChatMessage.body,
      createdAt: DateTime.now(),
      sendBy: widget.currentUser.id,
      status: MessageStatus.read,
    );

    setState(() {
      _messages.add(newChatMessage);
      _chatViewState = ChatViewState.hasMessages;
    });

    _chatController.addMessage(message);

    _scrollDebounce?.cancel();
    _scrollDebounce = Timer(const Duration(milliseconds: 160), _scrollToBottom);
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

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: _buildAppBar(loc, colorScheme, participants),
      body: ChatView(
        currentUser: _chatUsersById[widget.currentUser.id]!,
        chatController: _chatController,
        chatViewState: _chatViewState,
        onSendTap: _handleSendTap,
        featureActiveConfig: const FeatureActiveConfig(
          enableSwipeToSeeTime: true,
          enableDoubleTapToLike: false,
        ),
      ),
      floatingActionButton: FloatingActionButton.small(
        onPressed: _showAttachmentSheet,
        tooltip: loc.chat_attachment_more,
        child: const Icon(Icons.add_circle_outline),
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
