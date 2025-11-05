import 'dart:async';

import 'package:crew_app/features/messages/data/chat_message.dart';
import 'package:crew_app/features/messages/data/chat_participant.dart';
import 'package:crew_app/features/messages/data/direct_chat_preview.dart';
import 'package:crew_app/features/messages/presentation/chat_room/pages/chat_room_settings_page.dart';
import 'package:crew_app/features/messages/presentation/chat_room/widgets/chat_attachment_sheet.dart';
import 'package:crew_app/features/messages/presentation/chat_room/widgets/chat_message_search_sheet.dart';
import 'package:crew_app/features/messages/presentation/chat_room/widgets/chat_header_actions.dart';
import 'package:crew_app/features/messages/presentation/chat_room/widgets/chat_room_app_bar.dart';
import 'package:crew_app/features/messages/presentation/chat_room/widgets/chat_room_message_composer.dart';
import 'package:crew_app/features/messages/presentation/chat_room/widgets/chat_room_message_list.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:crew_app/features/user/presentation/pages/user_profile/user_profile_page.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:crew_app/shared/widgets/crew_avatar.dart';
import 'package:flutter/material.dart';

enum ChatConversationType { group, direct }

/// 聊天页面相关常量
class _ChatConversationConstants {
  // 滚动相关常量
  static const double scrollOffsetPadding = 72.0;
  static const int scrollAnimationDurationMs = 300;
  static const int scrollDelayMs = 16;
  
  // 高亮相关常量
  static const int highlightDurationSeconds = 2;
  
