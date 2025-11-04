import 'package:crew_app/features/events/presentation/pages/detail/widgets/event_members_list.dart';
import 'package:crew_app/features/events/presentation/pages/detail/widgets/event_moment_card.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

class EventMomentsSection extends StatefulWidget {
  final AppLocalizations loc;

  const EventMomentsSection({
    super.key,
    required this.loc,
  });

  @override
  State<EventMomentsSection> createState() => _EventMomentsSectionState();
}

class _EventMomentsSectionState extends State<EventMomentsSection> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

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
                  _currentPage == 0
                      ? widget.loc.events_tab_moments
                      : '成员列表',
                  key: ValueKey(_currentPage),
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
                  _PageIndicator(
                    isActive: _currentPage == 0,
                    onTap: () {
                      _pageController.animateToPage(
                        0,
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  _PageIndicator(
                    isActive: _currentPage == 1,
                    onTap: () {
                      _pageController.animateToPage(
                        1,
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        // PageView
        SizedBox(
          height: 500,
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            children: [
              // 第一页：Moments
              SingleChildScrollView(
                child: EventMomentCard(loc: widget.loc),
              ),
              // 第二页：成员列表
              EventMembersList(loc: widget.loc),
            ],
          ),
        ),
      ],
    );
  }
}

class _PageIndicator extends StatelessWidget {
  final bool isActive;
  final VoidCallback onTap;

  const _PageIndicator({
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

