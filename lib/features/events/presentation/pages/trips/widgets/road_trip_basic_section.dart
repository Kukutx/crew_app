import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:crew_app/shared/utils/formatted_date.dart';
import 'package:flutter/material.dart';

import 'road_trip_section_card.dart';

class RoadTripBasicSection extends StatelessWidget {
  const RoadTripBasicSection({
    super.key,
    required this.titleController,
    required this.dateRange,
    required this.onPickDateRange,
  });

  final TextEditingController titleController;
  final DateTimeRange? dateRange;
  final VoidCallback onPickDateRange;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    return RoadTripSectionCard(
      icon: Icons.rocket_launch_outlined,
      title: loc.road_trip_basic_section_title,
      subtitle: loc.road_trip_basic_section_subtitle,
      children: [
        TextFormField(
          controller: titleController,
          decoration: roadTripInputDecoration(
            context,
            loc.road_trip_basic_title_label,
            loc.road_trip_basic_title_hint,
          ),
          validator: (v) => (v == null || v.trim().isEmpty)
              ? loc.road_trip_basic_title_required
              : null,
        ),
        const SizedBox(height: 16),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(
            Icons.calendar_month,
            color: theme.colorScheme.primary,
          ),
          title: Text(loc.road_trip_basic_date_label),
          subtitle: Text(
            dateRange == null
                ? loc.road_trip_basic_date_hint
                : '${FormattedDate.formatDate(dateRange!.start)} → ${FormattedDate.formatDate(dateRange!.end)}',
          ),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: onPickDateRange,
        ),
      ],
    );
  }
}
