import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

import 'road_trip_section_card.dart';

class RoadTripStorySection extends StatelessWidget {
  const RoadTripStorySection({
    super.key,
    required this.descriptionController,
  });

  final TextEditingController descriptionController;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return RoadTripSectionCard(
      icon: Icons.description_outlined,
      title: loc.road_trip_story_section_title,
      subtitle: loc.road_trip_story_section_subtitle,
      children: [
        TextFormField(
          controller: descriptionController,
          decoration: roadTripInputDecoration(
            context,
            loc.road_trip_story_description_label,
            loc.road_trip_story_description_hint,
          ),
          maxLines: 6,
          validator: (v) => (v == null || v.trim().isEmpty)
              ? loc.road_trip_story_description_required
              : null,
        ),
      ],
    );
  }
}
