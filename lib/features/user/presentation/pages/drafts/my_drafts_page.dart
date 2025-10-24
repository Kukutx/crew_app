import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

class MyDraftsPage extends StatelessWidget {
  const MyDraftsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.my_drafts_title),
      ),
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
    final colorScheme = Theme.of(context).colorScheme;

    final drafts = [
      _DraftPreview(
        title: _localizedText(
          context,
          en: 'Sunrise rooftop flow',
          zh: '日出天台流瑜伽',
        ),
        schedule: _localizedText(
          context,
          en: 'Apr 26 · 7:00 AM',
          zh: '4月26日 · 07:00',
        ),
        location: _localizedText(
          context,
          en: 'Riverside Studio',
          zh: '江畔瑜伽馆',
        ),
        lastEdited: loc.my_drafts_last_edited(
          _localizedText(context, en: '2 days ago', zh: '2天'),
        ),
        tags: [loc.tag_sports, loc.tag_easy_social],
        gradient: const LinearGradient(
          colors: [Color(0xFF8BC6EC), Color(0xFF9599E2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      _DraftPreview(
        title: _localizedText(
          context,
          en: 'Community night market',
          zh: '社区夜市快闪',
        ),
        schedule: _localizedText(
          context,
          en: 'May 5 · 6:30 PM',
          zh: '5月5日 · 18:30',
        ),
        location: _localizedText(
          context,
          en: 'Old Town Plaza',
          zh: '老城广场',
        ),
        lastEdited: loc.my_drafts_last_edited(
          _localizedText(context, en: '5 hours ago', zh: '5小时'),
        ),
        tags: [loc.tag_trending, loc.tag_party],
        gradient: const LinearGradient(
          colors: [Color(0xFFFFC3A0), Color(0xFFFFAFBD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      _DraftPreview(
        title: _localizedText(
          context,
          en: 'Art walk with live sketching',
          zh: '街区艺术写生漫步',
        ),
        schedule: _localizedText(
          context,
          en: 'Apr 30 · 4:00 PM',
          zh: '4月30日 · 16:00',
        ),
        location: _localizedText(
          context,
          en: 'East Riverfront',
          zh: '东岸河畔',
        ),
        lastEdited: loc.my_drafts_last_edited(
          _localizedText(context, en: '1 week ago', zh: '1周'),
        ),
        tags: [loc.tag_city_explore, loc.tag_friends],
        gradient: const LinearGradient(
          colors: [Color(0xFFA1C4FD), Color(0xFFC2E9FB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      _DraftPreview(
        title: _localizedText(
          context,
          en: 'Coffee tasting circle',
          zh: '城市咖啡品鉴会',
        ),
        schedule: _localizedText(
          context,
          en: 'May 2 · 3:30 PM',
          zh: '5月2日 · 15:30',
        ),
        location: _localizedText(
          context,
          en: 'Maple Street Hub',
          zh: '枫叶街社群中心',
        ),
        lastEdited: loc.my_drafts_last_edited(
          _localizedText(context, en: 'Yesterday', zh: '昨日'),
        ),
        tags: [loc.tag_easy_social, loc.tag_trending],
        gradient: const LinearGradient(
          colors: [Color(0xFFF6D365), Color(0xFFFDA085)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
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
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: drafts.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.72,
          ),
          itemBuilder: (context, index) {
            return _DraftCard(draft: drafts[index], colorScheme: colorScheme);
          },
        ),
      ],
    );
  }
}

class _DraftCard extends StatelessWidget {
  const _DraftCard({required this.draft, required this.colorScheme});

  final _DraftPreview draft;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: colorScheme.surfaceContainerLow,
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: Container(
                decoration: BoxDecoration(gradient: draft.gradient),
                padding: const EdgeInsets.all(16),
                alignment: Alignment.bottomLeft,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: draft.tags
                      .map(
                        (tag) => Chip(
                          label: Text(tag),
                          visualDensity: VisualDensity.compact,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                          shape: StadiumBorder(
                            side: BorderSide(color: Colors.white.withOpacity(0.4)),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    draft.title,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${draft.schedule} · ${draft.location}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Text(
                    draft.lastEdited,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.tonal(
                    onPressed: () {},
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(36),
                    ),
                    child: Text(AppLocalizations.of(context)!.my_drafts_resume_button),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DraftPreview {
  const _DraftPreview({
    required this.title,
    required this.schedule,
    required this.location,
    required this.lastEdited,
    required this.tags,
    required this.gradient,
  });

  final String title;
  final String schedule;
  final String location;
  final String lastEdited;
  final List<String> tags;
  final Gradient gradient;
}

String _localizedText(BuildContext context,
    {required String en, required String zh}) {
  final locale = Localizations.localeOf(context);
  return locale.languageCode == 'zh' ? zh : en;
}
