import 'package:crew_app/features/events/data/event_models.dart';
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
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _buildTags(loc),
            ),
            const SizedBox(height: 16),
            Text(
              event.description,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tagChip(String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.shade300),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.orange),
        ),
      );

  List<Widget> _buildTags(AppLocalizations loc) {
    final tags = event.tags;
    if (tags.isEmpty) {
      return [
        _tagChip(loc.tag_city_explore),
        _tagChip(loc.tag_easy_social),
        _tagChip(loc.tag_walk_friendly),
      ];
    }
    return tags.take(6).map(_tagChip).toList(growable: false);
  }
}
