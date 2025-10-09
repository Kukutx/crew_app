import 'package:crew_app/features/messages/data/messages_chat_participant.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'messages_chat_room_participant_avatar.dart';

class MessagesChatRoomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MessagesChatRoomAppBar({
    super.key,
    required this.channelTitle,
    required this.participants,
  });

  final String channelTitle;
  final List<GroupParticipant> participants;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 72);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final loc = AppLocalizations.of(context)!;

    return AppBar(
      elevation: 0,
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      titleSpacing: 16,
      title: _AppBarTitle(
        channelTitle: channelTitle,
        membersLabel: loc.chat_members_count(participants.length),
        color: colorScheme.onSurfaceVariant,
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
        preferredSize: const Size.fromHeight(84),
        child: SizedBox(
          height: 84,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              final participant = participants[index];
              return MessagesChatRoomParticipantAvatar(participant: participant);
            },
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemCount: participants.length,
          ),
        ),
      ),
    );
  }
}

class _AppBarTitle extends StatelessWidget {
  const _AppBarTitle({
    required this.channelTitle,
    required this.membersLabel,
    required this.color,
  });

  final String channelTitle;
  final String membersLabel;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          channelTitle,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          membersLabel,
          style: TextStyle(
            fontSize: 13,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
