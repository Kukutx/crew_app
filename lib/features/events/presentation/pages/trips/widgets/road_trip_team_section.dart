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
    return RoadTripSectionCard(
      icon: Icons.groups_3_outlined,
      title: '团队配置',
      subtitle: '人数限制与费用模式',
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: maxParticipantsController,
                decoration: roadTripInputDecoration(context, '人数上限', '例如 4'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  final n = int.tryParse(v ?? '');
                  if (n == null || n < 1) {
                    return '请输入≥1的整数';
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
                  '人均费用 (€)',
                  pricingType == RoadTripPricingType.free ? '免费活动' : '例如 29.5',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                enabled: pricingType == RoadTripPricingType.paid,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SegmentedButton<RoadTripPricingType>(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(
              value: RoadTripPricingType.free,
              label: Text('免费'),
              icon: Icon(Icons.favorite_outline),
            ),
            ButtonSegment(
              value: RoadTripPricingType.paid,
              label: Text('收费'),
              icon: Icon(Icons.payments_outlined),
            ),
          ],
          selected: {pricingType},
          onSelectionChanged: (value) => onPricingTypeChanged(value.first),
        ),
      ],
    );
  }
}
