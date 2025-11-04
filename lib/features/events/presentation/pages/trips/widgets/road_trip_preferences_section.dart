import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'road_trip_section_card.dart';

class RoadTripPreferencesSection extends StatelessWidget {
  const RoadTripPreferencesSection({
    super.key,
    required this.carType,
    required this.onCarTypeChanged,
    required this.tagInputController,
    required this.onSubmitTag,
    required this.tags,
    required this.onRemoveTag,
  });

  final String? carType;
  final ValueChanged<String?> onCarTypeChanged;
  final TextEditingController tagInputController;
  final VoidCallback onSubmitTag;
  final List<String> tags;
  final ValueChanged<String> onRemoveTag;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return RoadTripSectionCard(
      icon: Icons.tune,
      title: loc.road_trip_preferences_section_title,
      subtitle: loc.road_trip_preferences_section_subtitle,
      children: [
        DropdownButtonFormField<String>(
          initialValue: carType,
          decoration: roadTripInputDecoration(
            context,
            loc.road_trip_preferences_car_type_label,
            null,
          ),
          items: [
            DropdownMenuItem(
              value: 'Sedan',
              child: Text(loc.road_trip_preferences_car_sedan),
            ),
            DropdownMenuItem(
              value: 'SUV',
              child: Text(loc.road_trip_preferences_car_suv),
            ),
            DropdownMenuItem(
              value: 'Hatchback',
              child: Text(loc.road_trip_preferences_car_hatchback),
            ),
            DropdownMenuItem(
              value: 'Van',
              child: Text(loc.road_trip_preferences_car_van),
            ),
          ],
          onChanged: onCarTypeChanged,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: tagInputController,
          decoration: roadTripInputDecoration(
            context,
            loc.road_trip_preferences_tag_label,
            loc.road_trip_preferences_tag_hint,
          ).copyWith(
            suffixIcon: IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: onSubmitTag,
            ),
          ),
          onSubmitted: (_) => onSubmitTag(),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: tags
              .map(
                (t) => Chip(
                  label: Text('#$t'),
                  deleteIcon: const Icon(Icons.close),
                  onDeleted: () => onRemoveTag(t),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
