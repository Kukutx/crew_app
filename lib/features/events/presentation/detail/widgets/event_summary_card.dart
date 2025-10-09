import 'package:crew_app/features/events/data/event.dart';
import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

class EventSummaryCard extends StatelessWidget {
  final Event event;
  final AppLocalizations loc;

  const EventSummaryCard({
    super.key,
    required this.event,
    required this.loc,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      color: colorScheme.surfaceContainerLow,
      elevation: 0,
      shadowColor: colorScheme.shadow.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _buildTags(loc, theme, colorScheme),
            ),
            const SizedBox(height: 16),
            Text(
              event.description,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tagChip(
    String label,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.primary.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
  }

  List<Widget> _buildTags(
    AppLocalizations loc,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final tags = event.tags;
    if (tags.isEmpty) {
      return [
        _tagChip(loc.tag_city_explore, theme, colorScheme),
        _tagChip(loc.tag_easy_social, theme, colorScheme),
        _tagChip(loc.tag_walk_friendly, theme, colorScheme),
      ];
    }
    return tags
        .take(6)
        .map((tag) => _tagChip(tag, theme, colorScheme))
        .toList(growable: false);
  }
}
