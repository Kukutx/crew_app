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
    final titleStyle = theme.textTheme.titleLarge?.copyWith(
      color: colorScheme.onSurface,
      fontWeight: FontWeight.bold,
    );
    final descriptionStyle = theme.textTheme.bodyMedium?.copyWith(
      color: colorScheme.onSurfaceVariant,
      height: 1.5,
    );
    final tagTextStyle = theme.textTheme.labelMedium?.copyWith(
      color: colorScheme.onPrimaryContainer,
      fontWeight: FontWeight.w600,
    );
    final tagBackground = colorScheme.primaryContainer;
    final tagBorderColor = colorScheme.primary.withOpacity(0.4);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: colorScheme.surfaceVariant,
      shadowColor: Colors.black.withOpacity(0.45),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.title,
              style: titleStyle ??
                  const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _buildTags(
                loc,
                tagBackground,
                tagBorderColor,
                tagTextStyle ??
                    const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              event.description,
              style: descriptionStyle ??
                  const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tagChip(
    String label,
    Color backgroundColor,
    Color borderColor,
    TextStyle textStyle,
  ) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Text(label, style: textStyle),
      );

  List<Widget> _buildTags(
    AppLocalizations loc,
    Color backgroundColor,
    Color borderColor,
    TextStyle textStyle,
  ) {
    final tags = event.tags;
    if (tags.isEmpty) {
      return [
        _tagChip(loc.tag_city_explore, backgroundColor, borderColor, textStyle),
        _tagChip(loc.tag_easy_social, backgroundColor, borderColor, textStyle),
        _tagChip(loc.tag_walk_friendly, backgroundColor, borderColor, textStyle),
      ];
    }
    return tags
        .take(6)
        .map(
          (label) => _tagChip(label, backgroundColor, borderColor, textStyle),
        )
        .toList(growable: false);
  }
}
