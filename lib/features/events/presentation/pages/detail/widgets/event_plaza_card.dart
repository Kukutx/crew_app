import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:crew_app/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class EventPlazaCard extends StatelessWidget {
  const EventPlazaCard({super.key, required this.loc});

  final AppLocalizations loc;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.events_tab_moments,
              style: AppTextStyles.subtitle,
            ),
            const SizedBox(height: 12),
            Text(
              loc.feature_not_ready,
              style: AppTextStyles.body,
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(loc.feature_not_ready)),
                );
              },
              icon: const Icon(Icons.auto_awesome),
              label: Text(loc.event_detail_publish_plaza),
            ),
          ],
        ),
      ),
    );
  }
}
