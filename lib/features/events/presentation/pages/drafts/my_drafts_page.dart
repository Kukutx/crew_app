import 'package:crew_app/features/events/presentation/widgets/trips/road_trip_editor_page.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
// 各种活动的草稿

class MyDraftsPage extends StatelessWidget {
  const MyDraftsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(loc.my_drafts_title)),
      body: const SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 24),
              sliver: SliverToBoxAdapter(
                child: _DraftsContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class _DraftsContent extends StatelessWidget {
  const _DraftsContent();

  static const _drafts = <({String title, String timeLabel, String location})>[
    (title: 'Sunrise rooftop flow', timeLabel: 'Apr 26 · 7:00 AM', location: 'Riverside Studio'),
    (title: 'Community night market', timeLabel: 'May 5 · 6:30 PM', location: 'Old Town Plaza'),
    (title: 'Art walk with live sketching', timeLabel: 'Apr 30 · 4:00 PM', location: 'East Riverfront'),
    (title: 'Coffee tasting circle', timeLabel: 'May 2 · 3:30 PM', location: 'Maple Street Hub'),
  ];

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(loc.my_drafts_section_saved, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _drafts.length,
          separatorBuilder: (_, _) => const SizedBox(height: 14),
          itemBuilder: (context, i) => _DraftCard(
            title: _drafts[i].title,
            timeLabel: _drafts[i].timeLabel,
            location: _drafts[i].location,
            onTap: () => _openEditor(context),
            resumeLabel: loc.my_drafts_resume_button,
          ),
        ),
      ],
    );
  }

  void _openEditor(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (routeContext) => RoadTripEditorPage(onClose: () => Navigator.of(routeContext).pop()),
    ));
  }
}

class _DraftCard extends StatelessWidget {
  const _DraftCard({
    required this.title,
    required this.timeLabel,
    required this.location,
    required this.onTap,
    required this.resumeLabel,
  });

  final String title;
  final String timeLabel;
  final String location;
  final VoidCallback onTap;
  final String resumeLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = Theme.of(context).colorScheme;
    final bg = base.surfaceContainerHigh;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [bg.withValues(alpha: 0.98), bg.withValues(alpha: 0.92)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.45),
              offset: const Offset(8, 10),
              blurRadius: 20,
              spreadRadius: -6,
            ),
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.06),
              offset: const Offset(-6, -6),
              blurRadius: 12,
              spreadRadius: -8,
            ),
          ],
          border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
        ),
        child: Row(
          children: [
            _Thumb(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题 + 删除按钮
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: .2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _DeleteButton(onPressed: () {
                        // TODO: 删除逻辑
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('已删除草稿')),
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.event, size: 16),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(timeLabel, style: theme.textTheme.bodySmall?.copyWith(height: 1.1)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(location, style: theme.textTheme.bodySmall?.copyWith(height: 1.1)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _Badge(text: '草稿'),
                      const Spacer(),
                      FilledButton.tonal(
                        onPressed: onTap,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(0, 36),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(resumeLabel),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: cs.surfaceContainerHighest.withValues(alpha: .5),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: .35), blurRadius: 10, offset: const Offset(6, 8), spreadRadius: -6),
          BoxShadow(color: Colors.white.withValues(alpha: .06), blurRadius: 8, offset: const Offset(-4, -4), spreadRadius: -6),
        ],
        border: Border.all(color: Colors.white.withValues(alpha: .06)),
      ),
      child: const Icon(Icons.image_not_supported_outlined, size: 22),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cs.secondaryContainer.withValues(alpha: .6),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: .08)),
      ),
      child: Text(text, style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700)),
    );
  }
}

/// 新拟态风格的小型 X 按钮
class _DeleteButton extends StatelessWidget {
  const _DeleteButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onPressed,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: cs.surface.withValues(alpha: 0.4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              offset: const Offset(2, 3),
              blurRadius: 6,
              spreadRadius: -2,
            ),
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.05),
              offset: const Offset(-2, -2),
              blurRadius: 6,
              spreadRadius: -3,
            ),
          ],
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: const Icon(Icons.close_rounded, size: 18),
      ),
    );
  }
}