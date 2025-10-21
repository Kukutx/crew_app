import 'package:flutter/material.dart';

import 'road_trip_form_decorations.dart';
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
    return RoadTripSectionCard(
      icon: Icons.tune,
      title: '个性设置',
      subtitle: '车辆与标签',
      children: [
        DropdownButtonFormField<String>(
          initialValue : carType,
          decoration: roadTripInputDecoration(context, '车辆类型（可选）', null),
          items: const [
            DropdownMenuItem(value: 'Sedan', child: Text('Sedan')),
            DropdownMenuItem(value: 'SUV', child: Text('SUV')),
            DropdownMenuItem(value: 'Hatchback', child: Text('Hatchback')),
            DropdownMenuItem(value: 'Van', child: Text('Van')),
          ],
          onChanged: onCarTypeChanged,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: tagInputController,
          decoration: roadTripInputDecoration(context, '添加标签', '添加').copyWith(
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
