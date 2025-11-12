import 'package:crew_app/features/messages/data/chat_member.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:crew_app/shared/widgets/crew_avatar.dart';
import 'package:flutter/material.dart';

class ChatRoomMemberAvatar extends StatelessWidget {
  const ChatRoomMemberAvatar({
    super.key,
    required this.member,
    this.onTap,
  });

  final ChatMember member;
  final ValueChanged<ChatMember>? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final borderColor =
        member.isCurrentUser ? colorScheme.primary : colorScheme.surface;
    final avatarColor = Color(
      member.avatarColorValue ?? colorScheme.primary.toARGB32(),
    );
    final initials = (member.initials ??
            member.displayName.characters.take(2).toString())
        .toUpperCase();

    final canTap = onTap != null && !member.isCurrentUser;

    return InkWell(
      onTap: canTap ? () => onTap!(member) : null,
      borderRadius: BorderRadius.circular(18),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: borderColor,
                width: member.isCurrentUser ? 2 : 1,
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
              member.isCurrentUser
                  ? AppLocalizations.of(context)!.chat_you_label
                  : member.displayName,
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

