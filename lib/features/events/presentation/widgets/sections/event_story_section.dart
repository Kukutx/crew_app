import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

import 'event_section_card.dart';

class EventStorySection extends StatelessWidget {
  const EventStorySection({
    super.key,
    required this.descriptionController,
  });

  final TextEditingController descriptionController;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return EventSectionCard(
      icon: Icons.description_outlined,
      title: loc.road_trip_story_section_title,
      subtitle: loc.road_trip_story_section_subtitle,
      children: [
        TextFormField(
          controller: descriptionController,
          style: const TextStyle(fontSize: 14),
          decoration: eventInputDecoration(
            context,
            loc.road_trip_story_description_label,
            loc.road_trip_story_description_hint,
          ),
          maxLines: 6,
          maxLength: 500,
          validator: (v) => (v == null || v.trim().isEmpty)
              ? loc.road_trip_story_description_required
              : null,
        ),
      ],
    );
  }
}

