import 'package:crew_app/features/messages/data/chat_participant.dart';
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
    this.onVoiceCallTap,
    this.onVideoCallTap,
    this.onPhoneCallTap,
  });

  final String channelTitle;
  final List<ChatParticipant> participants;
  final VoidCallback onOpenSettings;
  final VoidCallback? onSearchTap;
  final VoidCallback? onVoiceCallTap;
  final VoidCallback? onVideoCallTap;
  final VoidCallback? onPhoneCallTap;

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
        IconButton(
          tooltip: loc.chat_search_hint,
          icon: const Icon(Icons.search),
          onPressed: withFallback(onSearchTap, loc.chat_search_hint),
        ),
        IconButton(
          tooltip: loc.chat_action_voice_call,
          icon: const Icon(Icons.mic_none_outlined),
          onPressed:
              withFallback(onVoiceCallTap, loc.chat_action_voice_call),
        ),
        IconButton(
          tooltip: loc.chat_action_video_call,
          icon: const Icon(Icons.videocam_outlined),
          onPressed:
              withFallback(onVideoCallTap, loc.chat_action_video_call),
        ),
        IconButton(
          tooltip: loc.chat_action_phone_call,
          icon: const Icon(Icons.call_outlined),
          onPressed:
              withFallback(onPhoneCallTap, loc.chat_action_phone_call),
        ),
        IconButton(
          tooltip: loc.chat_action_open_settings,
          icon: const Icon(Icons.settings_outlined),
          onPressed: onOpenSettings,
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
              return ChatRoomParticipantAvatar(participant: participant);
            },
            separatorBuilder: (_, __) => const SizedBox(width: 12),
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