  // Emoji 选择器相关常量
  static const double emojiPickerHeight = 320.0;
}

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
  late final TextEditingController _composerController;
  late final ScrollController _scrollController;
  late final FocusNode _composerFocusNode;
  late final List<ChatMessage> _messages;
  final Map<String, GlobalKey> _messageKeys = <String, GlobalKey>{};
  String? _highlightedMessageId;
  Timer? _highlightTimer;
  bool _isEmojiPickerVisible = false;

  bool get _isGroup => widget.type == ChatConversationType.group;

  @override
  void initState() {
    super.initState();
    _composerController = TextEditingController();
    _scrollController = ScrollController();
    _composerFocusNode = FocusNode();
    _messages = List<ChatMessage>.of(widget.initialMessages);
    _ensureMessageKeys();
    _composerFocusNode.addListener(() {
      if (_composerFocusNode.hasFocus && _isEmojiPickerVisible) {
        setState(() => _isEmojiPickerVisible = false);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    _highlightTimer?.cancel();
    _composerController.dispose();
    _scrollController.dispose();
    _composerFocusNode.dispose();
    super.dispose();
  }

  void _handleSend() {
    final raw = _composerController.text.trim();
    if (raw.isEmpty) return;

    final timeLabel = MaterialLocalizations.of(context)
        .formatTimeOfDay(TimeOfDay.fromDateTime(DateTime.now()));

    final prefix = _isGroup ? 'group-temp' : 'direct-temp';

    final newMessage = ChatMessage(
      id: '$prefix-${DateTime.now().millisecondsSinceEpoch}',
      sender: widget.currentUser,
      body: raw,
      sentAtLabel: timeLabel,
    );

    setState(() {
      _messages.add(newMessage);
      _messageKeys[newMessage.id] = GlobalKey();
      _isEmojiPickerVisible = false;
    });
    _composerController.clear();
    _scrollToBottom();
  }

  void _toggleEmojiPicker() {
    setState(() {
      _isEmojiPickerVisible = !_isEmojiPickerVisible;
    });

    if (_isEmojiPickerVisible) {
      FocusScope.of(context).unfocus();
    } else {
      _composerFocusNode.requestFocus();
    }
  }

  void _hideEmojiPicker() {
    if (!_isEmojiPickerVisible) return;
    setState(() => _isEmojiPickerVisible = false);
  }

  void _handleEmojiSelected(Category? category, Emoji emoji) {
    final text = _composerController.text;
    final selection = _composerController.selection;
    final start = selection.start >= 0 ? selection.start : text.length;
    final end = selection.end >= 0 ? selection.end : start;

    final newText = text.replaceRange(start, end, emoji.emoji);
    final newSelectionIndex = start + emoji.emoji.length;

    _composerController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newSelectionIndex),
    );
  }

  void _handleBackspacePressed() {
    final text = _composerController.text;
    final selection = _composerController.selection;
    final start = selection.start >= 0 ? selection.start : text.length;
    final end = selection.end >= 0 ? selection.end : start;

    if (start != end) {
      final newText = text.replaceRange(start, end, '');
      _composerController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: start),
      );
      return;
    }

    if (start <= 0) {
      return;
    }

    final prefix = text.substring(0, start);
    final trimmedPrefix = prefix.characters.skipLast(1).toString();
    final suffix = text.substring(start);
    final newText = trimmedPrefix + suffix;
    _composerController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: trimmedPrefix.length),
    );
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;

    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent + _ChatConversationConstants.scrollOffsetPadding,
      duration: const Duration(milliseconds: _ChatConversationConstants.scrollAnimationDurationMs),
      curve: Curves.easeOut,
    );
  }

  void _ensureMessageKeys() {
    for (final message in _messages) {
      _messageKeys.putIfAbsent(message.id, () => GlobalKey());
    }
  }

  Future<void> _scrollToMessage(String messageId) async {
    if (!_scrollController.hasClients) return;

    final key = _messageKeys[messageId];
    final index = _messages.indexWhere((message) => message.id == messageId);
    if (index == -1) return;

    if (key?.currentContext == null) {
      final targetOffset = _estimateScrollOffsetForIndex(index);
      try {
        await _scrollController.animateTo(
          targetOffset,
          duration: const Duration(milliseconds: _ChatConversationConstants.scrollAnimationDurationMs),
          curve: Curves.easeOut,
        );
      } catch (_) {
        // Ignore scroll errors when the controller is no longer attached.
      }
      await Future<void>.delayed(const Duration(milliseconds: _ChatConversationConstants.scrollDelayMs));
    }

    final context = key?.currentContext;
    if (context != null) {
      await Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: _ChatConversationConstants.scrollAnimationDurationMs),
        alignment: 0.1,
        curve: Curves.easeOut,
      );
    }
  }

  double _estimateScrollOffsetForIndex(int index) {
    if (!_scrollController.hasClients) {
      return 0;
    }

    final position = _scrollController.position;
    final maxExtent = position.maxScrollExtent;
    if (maxExtent <= 0 || _messages.length <= 1) {
      return maxExtent;
    }

    final averageExtent = maxExtent / (_messages.length - 1);
    final estimatedOffset = averageExtent * index;
    return estimatedOffset.clamp(0, maxExtent).toDouble();
  }

  void _highlightMessage(String messageId) {
    _highlightTimer?.cancel();
    setState(() => _highlightedMessageId = messageId);
    _highlightTimer = Timer(const Duration(seconds: _ChatConversationConstants.highlightDurationSeconds), () {
      if (!mounted) return;
      if (_highlightedMessageId == messageId) {
        setState(() => _highlightedMessageId = null);
      }
    });
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

    _highlightMessage(selectedMessage.id);
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
        onParticipantTap: _openUserProfile,
      );
    }

    final partner = widget.partner;
    final preview = widget.preview;

    if (partner == null || preview == null) {
      return AppBar(title: Text(widget.title));
    }

    // 如果是客服聊天，完全使用固定的客服信息（头像和名称）
    final isCustomerService = _isCustomerService();
    
    // 客服聊天时，固定使用客服的头像和名称
    final String displayName;
    final Color? avatarBackgroundColor;
    final Color? avatarForegroundColor;
    
    if (isCustomerService) {
      // 客服固定信息，使用与通知页相同的颜色方案
      displayName = '客服';
      avatarBackgroundColor = colorScheme.secondaryContainer;
      avatarForegroundColor = colorScheme.onSecondaryContainer;
    } else {
      // 非客服聊天，使用 partner 的信息
      displayName = widget.title;
      final avatarColorValue = preview.avatarColorValue ??
          partner.avatarColorValue ??
          colorScheme.primary.toARGB32();
      final avatarColor = Color(avatarColorValue);
      avatarBackgroundColor = avatarColor.withValues(alpha: .15);
      avatarForegroundColor = avatarColor;
    }

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
              backgroundColor: avatarBackgroundColor,
              foregroundColor: avatarForegroundColor,
              child: isCustomerService
                  ? const Icon(Icons.support_agent_outlined)
                  : Text(
                      (partner.initials ?? partner.displayName.characters.take(2).toString())
                          .toUpperCase(),
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
                  displayName,
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
              messageKeys: _messageKeys,
              highlightedMessageId: _highlightedMessageId,
              onAvatarTap: _openUserProfile,
            ),
          ),
          ChatRoomMessageComposer(
            controller: _composerController,
            hintText: loc.chat_message_input_hint,
            onSend: _handleSend,
            onMoreOptionsTap: _showAttachmentSheet,
            onEmojiTap: _toggleEmojiPicker,
            focusNode: _composerFocusNode,
            onTextFieldTap: _hideEmojiPicker,
            isEmojiPickerVisible: _isEmojiPickerVisible,
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: _isEmojiPickerVisible
                ? SizedBox(
                    key: const ValueKey('emoji_picker'),
                    height: _ChatConversationConstants.emojiPickerHeight,
                  child: EmojiPicker(
                    onEmojiSelected: _handleEmojiSelected,
                    onBackspacePressed: _handleBackspacePressed,
                    config: const Config(),
                  ),
                )
                : const SizedBox.shrink(),
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

  /// 判断是否为客服聊天
  bool _isCustomerService() {
    final partner = widget.partner;
    final preview = widget.preview;
    return partner?.id == 'customer-service-agent' ||
        preview?.id == 'customer-service';
  }
}
