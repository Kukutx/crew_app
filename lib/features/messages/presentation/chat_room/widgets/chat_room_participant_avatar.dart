import 'package:crew_app/features/messages/data/chat_participant.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:crew_app/shared/widgets/crew_avatar.dart';
import 'package:flutter/material.dart';

class ChatRoomParticipantAvatar extends StatelessWidget {
  const ChatRoomParticipantAvatar({
    super.key,
    required this.participant,
    this.onTap,
  });

  final ChatParticipant participant;
  final ValueChanged<ChatParticipant>? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final borderColor =
        participant.isCurrentUser ? colorScheme.primary : colorScheme.surface;
    final avatarColor = Color(
      participant.avatarColorValue ?? colorScheme.primary.toARGB32(),
    );
    final initials = (participant.initials ??
            participant.displayName.characters.take(2).toString())
        .toUpperCase();

    final canTap = onTap != null && !participant.isCurrentUser;

    return InkWell(
      onTap: canTap ? () => onTap!(participant) : null,
      borderRadius: BorderRadius.circular(18),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: borderColor,
                width: participant.isCurrentUser ? 2 : 1,
              ),
            ),
            child: CrewAvatar(
              radius: 20,
              backgroundColor: avatarColor.withValues(alpha: .12),
              foregroundColor: avatarColor,
              borderRadius: BorderRadius.circular(18),
              child: Text(
                initials,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 64,
            child: Text(
              participant.isCurrentUser
                  ? AppLocalizations.of(context)!.chat_you_label
                  : participant.displayName,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
