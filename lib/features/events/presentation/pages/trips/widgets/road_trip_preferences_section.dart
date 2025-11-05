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
      subtitle: "",
      children: [
        TextField(
          controller: tagInputController,
          style: const TextStyle(fontSize: 14),
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
          maxLength: 30,
          onSubmitted: (_) => onSubmitTag(),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: tags
              .map(
                (t) => Chip(
                  label: Text(
                    '#$t',
                    style: const TextStyle(fontSize: 12),
                  ),
                  deleteIcon: const Icon(Icons.close, size: 16),
                  onDeleted: () => onRemoveTag(t),
                  labelStyle: const TextStyle(fontSize: 12),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
