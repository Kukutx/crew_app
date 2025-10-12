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

    final voiceAction =
        withFallback(onVoiceCallTap, loc.chat_action_voice_call);
    final videoAction =
        withFallback(onVideoCallTap, loc.chat_action_video_call);
    final phoneAction =
        withFallback(onPhoneCallTap, loc.chat_action_phone_call);

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
        PopupMenuButton<_ChatHeaderAction>(
          tooltip: loc.chat_action_more_options,
          icon: const Icon(Icons.add_circle_outline),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: _ChatHeaderAction.voiceCall,
              child: _HeaderActionRow(
                icon: Icons.mic_none_outlined,
                label: loc.chat_action_voice_call,
              ),
            ),
            PopupMenuItem(
              value: _ChatHeaderAction.phoneCall,
              child: _HeaderActionRow(
                icon: Icons.call_outlined,
                label: loc.chat_action_phone_call,
              ),
            ),
            PopupMenuItem(
              value: _ChatHeaderAction.videoCall,
              child: _HeaderActionRow(
                icon: Icons.videocam_outlined,
                label: loc.chat_action_video_call,
              ),
            ),
          ],
          onSelected: (action) {
            switch (action) {
              case _ChatHeaderAction.voiceCall:
                voiceAction();
                break;
              case _ChatHeaderAction.phoneCall:
                phoneAction();
                break;
              case _ChatHeaderAction.videoCall:
                videoAction();
                break;
            }
          },
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

enum _ChatHeaderAction { voiceCall, phoneCall, videoCall }

class _HeaderActionRow extends StatelessWidget {
  const _HeaderActionRow({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
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
