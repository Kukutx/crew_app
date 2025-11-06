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
      subtitle: '',
      children: [
        TextFormField(
          controller: titleController,
          style: const TextStyle(fontSize: 14),
          decoration: roadTripInputDecoration(
            context,
            loc.road_trip_basic_title_label,
            loc.road_trip_basic_title_hint,
          ),
          maxLength: 20,
          validator: (v) => (v == null || v.trim().isEmpty)
              ? loc.road_trip_basic_title_required
              : null,
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: onPickDateRange,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_month,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    dateRange == null
                        ? loc.road_trip_basic_date_label
                        : '${DateFormatHelper.formatDate(dateRange!.start)} → ${DateFormatHelper.formatDate(dateRange!.end)}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
