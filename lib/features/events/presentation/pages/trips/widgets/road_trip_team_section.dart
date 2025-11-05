import 'package:crew_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

import '../data/road_trip_editor_models.dart';
import 'road_trip_section_card.dart';

class RoadTripTeamSection extends StatelessWidget {
  const RoadTripTeamSection({
    super.key,
    required this.maxParticipantsController,
    required this.priceController,
    required this.pricingType,
    required this.onPricingTypeChanged,
  });

  final TextEditingController maxParticipantsController;
  final TextEditingController priceController;
  final RoadTripPricingType pricingType;
  final ValueChanged<RoadTripPricingType> onPricingTypeChanged;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return RoadTripSectionCard(
      icon: Icons.groups_3_outlined,
      title: loc.road_trip_team_section_title,
      subtitle: loc.road_trip_team_section_subtitle,
      headerTrailing: SegmentedButton<RoadTripPricingType>(
        showSelectedIcon: false,
        segments: [
          ButtonSegment(
            value: RoadTripPricingType.free,
            label: Text(loc.road_trip_team_pricing_free),
            icon: const Icon(Icons.favorite_outline),
          ),
          ButtonSegment(
            value: RoadTripPricingType.paid,
            label: Text(loc.road_trip_team_pricing_paid),
            icon: const Icon(Icons.payments_outlined),
          ),
        ],
        selected: {pricingType},
        onSelectionChanged: (value) => onPricingTypeChanged(value.first),
      ),
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: maxParticipantsController,
                decoration: roadTripInputDecoration(
                  context,
                  loc.road_trip_team_max_participants_label,
                  loc.road_trip_team_max_participants_hint,
                ),
                keyboardType: TextInputType.number,
                maxLength: 3,
                validator: (v) {
                  final n = int.tryParse(v ?? '');
                  if (n == null || n < 1) {
                    return loc.road_trip_team_max_participants_error;
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: priceController,
                decoration: roadTripInputDecoration(
                  context,
                  loc.road_trip_team_price_label,
                  pricingType == RoadTripPricingType.free
                      ? loc.road_trip_team_price_free_hint
                      : loc.road_trip_team_price_paid_hint,
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                maxLength: 10,
                enabled: pricingType == RoadTripPricingType.paid,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
