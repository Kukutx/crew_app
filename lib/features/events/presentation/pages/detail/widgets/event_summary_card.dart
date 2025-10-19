import 'package:crew_app/features/events/data/event.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:crew_app/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class EventSummaryCard extends StatelessWidget {
  const EventSummaryCard({
    super.key,
    required this.event,
    required this.loc,
  });

  final Event event;
  final AppLocalizations loc;

  @override
  Widget build(BuildContext context) {
    final tags = event.tags.isNotEmpty
        ? event.tags.take(4).toList(growable: false)
        : [loc.tag_city_explore, loc.tag_walk_friendly, loc.tag_easy_social];

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.event_details_title,
              style: AppTextStyles.subtitle,
            ),
            const SizedBox(height: 14),
            Text(
              event.title,
              style: AppTextStyles.headline,
            ),
            const SizedBox(height: 12),
            Text(
              event.description,
              style: AppTextStyles.body,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tags
                  .map(
                    (tag) => Chip(
                      label: Text(tag),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
          ],
        ),
      ),
    );
  }
}
