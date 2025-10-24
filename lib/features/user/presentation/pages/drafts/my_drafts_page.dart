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
    (
      title: 'Sunrise rooftop flow',
      timeLabel: 'Apr 26 · 7:00 AM',
      location: 'Riverside Studio',
    ),
    (
      title: 'Community night market',
      timeLabel: 'May 5 · 6:30 PM',
      location: 'Old Town Plaza',
    ),
    (
      title: 'Art walk with live sketching',
      timeLabel: 'Apr 30 · 4:00 PM',
      location: 'East Riverfront',
    ),
    (
      title: 'Coffee tasting circle',
      timeLabel: 'May 2 · 3:30 PM',
      location: 'Maple Street Hub',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.my_drafts_section_saved,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        Column(
          children: [
            for (var i = 0; i < _drafts.length; i++) ...[
              MapEventFloatingCard(
                title: _drafts[i].title,
                timeLabel: _drafts[i].timeLabel,
                location: _drafts[i].location,
                primaryAction: FilledButton.tonal(
                  onPressed: () {},
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 36),
                  ),
                  child: Text(loc.my_drafts_resume_button),
                ),
              ),
              if (i != _drafts.length - 1) const SizedBox(height: 16),
            ],
          ],
        ),
      ],
    );
  }
}

