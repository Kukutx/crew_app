import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

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
    final cs = Theme.of(context).colorScheme;
    final participants = [
      ...widget.participants,
      if (!widget.participants
          .any((element) => element.name == widget.currentUser.name))
        widget.currentUser,
    ];

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.channelTitle,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              loc.chat_members_count(participants.length),
              style: TextStyle(
                fontSize: 13,
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(72),
          child: SizedBox(
            height: 72,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final participant = participants[index];
                return _ParticipantAvatar(participant: participant);
              },
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemCount: participants.length,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: cs.surfaceContainerLowest,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.only(bottom: 24, top: 16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final bool showAvatar = index == 0
                      ? true
                      : !_messages[index - 1]
                          .isFromSameSender(_messages[index]);
                  return _GroupMessageTile(
                    message: msg,
                    showAvatar: showAvatar,
                    youLabel: loc.chat_you_label,
                    repliesLabelBuilder: (count) => loc.chat_reply_count(count),
                  );
                },
              ),
            ),
          ),
          _MessageComposer(
            controller: _composerController,
            hintText: loc.chat_message_input_hint,
            onSend: _handleSend,
          ),
        ],
      ),
    );
  }
}

class GroupParticipant {
  const GroupParticipant({
    required this.name,
    required this.initials,
    required this.avatarColor,
    this.isSelf = false,
  });

  final String name;
  final String initials;
  final Color avatarColor;
  final bool isSelf;
}

class GroupMessage {
  const GroupMessage({
    required this.sender,
    required this.content,
    required this.timeLabel,
    this.replyCount,
    this.replyPreview,
    this.attachmentChips = const <String>[],
  });

  final GroupParticipant sender;
  final String content;
  final String timeLabel;
  final int? replyCount;
  final String? replyPreview;
  final List<String> attachmentChips;

  bool get isMine => sender.isSelf;

  bool isFromSameSender(GroupMessage other) => sender.name == other.sender.name;
}

class _ParticipantAvatar extends StatelessWidget {
  const _ParticipantAvatar({required this.participant});

  final GroupParticipant participant;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final borderColor = participant.isSelf ? cs.primary : cs.surface;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: borderColor, width: participant.isSelf ? 2 : 1),
          ),
          child: CircleAvatar(
            radius: 20,
            backgroundColor: participant.avatarColor.withValues(alpha: .12),
            child: Text(
              participant.initials,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: participant.avatarColor,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 64,
          child: Text(
            participant.isSelf ? AppLocalizations.of(context)!.chat_you_label : participant.name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class _GroupMessageTile extends StatelessWidget {
  const _GroupMessageTile({
    required this.message,
    required this.showAvatar,
    required this.youLabel,
    required this.repliesLabelBuilder,
  });

  final GroupMessage message;
  final bool showAvatar;
  final String youLabel;
  final String Function(int) repliesLabelBuilder;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isMine = message.isMine;
    final bubbleColor = isMine ? cs.primary : cs.surface;
    final textColor = isMine ? cs.onPrimary : cs.onSurface;
    final captionColor = isMine ? cs.onPrimary.withValues(alpha: .8) : cs.onSurfaceVariant;

    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: isMine ? 80 : 16,
        end: isMine ? 16 : 80,
        top: 6,
        bottom: 6,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMine)
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: showAvatar ? 1 : 0,
              child: showAvatar
                  ? CircleAvatar(
                      radius: 18,
                      backgroundColor: message.sender.avatarColor.withValues(alpha: .15),
                      child: Text(
                        message.sender.initials,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: message.sender.avatarColor,
                        ),
                      ),
                    )
                  : const SizedBox(width: 36),
            )
          else
            const SizedBox(width: 36),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  isMine ? '$youLabel · ${message.timeLabel}' : '${message.sender.name} · ${message.timeLabel}',
                  style: TextStyle(
                    fontSize: 12,
                    color: captionColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(isMine ? 20 : 8),
                      bottomRight: Radius.circular(isMine ? 8 : 20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: cs.shadow.withValues(alpha:.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment:
                        isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.content,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.4,
                          color: textColor,
                        ),
                      ),
                      if (message.attachmentChips.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: message.attachmentChips
                              .map(
                                (chip) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isMine
                                        ? cs.onPrimary.withValues(alpha:.12)
                                        : cs.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.insert_drive_file_outlined,
                                        size: 14,
                                        color: textColor.withValues(alpha:.85),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        chip,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: textColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                ),
                if (message.replyCount != null && message.replyCount! > 0)
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest.withValues(alpha:.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.reply_all, size: 16, color: cs.primary),
                        const SizedBox(width: 6),
                        Text(
                          message.replyPreview ?? repliesLabelBuilder(message.replyCount!),
                          style: TextStyle(
                            fontSize: 12,
                            color: cs.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (isMine)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Icon(
                      Icons.done_all,
                      size: 16,
                      color: cs.primary,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageComposer extends StatelessWidget {
  const _MessageComposer({
    required this.controller,
    required this.hintText,
    required this.onSend,
  });

  final TextEditingController controller;
  final String hintText;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: cs.shadow.withValues(alpha:.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              IconButton(
                tooltip: 'emoji',
                icon: Icon(Icons.emoji_emotions_outlined, color: cs.primary),
                onPressed: () {},
              ),
              IconButton(
                tooltip: 'attach',
                icon: Icon(Icons.attach_file, color: cs.primary),
                onPressed: () {},
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  minLines: 1,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: hintText,
                  ),
                  onSubmitted: (_) => onSend(),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: cs.primary,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(Icons.send_rounded, color: cs.onPrimary),
                  onPressed: onSend,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
