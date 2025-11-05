import 'package:crew_app/features/events/presentation/pages/detail/widgets/event_moment_card.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:crew_app/shared/widgets/crew_avatar.dart';
import 'package:flutter/material.dart';

class EventContentTabs extends StatefulWidget {
  final AppLocalizations loc;

  const EventContentTabs({
    super.key,
    required this.loc,
  });

  @override
  State<EventContentTabs> createState() => _EventContentTabsState();
}

class _EventContentTabsState extends State<EventContentTabs> {
  int _currentTab = 0;
  double _startDragX = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题和指示点
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Row(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Text(
                  _currentTab == 0
                      ? widget.loc.events_tab_moments
                      : widget.loc.event_members_list,
                  key: ValueKey(_currentTab),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    height: 1.3,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              const Spacer(),
              // 指示点
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _TabIndicator(
                    isActive: _currentTab == 0,
                    onTap: () {
                      setState(() {
                        _currentTab = 0;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  _TabIndicator(
                    isActive: _currentTab == 1,
                    onTap: () {
                      setState(() {
                        _currentTab = 1;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        // 内容切换 - 支持手势滑动，内容自适应高度
        GestureDetector(
          onHorizontalDragStart: (details) {
            _startDragX = details.globalPosition.dx;
          },
          onHorizontalDragEnd: (details) {
            final deltaX = details.globalPosition.dx - _startDragX;
            const threshold = 50.0;
            
            if (deltaX > threshold && _currentTab > 0) {
              // 向右滑动，切换到上一页
              setState(() {
                _currentTab--;
              });
            } else if (deltaX < -threshold && _currentTab < 1) {
              // 向左滑动，切换到下一页
              setState(() {
                _currentTab++;
              });
            }
          },
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: _currentTab == 0
                ? EventMomentCard(
                    key: const ValueKey('moments'),
                    loc: widget.loc,
                  )
                : _MembersList(
                    key: const ValueKey('members'),
                    loc: widget.loc,
                  ),
          ),
        ),
      ],
    );
  }
}

class _TabIndicator extends StatelessWidget {
  final bool isActive;
  final VoidCallback onTap;

  const _TabIndicator({
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        width: isActive ? 24 : 8,
        height: 8,
        decoration: BoxDecoration(
          color: isActive
              ? colorScheme.primary
              : colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}

// 成员列表组件
class _MembersList extends StatelessWidget {
  final AppLocalizations loc;

  const _MembersList({
    super.key,
    required this.loc,
  });

  // 模拟成员数据 - 注意：角色应在实际数据中提供，这里需要 AppLocalizations
  // 为了简化，我们保持静态数据，但角色应该从外部传入
  static List<_Member> _getMembers(AppLocalizations loc) => [
    _Member(
      name: 'Luna',
      initials: 'LU',
      role: loc.event_member_role_organizer,
      accentColor: 0xFF6750A4,
    ),
    _Member(
      name: 'Alex',
      initials: 'AL',
      role: loc.event_member_role_participant,
      accentColor: 0xFF4C6ED7,
    ),
    _Member(
      name: 'Mia',
      initials: 'MI',
      role: loc.event_member_role_participant,
      accentColor: 0xFF377D71,
    ),
    _Member(
      name: 'Sam',
      initials: 'SA',
      role: loc.event_member_role_participant,
      accentColor: 0xFF9C27B0,
    ),
    _Member(
      name: 'Emma',
      initials: 'EM',
      role: loc.event_member_role_participant,
      accentColor: 0xFFE91E63,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final members = _getMembers(loc);

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: members.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        thickness: 1,
        color: colorScheme.outline.withValues(alpha: 0.1),
      ),
      itemBuilder: (context, index) {
        final member = members[index];
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

