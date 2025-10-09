import 'package:crew_app/features/messages/data/chat_participant.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

class ChatRoomParticipantAvatar extends StatelessWidget {
  const ChatRoomParticipantAvatar({
    super.key,
    required this.participant,
  });

  final ChatParticipant participant;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final borderColor =
        participant.isCurrentUser ? colorScheme.primary : colorScheme.surface;
    final avatarColor = Color(
      participant.avatarColorValue ?? colorScheme.primary.value,
    );
    final initials = (participant.initials ??
            participant.displayName.characters.take(2).toString())
        .toUpperCase();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: borderColor,
              width: participant.isCurrentUser ? 2 : 1,
            ),
          ),
          child: CircleAvatar(
            radius: 20,
            backgroundColor: avatarColor.withValues(alpha: .12),
            child: Text(
              initials,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: avatarColor,
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
    );
  }
}
