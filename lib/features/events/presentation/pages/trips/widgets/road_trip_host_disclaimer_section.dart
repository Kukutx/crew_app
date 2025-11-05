import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'road_trip_section_card.dart';

class RoadTripHostDisclaimerSection extends StatelessWidget {
  const RoadTripHostDisclaimerSection({
    super.key,
    required this.disclaimerController,
  });

  final TextEditingController disclaimerController;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return RoadTripSectionCard(
      icon: Icons.shield_moon_outlined,
      title: loc.road_trip_disclaimer_section_title,
      subtitle: loc.road_trip_disclaimer_section_subtitle,
      children: [
        TextFormField(
          controller: disclaimerController,
          style: const TextStyle(fontSize: 14),
          decoration: roadTripInputDecoration(
            context,
            loc.road_trip_disclaimer_content_label,
            loc.road_trip_disclaimer_content_hint,
          ),
          minLines: 3,
          maxLines: 5,
          maxLength: 500,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
        ),
      ],
    );
  }
}
