import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:crew_app/shared/widgets/crew_avatar.dart';
import 'package:flutter/material.dart';

class EventMembersList extends StatelessWidget {
  final AppLocalizations loc;

  const EventMembersList({
    super.key,
    required this.loc,
  });

  // 模拟成员数据
  static const List<_Member> _members = [
    _Member(
      name: 'Luna',
      initials: 'LU',
      role: '组织者',
      accentColor: 0xFF6750A4,
    ),
    _Member(
      name: 'Alex',
      initials: 'AL',
      role: '参与者',
      accentColor: 0xFF4C6ED7,
    ),
    _Member(
      name: 'Mia',
      initials: 'MI',
      role: '参与者',
      accentColor: 0xFF377D71,
    ),
    _Member(
      name: 'Sam',
      initials: 'SA',
      role: '参与者',
      accentColor: 0xFF9C27B0,
    ),
    _Member(
      name: 'Emma',
      initials: 'EM',
      role: '参与者',
      accentColor: 0xFFE91E63,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _members.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        thickness: 1,
        color: colorScheme.outline.withValues(alpha: 0.1),
      ),
      itemBuilder: (context, index) {
        final member = _members[index];
        return _MemberTile(
          member: member,
          colorScheme: colorScheme,
        );
      },
    );
  }
}

class _Member {
  final String name;
  final String initials;
  final String role;
  final int accentColor;

  const _Member({
    required this.name,
    required this.initials,
    required this.role,
    required this.accentColor,
  });
}

class _MemberTile extends StatelessWidget {
  final _Member member;
  final ColorScheme colorScheme;

  const _MemberTile({
    required this.member,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      leading: CrewAvatar(
        radius: 24,
        backgroundColor: Color(member.accentColor).withValues(alpha: 0.15),
        foregroundColor: Color(member.accentColor),
        child: Text(
          member.initials,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      title: Text(
        member.name,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          height: 1.3,
          letterSpacing: 0,
        ),
      ),
      subtitle: Text(
        member.role,
        style: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
          fontSize: 13,
          height: 1.4,
          letterSpacing: 0,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        size: 20,
        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
      ),
      onTap: () {
        // TODO: 打开成员详情页面
      },
    );
  }
}

