import 'package:crew_app/features/messages/data/chat_participant.dart';
import 'package:crew_app/features/messages/presentation/chat_room/widgets/chat_header_actions.dart';
import 'package:crew_app/features/messages/presentation/chat_room/widgets/chat_room_participant_avatar.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

class ChatRoomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ChatRoomAppBar({
    super.key,
    required this.channelTitle,
    required this.participants,
    required this.onOpenSettings,
    this.onSearchTap,
    this.onParticipantTap,
  });

  final String channelTitle;
  final List<ChatParticipant> participants;
  final VoidCallback onOpenSettings;
  final VoidCallback? onSearchTap;
  final ValueChanged<ChatParticipant>? onParticipantTap;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 72);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final loc = AppLocalizations.of(context)!;

    void showUnavailable(String label) {
      final messenger = ScaffoldMessenger.of(context);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(loc.chat_action_unavailable(label)),
          ),
        );
    }

    VoidCallback withFallback(VoidCallback? callback, String label) {
      return callback ?? () => showUnavailable(label);
    }

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
        ChatHeaderActions(
          onSearchTap: withFallback(onSearchTap, loc.chat_search_hint),
          onOpenSettings: onOpenSettings,
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
              return ChatRoomParticipantAvatar(
                participant: participant,
                onTap: onParticipantTap,
              );
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
            fontSize: 18,
            fontWeight: FontWeight.w700,
            height: 1.3,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          membersLabel,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
            height: 1.3,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}
