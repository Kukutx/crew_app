import 'package:crew_app/features/messages/data/messages_chat_participant.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

class MessagesChatRoomParticipantAvatar extends StatelessWidget {
  const MessagesChatRoomParticipantAvatar({
    super.key,
    required this.participant,
  });

  final GroupParticipant participant;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final borderColor = participant.isSelf ? colorScheme.primary : colorScheme.surface;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: borderColor,
              width: participant.isSelf ? 2 : 1,
            ),
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
            participant.isSelf
                ? AppLocalizations.of(context)!.chat_you_label
                : participant.name,
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
