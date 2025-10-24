import 'package:crew_app/features/events/presentation/pages/map/widgets/map_event_floating_card.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

class MyDraftsPage extends StatelessWidget {
  const MyDraftsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(loc.my_drafts_title)),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              sliver: const SliverToBoxAdapter(
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

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final drafts = [
      _DraftPreview(
        title: _localizedText(
          context,
          en: 'Sunrise rooftop flow',
          zh: '日出天台流瑜伽',
        ),
        timeLabel: _localizedText(
          context,
          en: 'Apr 26 · 7:00 AM',
          zh: '4月26日 · 07:00',
        ),
        location: _localizedText(
          context,
          en: 'Riverside Studio',
          zh: '江畔瑜伽馆',
        ),
      ),
      _DraftPreview(
        title: _localizedText(
          context,
          en: 'Community night market',
          zh: '社区夜市快闪',
        ),
        timeLabel: _localizedText(
          context,
          en: 'May 5 · 6:30 PM',
          zh: '5月5日 · 18:30',
        ),
        location: _localizedText(
          context,
          en: 'Old Town Plaza',
          zh: '老城广场',
        ),
      ),
      _DraftPreview(
        title: _localizedText(
          context,
          en: 'Art walk with live sketching',
          zh: '街区艺术写生漫步',
        ),
        timeLabel: _localizedText(
          context,
          en: 'Apr 30 · 4:00 PM',
          zh: '4月30日 · 16:00',
        ),
        location: _localizedText(
          context,
          en: 'East Riverfront',
          zh: '东岸河畔',
        ),
      ),
      _DraftPreview(
        title: _localizedText(
          context,
          en: 'Coffee tasting circle',
          zh: '城市咖啡品鉴会',
        ),
        timeLabel: _localizedText(
          context,
          en: 'May 2 · 3:30 PM',
          zh: '5月2日 · 15:30',
        ),
        location: _localizedText(
          context,
          en: 'Maple Street Hub',
          zh: '枫叶街社群中心',
        ),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.my_drafts_section_saved,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        Column(
          children: [
            for (var i = 0; i < drafts.length; i++) ...[
              _DraftCard(draft: drafts[i]),
              if (i != drafts.length - 1) const SizedBox(height: 16),
            ],
          ],
        ),
      ],
    );
  }
}

class _DraftCard extends StatelessWidget {
  const _DraftCard({required this.draft});

  final _DraftPreview draft;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return MapEventFloatingCard(
      title: draft.title,
      timeLabel: draft.timeLabel,
      location: draft.location,
      primaryAction: FilledButton.tonal(
        onPressed: () {},
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 36),
        ),
        child: Text(loc.my_drafts_resume_button),
      ),
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(24),
      elevation: 4,
    );
  }
}

class _DraftPreview {
  const _DraftPreview({
    required this.title,
    required this.timeLabel,
    required this.location,
  });

  final String title;
  final String timeLabel;
  final String location;
}

String _localizedText(BuildContext context,
    {required String en, required String zh}) {
  final locale = Localizations.localeOf(context);
  return locale.languageCode == 'zh' ? zh : en;
}

